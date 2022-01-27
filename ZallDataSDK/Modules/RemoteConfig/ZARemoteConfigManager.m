//
// ZARemoteConfigManager.m
// ZallDataSDK
//
// Created by guo on 2020/11/5.
// Copyright © 2020 Zall Data Co., Ltd. All rights reserved.
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

#import "ZARemoteConfigManager.h"
#import "ZAModuleManager.h"
#import "ZALog.h"
#import "ZAConfigOptions.h"
#import "ZARemoteConfigOperator.h"
#import "ZARemoteConfigCommonOperator.h"
#import "ZAEventBaseObject.h"
#import "ZallDataSDK+ZARemoteConfig.h"
#import "ZallDataSDK+ZAPrivate.h"
#import "ZARemoteConfigCheckOperator.h"

@ZAAppLoadModule(ZARemoteConfigManager)
@interface ZARemoteConfigManager ()

@property (atomic, strong) ZARemoteConfigOperator *operator;

@end

@implementation ZARemoteConfigManager

+ (instancetype)defaultManager {
    static dispatch_once_t onceToken;
    static ZARemoteConfigManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[ZARemoteConfigManager alloc] init];
    });
    return manager;
}

- (void)setConfigOptions:(ZAConfigOptions *)configOptions {
    if (za_quick_app_extension()) {
        configOptions.enableRemoteConfig = NO;
    }
    _configOptions = configOptions;
    self.enable = configOptions.enableRemoteConfig;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appLifecycleStateWillChange:) name:kZAAppLifeCycleMonitorDidChangeNotification object:nil];
       
    }
    return self;
}


#pragma mark - NSNotificationAppLifecycle

- (void)appLifecycleStateWillChange:(NSNotification *)sender {
    if (!self.isEnable) {
        return;
    }
    NSDictionary *userInfo = sender.userInfo;
    ZAAppLifeCycleMonitorState newState = [userInfo[kZAAppLifeCycleMonitorNewStateKey] integerValue];
    ZAAppLifeCycleMonitorState oldState = [userInfo[kZAAppLifeCycleMonitorOldStateKey] integerValue];
   
  
    // 热启动
    if (oldState != ZAAppLifeCycleMonitorStateInitiativeStart && newState == ZAAppLifeCycleMonitorStateStart) {
        [self enableLocalRemoteConfig];
        [self tryToRequestRemoteConfig];
        return;
    }

    // 退出
    if (newState == ZAAppLifeCycleMonitorStateEnd) {
        [self cancelRequestRemoteConfig];
    }
}

#pragma mark - ZAModuleProtocol

- (void)setEnable:(BOOL)enable {
   
    if (enable) {
        self.operator = [[ZARemoteConfigCommonOperator alloc] initWithConfigOptions:self.configOptions remoteConfigModel:nil];
        [self tryToRequestRemoteConfig];
    } else {
        self.operator = nil;
    }
}
-(BOOL)isEnable{
    return ZAConfigOptions.sharedInstance.disableSDK ?: ZAConfigOptions.sharedInstance.enableRemoteConfig;
}




#pragma mark - ZAOpenURLProtocol

- (BOOL)canHandleURL:(NSURL *)url {
    return self.isEnable && [url.host isEqualToString:@"zalldataremoteconfig"];
}

- (BOOL)handleURL:(NSURL *)url {
    // 打开 log 用于调试

    [self cancelRequestRemoteConfig];

    if (![self.operator isKindOfClass:[ZARemoteConfigCheckOperator class]]) {
        ZARemoteConfigModel *model = self.operator.model;
        self.operator = [[ZARemoteConfigCheckOperator alloc] initWithConfigOptions:self.configOptions remoteConfigModel:model];
    }

    if ([self.operator respondsToSelector:@selector(handleRemoteConfigURL:)]) {
        return [self.operator handleRemoteConfigURL:url];
    }

    return NO;
}

- (void)cancelRequestRemoteConfig {
    if ([self.operator respondsToSelector:@selector(cancelRequestRemoteConfig)]) {
        [self.operator cancelRequestRemoteConfig];
    }
}

- (void)enableLocalRemoteConfig {
    if ([self.operator respondsToSelector:@selector(enableLocalRemoteConfig)]) {
        [self.operator enableLocalRemoteConfig];
    }
}

- (void)tryToRequestRemoteConfig {
    if ([self.operator respondsToSelector:@selector(tryToRequestRemoteConfig)]) {
        [self.operator tryToRequestRemoteConfig];
    }
}

#pragma mark - ZARemoteConfigModuleProtocol

- (BOOL)isDisableSDK {
    return self.operator.isDisableSDK;
}

- (void)retryRequestRemoteConfigWithForceUpdateFlag:(BOOL)isForceUpdate {
    if ([self.operator respondsToSelector:@selector(retryRequestRemoteConfigWithForceUpdateFlag:)]) {
        [self.operator retryRequestRemoteConfigWithForceUpdateFlag:isForceUpdate];
    }
}

- (BOOL)isIgnoreEventObject:(ZAEventBaseObject *)obj {
    if (obj.isIgnoreRemoteConfig) {
        return NO;
    }

    if (self.operator.isDisableSDK) {
        ZALogDebug(@"【remote config】SDK is disabled");
        return YES;
    }

    if ([self.operator isBlackListContainsEvent:obj.event]) {
        ZALogDebug(@"【remote config】 %@ is ignored by remote config", obj.event);
        return YES;
    }

    return NO;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
