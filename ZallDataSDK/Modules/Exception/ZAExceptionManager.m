//
// ZAExceptionManager.m
// ZallDataSDK
//
// Created by guo on 2021/6/4.
// Copyright © 2021 Zall Data Co., Ltd. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag on this file.
#endif

#import "ZAExceptionManager.h"
#import "ZallDataSDK.h"
#import "ZAModuleManager.h"
#import "ZALog.h"
#import "ZAQueueManage.h"
#import "ZAEventTrackObject.h"
#import "ZallDataSDK+ZAPrivate.h"
#include <libkern/OSAtomic.h>
#include <execinfo.h>

static NSString * const kZASignalExceptionName = @"UncaughtExceptionHandlerSignalExceptionName";
static NSString * const kZASignalKey = @"UncaughtExceptionHandlerSignalKey";

static volatile int32_t kZAExceptionCount = 0;
static const int32_t kZAExceptionMaximum = 10;

static NSString * const kZAAppCrashedReason = @"app_crashed_reason";

@ZAAppLoadModule(ZAExceptionManager)
@interface ZAExceptionManager ()

@property (nonatomic) NSUncaughtExceptionHandler *defaultExceptionHandler;
@property (nonatomic, unsafe_unretained) struct sigaction *prev_signal_handlers;

@end

@implementation ZAExceptionManager

+ (instancetype)defaultManager {
    static dispatch_once_t onceToken;
    static ZAExceptionManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[ZAExceptionManager alloc] init];
    });
    return manager;
}

- (void)setEnable:(BOOL)enable {
    _enable = enable;

    if (enable) {
        _prev_signal_handlers = calloc(NSIG, sizeof(struct sigaction));

        [self setupExceptionHandler];
    }
}

- (void)setConfigOptions:(ZAConfigOptions *)configOptions {
    _configOptions = configOptions;
    self.enable = configOptions.enableTrackAppCrash;
}

- (void)dealloc {
    free(_prev_signal_handlers);
}

- (void)setupExceptionHandler {
    _defaultExceptionHandler = NSGetUncaughtExceptionHandler();
    NSSetUncaughtExceptionHandler(&ZAHandleException);

    struct sigaction action;
    sigemptyset(&action.sa_mask);
    action.sa_flags = SA_SIGINFO;
    action.sa_sigaction = &ZASignalHandler;
    int signals[] = {SIGABRT, SIGILL, SIGSEGV, SIGFPE, SIGBUS};
    for (int i = 0; i < sizeof(signals) / sizeof(int); i++) {
        struct sigaction prev_action;
        int err = sigaction(signals[i], &action, &prev_action);
        if (err == 0) {
            char *address_action = (char *)&prev_action;
            char *address_signal = (char *)(_prev_signal_handlers + signals[i]);
            strlcpy(address_signal, address_action, sizeof(prev_action));
        } else {
            ZALogError(@"Errored while trying to set up sigaction for signal %d", signals[i]);
        }
    }
}

#pragma mark - Handler

static void ZASignalHandler(int crashSignal, struct __siginfo *info, void *context) {
    int32_t exceptionCount = OSAtomicIncrement32(&kZAExceptionCount);
    if (exceptionCount <= kZAExceptionMaximum) {
        NSDictionary *userInfo = @{kZASignalKey: @(crashSignal)};
        NSString *reason = [NSString stringWithFormat:@"Signal %d was raised.", crashSignal];
        NSException *exception = [NSException exceptionWithName:kZASignalExceptionName
                                                         reason:reason
                                                       userInfo:userInfo];

        [ZAExceptionManager.defaultManager handleUncaughtException:exception];
    }

    struct sigaction prev_action = ZAExceptionManager.defaultManager.prev_signal_handlers[crashSignal];
    if (prev_action.sa_flags & SA_SIGINFO) {
        if (prev_action.sa_sigaction) {
            prev_action.sa_sigaction(crashSignal, info, context);
        }
    } else if (prev_action.sa_handler &&
               prev_action.sa_handler != SIG_IGN) {
        // SIG_IGN 表示忽略信号
        prev_action.sa_handler(crashSignal);
    }
}

static void ZAHandleException(NSException *exception) {
    int32_t exceptionCount = OSAtomicIncrement32(&kZAExceptionCount);
    if (exceptionCount <= kZAExceptionMaximum) {
        [ZAExceptionManager.defaultManager handleUncaughtException:exception];
    }

    if (ZAExceptionManager.defaultManager.defaultExceptionHandler) {
        ZAExceptionManager.defaultManager.defaultExceptionHandler(exception);
    }
}

- (void)handleUncaughtException:(NSException *)exception {
    if (!self.enable) {
        return;
    }
    @try {
        NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
        if (exception.callStackSymbols) {
            properties[kZAAppCrashedReason] = [NSString stringWithFormat:@"Exception Reason:%@\nException Stack:%@", exception.reason, [exception.callStackSymbols componentsJoinedByString:@"\n"]];
        } else {
            properties[kZAAppCrashedReason] = [NSString stringWithFormat:@"%@ %@", exception.reason, [NSThread.callStackSymbols componentsJoinedByString:@"\n"]];
        }
        ZAEventPresetTrackObject *object = [[ZAEventPresetTrackObject alloc] initWithEventId:kZAEventNameAppCrashed];
        [ZallDataSDK.sharedInstance asyncTrackEventObject:object properties:properties];

        //触发页面浏览时长事件
        [[ZAModuleManager sharedInstance] trackPageLeaveWhenCrashed];

        // 触发退出事件
        [ZAModuleManager.sharedInstance trackAppEndWhenCrashed];

        // 阻塞当前线程，完成 serialQueue 中数据相关的任务
        [ZAQueueManage sdkOperationQueueSync:^{}];
        ZALogError(@"Encountered an uncaught exception. All ZallAnalytics instances were archived.");
    } @catch(NSException *exception) {
        ZALogError(@"%@ error: %@", self, exception);
    }

    NSSetUncaughtExceptionHandler(NULL);
    signal(SIGABRT, SIG_DFL);
    signal(SIGILL, SIG_DFL);
    signal(SIGSEGV, SIG_DFL);
    signal(SIGFPE, SIG_DFL);
    signal(SIGBUS, SIG_DFL);
}

@end
