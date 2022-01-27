//
// ZAAppStartTracker.m
// ZallDataSDK
//
// Created by guo on 2021/4/2.
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

#import "ZATrackerAppStart.h"
#import "ZAConstantsDefin.h"
#import "ZallDataSDK+ZAPrivate.h"

// App 启动标记
static NSString * const kZAHasLaunchedOnce = @"HasLaunchedOnce";
// App 首次启动
static NSString * const kZAEventPropertyAppFirstStart = @"$is_first_time";
// App 是否从后台恢复
static NSString * const kZAEventPropertyResumeFromBackground = @"$resume_from_background";

@interface ZATrackerAppStart ()

/// 是否为热启动
@property (nonatomic, assign, getter=isRelaunch) BOOL relaunch;

@end

@implementation ZATrackerAppStart

#pragma mark - Life Cycle

- (instancetype)init {
    self = [super init];
    if (self) {
        _relaunch = NO;
    }
    return self;
}

#pragma mark - Override

- (NSString *)eventId {
    return self.isPassively ? kZAEventNameAppStartPassively : kZAEventNameAppStart;
}

#pragma mark - Public Methods

- (void)autoTrackEventWithProperties:(NSDictionary *)properties {
    if (!self.isIgnored) {
        NSMutableDictionary *eventProperties = [NSMutableDictionary dictionary];
        if (self.isPassively) {
            eventProperties[kZAEventPropertyAppFirstStart] = @([self isFirstAppStart]);
            eventProperties[kZAEventPropertyResumeFromBackground] = @(NO);
        } else {
            eventProperties[kZAEventPropertyAppFirstStart] = self.isRelaunch ? @(NO) : @([self isFirstAppStart]);
            eventProperties[kZAEventPropertyResumeFromBackground] = self.isRelaunch ? @(YES) : @(NO);
        }
        //添加 deeplink 相关渠道信息，可能不存在
        [eventProperties addEntriesFromDictionary:properties];

        [self trackAutoTrackEventWithProperties:eventProperties];

        // 上报启动事件（包括冷启动和热启动）
        if (!self.passively) {
            [ZallDataSDK.sharedInstance trackForceSendAll];
        }
    }

    // 更新首次标记
    [self updateFirstAppStart];

    // 触发过启动事件，下次为热启动
    self.relaunch = YES;
}

#pragma mark – Private Methods

- (BOOL)isFirstAppStart {
    return ![[NSUserDefaults standardUserDefaults] boolForKey:kZAHasLaunchedOnce];
}

- (void)updateFirstAppStart {
    if ([self isFirstAppStart]) {
        NSUserDefaults *standard = [NSUserDefaults standardUserDefaults];
        [standard setBool:YES forKey:kZAHasLaunchedOnce];
        [standard synchronize];
    }
}

@end
