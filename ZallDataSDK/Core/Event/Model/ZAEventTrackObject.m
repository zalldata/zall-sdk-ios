//
// ZATrackEventObject.m
// ZallDataSDK
//
// Created by guo on 2021/4/6.
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

#import "ZAEventTrackObject.h"
#import "ZAPresetProperty.h"
#import "ZALog.h"
#import "ZAUtilCheck.h"
#import "ZAConstantsDefin.h"

@implementation ZAEventTrackObject

- (instancetype)initWithEventId:(NSString *)eventId {
    self = [super init];
    if (self) {
        self.eventId = eventId && ![eventId isKindOfClass:[NSString class]] ? [NSString stringWithFormat:@"%@", eventId] : eventId;
    }
    return self;
}

- (void)validateEventWithError:(NSError **)error {
    *error = [ZAUtilCheck zaCheckKey:self.eventId];
}

#pragma makr - ZAEventBuildStrategy
- (void)addEventProperties:(NSDictionary *)properties {
    [self.properties addEntriesFromDictionary:properties];
}

- (void)addLatestUtmProperties:(NSDictionary *)properties {
    [self.properties addEntriesFromDictionary:properties];
}

- (void)addModuleProperties:(NSDictionary *)properties {
    [self.properties addEntriesFromDictionary:properties];
}

- (void)addSuperProperties:(NSDictionary *)properties {
    [self.properties addEntriesFromDictionary:properties];
    // 从公共属性中更新 lib 节点中的 $app_version 值
    id appVersion = properties[kZAEventPresetPropertyAppVersion];
    if (appVersion) {
        self.lib.appVersion = appVersion;
    }
}

- (void)addCustomProperties:(NSDictionary *)properties {
    [super addCustomProperties:properties];
    
    // 如果传入自定义属性中的 $lib_method 为 String 类型，需要进行修正处理
    id libMethod = self.properties[kZAEventPresetPropertyLibMethod];
    if (!libMethod || [libMethod isKindOfClass:NSString.class]) {
        if (![libMethod isEqualToString:kZALibMethodCode] &&
            ![libMethod isEqualToString:kZALibMethodAuto]) {
            libMethod = kZALibMethodCode;
        }
    }
    self.properties[kZAEventPresetPropertyLibMethod] = libMethod;
    self.lib.method = libMethod;
}

- (void)addReferrerTitleProperty:(NSString *)referrerTitle {
    self.properties[kZAEeventPropertyReferrerTitle] = referrerTitle;
}

- (void)addDurationProperty:(NSNumber *)duration {
    if (duration) {
        self.properties[@"event_duration"] = duration;
    }
}

@end

@implementation ZAEventSignUpTrackObject

- (instancetype)initWithEventId:(NSString *)eventId {
    self = [super initWithEventId:eventId];
    if (self) {
        self.type = kZAEventTypeSignup;
    }
    return self;
}

- (NSMutableDictionary *)jsonObject {
    NSMutableDictionary *jsonObject = [super jsonObject];
    jsonObject[@"original_id"] = self.originalId;
    return jsonObject;
}

- (BOOL)isSignUp {
    return YES;
}

// $SignUp 事件不添加该属性
- (void)addModuleProperties:(NSDictionary *)properties {
}

@end

@implementation ZAEventCustomTrackObject

- (instancetype)initWithEventId:(NSString *)eventId {
    self = [super initWithEventId:eventId];
    if (self) {
        self.type = kZAEventTypeTrack;
    }
    return self;
}

- (void)addChannelProperties:(NSDictionary *)properties {
    if (!za_check_empty_dict(properties)) {    
        [self.properties addEntriesFromDictionary:properties];
    }
}

@end

@implementation ZAEventAutoTrackObject

- (instancetype)initWithEventId:(NSString *)eventId {
    self = [super initWithEventId:eventId];
    if (self) {
        self.type = kZAEventTypeTrack;
    }
    return self;
}

- (void)addCustomProperties:(NSDictionary *)properties {
    [super addCustomProperties:properties];
    self.properties[kZAEventPresetPropertyLibMethod] = kZALibMethodAuto;
    self.lib.method = kZALibMethodAuto;

    // 不考虑 $AppClick 或者 $AppViewScreen 的计时采集，所以这里的 event 不会出现是 trackTimerStart 返回值的情况
    // 仅在全埋点的元素点击和页面浏览事件中添加 $lib_detail
    BOOL isAppClick = [self.eventId isEqualToString:kZAEventNameAppClick];
    BOOL isViewScreen = [self.eventId isEqualToString:kZAEventNameAppViewScreen];
    if (isAppClick || isViewScreen) {
        self.lib.detail = [NSString stringWithFormat:@"%@######", properties[kZAEventPropertyScreenName] ?: @""];
    }
}



@end

@implementation ZAEventPresetTrackObject

- (instancetype)initWithEventId:(NSString *)eventId {
    self = [super initWithEventId:eventId];
    if (self) {
        self.type = kZAEventTypeTrack;
    }
    return self;
}

@end

/// 绑定 ID 事件
@implementation ZAEventBindTrackObject

- (instancetype)initWithEventId:(NSString *)eventId {
    self = [super initWithEventId:eventId];
    if (self) {
        self.type = kZAEventTypeBind;
    }
    return self;
}

@end

/// 解绑 ID 事件
@implementation ZAEventUnbindTrackObject

- (instancetype)initWithEventId:(NSString *)eventId {
    self = [super initWithEventId:eventId];
    if (self) {
        self.type = kZAEventTypeUnbind;
    }
    return self;
}

@end
