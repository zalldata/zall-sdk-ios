//
// ZABaseEventObject.m
// ZallDataSDK
//
// Created by guo on 2021/4/13.
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

#import "ZAEventBaseObject.h"
#import "ZAPresetProperty.h"
#import "ZALog.h"
#import "ZAEventLibObject.h"
#import "ZAConstantsDefin.h"
#import "ZAUtilCheck.h"
#import "ZAQuickUtil.h"


@implementation ZAEventBaseObject

- (instancetype)init {
    self = [super init];
    if (self) {
        _lib = [[ZAEventLibObject alloc] init];
        _timeStamp = za_current_time();
        _trackId = @(arc4random());
        _properties = [NSMutableDictionary dictionary];
        _currentSystemUpTime = za_current_system_time();
        
        _ignoreRemoteConfig = NO;
    }
    return self;
}

- (NSString *)event {
    if (![self.eventId hasSuffix:kZAEventIdSuffix]) {
        return self.eventId;
    }
    //eventId 结构为 {eventName}_D3AC265B_3CC2_4C45_B8F0_3E05A83A9DAE_ZATimer，新增后缀长度为 44
    NSString *eventName = [self.eventId substringToIndex:(self.eventId.length - 1) - 44];
    return eventName;
}

- (BOOL)isSignUp {
    return NO;
}

- (void)validateEventWithError:(NSError **)error {
}

- (NSMutableDictionary *)jsonObject {
    NSMutableDictionary *eventInfo = [NSMutableDictionary dictionary];
    eventInfo[kZAEventProperties] = self.properties;
    eventInfo[kZAEventDistinctId] = self.distinctId;
    eventInfo[kZAEventLoginId] = self.loginId;
    eventInfo[kZAEventAnonymousId] = self.anonymousId;
    eventInfo[kZAEventType] = self.type;
    eventInfo[kZAEventTime] = @(self.timeStamp);
    eventInfo[kZAEventLib] = [self.lib jsonObject];
    eventInfo[kZAEventTrackId] = self.trackId;
    eventInfo[kZAEventName] = self.event;
    eventInfo[kZAEventProject] = self.project;
    eventInfo[kZAEventToken] = self.token;
    eventInfo[kZAEventIdentities] = self.identities;
    return eventInfo;
}

#pragma makr - ZAEventBuildStrategy
- (void)addEventProperties:(NSDictionary *)properties {
}

- (void)addLatestUtmProperties:(NSDictionary *)properties {
}

- (void)addChannelProperties:(NSDictionary *)properties {
    
}

- (void)addModuleProperties:(NSDictionary *)properties {
}

- (void)addSuperProperties:(NSDictionary *)properties {
}

- (void)addCustomProperties:(NSDictionary *)properties {
    properties = [ZAUtilCheck zaCheckProperties:properties];
    if (!properties) {
        return;
    }

    [self.properties addEntriesFromDictionary:properties];
    
    // 事件、公共属性和动态公共属性都需要支持修改 $project, $token, $time
    self.project = (NSString *)self.properties[kZAEventCommonOptionalPropertyProject];
    self.token = (NSString *)self.properties[kZAEventCommonOptionalPropertyToken];
    id originalTime = self.properties[kZAEventCommonOptionalPropertyTime];
    if ([originalTime isKindOfClass:NSDate.class]) {
        NSDate *customTime = (NSDate *)originalTime;
        int64_t customTimeInt = [customTime timeIntervalSince1970] * 1000;
        if (customTimeInt >= kZAEventCommonOptionalPropertyTimeInt) {
            self.timeStamp = customTimeInt;
        } else {
            ZALogError(@"$time error %lld, Please check the value", customTimeInt);
        }
    } else if (originalTime) {
        ZALogError(@"$time '%@' invalid, Please check the value", originalTime);
    }
    
    // $project, $token, $time 处理完毕后需要移除
    NSArray<NSString *> *needRemoveKeys = @[kZAEventCommonOptionalPropertyProject,
                                            kZAEventCommonOptionalPropertyToken,
                                            kZAEventCommonOptionalPropertyTime];
    [self.properties removeObjectsForKeys:needRemoveKeys];
}

- (void)addReferrerTitleProperty:(NSString *)referrerTitle {
}

- (void)addDurationProperty:(NSNumber *)duration {
}

- (void)correctDeviceID:(NSString *)deviceID {
    // 修正 $device_id
    // 1. 公共属性, 动态公共属性, 自定义属性不允许修改 $device_id
    // 2. trackEventCallback 可以修改 $device_id
    // 3. profile 操作中若传入 $device_id, 也需要进行修正
    if (self.properties[kZAEventPresetPropertyDeviceId] && deviceID) {
        self.properties[kZAEventPresetPropertyDeviceId] = deviceID;
    }
}



@end
