//
// ZallDataSDK+ZAPubic.m
// ZallDataSDK
//
// Created by guo on 2021/12/29.
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

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

#import "ZallDataSDK+ZAPrivate.h"
#import "ZAEventProfileObject.h"
#import "ZAKeyChainItemWrapper.h"

@implementation ZallDataSDK (Business)

 
- (void)setCookie:(NSString *)cookie withEncode:(BOOL)encode{
    [self.network setCookie:cookie isEncoded:encode];

}

 
- (NSString *)getCookieWithDecode:(BOOL)decode{
    return [self.network cookieWithDecoded:decode];
}


- (NSString *)getLastScreenUrl {
    return [ZAReferrerManager sharedInstance].referrerURL;
}


- (NSDictionary *)getPresetProperties{
    return [NSDictionary dictionaryWithDictionary:[self.presetProperty currentPresetProperties]];
}
 
- (void)registerSuperProperties:(NSDictionary *)propertyDict{
    [ZAQueueManage sdkOperationQueueAsync:^{
        [self.superProperty registerSuperProperties:propertyDict];
    }];
    
}
 
- (void)registerDynamicSuperProperties:(NSDictionary<NSString *, id> *(^)(void))dynamicSuperProperties{
    [self.superProperty registerDynamicSuperProperties:dynamicSuperProperties];
}
 
- (void)unregisterSuperProperty:(NSString *)property{
    [ZAQueueManage sdkOperationQueueAsync:^{
        [self.superProperty unregisterSuperProperty:property];
    }];
     

}
 
- (void)clearSuperProperties{
    [ZAQueueManage sdkOperationQueueAsync:^{
        [self.superProperty clearSuperProperties];
    }];
}
 
 
- (NSDictionary *)currentSuperProperties{
    return [self.superProperty currentSuperProperties];
}

 
- (void)login:(NSString *)loginId{
    [self login:loginId withProperties:nil];

}
 
- (NSString *)loginId{
    return self.identifier.loginId;
}

 
- (void)login:(NSString *)loginId withProperties:(NSDictionary * _Nullable )properties{
    ZAEventSignUpTrackObject *object = [[ZAEventSignUpTrackObject alloc] initWithEventId:kZAEventNameSignUp];
    object.dynamicSuperProperties = [self.superProperty acquireDynamicSuperProperties];
    [ZAQueueManage sdkOperationQueueAsync:^{
        if (![self.identifier isValidLoginId:loginId]) {
            return;
        }
        [self.identifier login:loginId];
        [[NSNotificationCenter defaultCenter] postNotificationName:ZA_TRACK_LOGIN_NOTIFICATION object:nil];
        [self trackEventObject:object properties:properties];
    }];
}
 
- (void)logout{
    [ZAQueueManage sdkOperationQueueAsync:^{
        BOOL isLogin = (self.loginId.length > 0);
        // logout 中会将 self.loginId 清除，因此需要在 logout 之前获取当前登录状态
        [self.identifier logout];
        if (isLogin) {
            [[NSNotificationCenter defaultCenter] postNotificationName:ZA_TRACK_LOGOUT_NOTIFICATION object:nil];
        }
    }];
   
}
 
- (NSString *)distinctId{
    return self.identifier.distinctId;
}


- (NSString *)anonymousId{
    return self.identifier.anonymousId;

}

- (void)resetAnonymousId{
    [ZAQueueManage sdkOperationQueueAsync:^{
        NSString *previousAnonymousId = [self.anonymousId copy];
        [self.identifier resetAnonymousId];
        if (self.loginId || [previousAnonymousId isEqualToString:self.anonymousId]) {
            return;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:ZA_TRACK_RESETANONYMOUSID_NOTIFICATION object:nil];
    }];
}

 
- (void)identify:(NSString *)anonymousId{
    [ZAQueueManage sdkOperationQueueAsync:^{
        if (![self.identifier identify:anonymousId]) {
            return;
        }
        // 其他 SDK 接收匿名 ID 修改通知，例如 AB，SF
        if (!self.loginId) {
            [[NSNotificationCenter defaultCenter] postNotificationName:ZA_TRACK_IDENTIFY_NOTIFICATION object:nil];
        }
    }];
   
}

 
- (void)bind:(NSString *)key value:(NSString *)value{
    if (![self.identifier isValidIdentity:key value:value]) {
        return;
    }
    [ZAQueueManage sdkOperationQueueAsync:^{
        [self.identifier bindIdentity:key value:value];
    }];

    ZAEventBindTrackObject *object = [[ZAEventBindTrackObject alloc] initWithEventId:kZAEventNameBind];
    [self asyncTrackEventObject:object properties:nil];
}
 
- (void)unbind:(NSString *)key value:(NSString *)value{
    if (![self.identifier isValidIdentity:key value:value]) {
        return;
    }
    [ZAQueueManage sdkOperationQueueAsync:^{
        [self.identifier unbindIdentity:key value:value];
    }];

    ZAEventUnbindTrackObject *object = [[ZAEventUnbindTrackObject alloc] initWithEventId:kZAEventNameUnbind];
    [self asyncTrackEventObject:object properties:nil];
}


#pragma mark Item
- (void)itemSetWithType:(NSString *)itemType itemId:(NSString *)itemId properties:(nullable NSDictionary <NSString *, id> *)propertyDict{
    NSMutableDictionary *itemDict = [[NSMutableDictionary alloc] init];
    itemDict[kZAEventType] = ZA_EVENT_ITEM_SET;
    itemDict[ZA_EVENT_ITEM_TYPE] = itemType;
    itemDict[ZA_EVENT_ITEM_ID] = itemId;

    [ZAQueueManage sdkOperationQueueAsync:^{
        [self trackItems:itemDict properties:propertyDict];
    }];
}

 
- (void)itemDeleteWithType:(NSString *)itemType itemId:(NSString *)itemId{
    NSMutableDictionary *itemDict = [[NSMutableDictionary alloc] init];
    itemDict[kZAEventType] = ZA_EVENT_ITEM_DELETE;
    itemDict[ZA_EVENT_ITEM_TYPE] = itemType;
    itemDict[ZA_EVENT_ITEM_ID] = itemId;
    
    [ZAQueueManage sdkOperationQueueAsync:^{
        [self trackItems:itemDict properties:nil];
    }];
}
- (void)trackItems:(nullable NSDictionary <NSString *, id> *)itemDict properties:(nullable NSDictionary <NSString *, id> *)propertyDict {

    NSMutableDictionary *itemProperties = [NSMutableDictionary dictionaryWithDictionary:itemDict];
    //item_type 必须为合法变量名
    NSString *itemType = itemProperties[ZA_EVENT_ITEM_TYPE];

    NSError *error = [ZAUtilCheck zaCheckKey:itemType];
  
    if (error) {
        ZALogError(@"%@",error.localizedDescription);
        if (error.code != ZACheckdatorErrorOverflow) {
            itemProperties[ZA_EVENT_ITEM_TYPE] = nil;
        }
    }

    NSString *itemId = itemProperties[ZA_EVENT_ITEM_ID];
    if (![itemId isKindOfClass:[NSString class]]) {
        ZALogError(@"Item_id must be a string");
        itemProperties[ZA_EVENT_ITEM_ID] = nil;
    }

    if ([itemId isKindOfClass:[NSString class]] && itemId.length > kZAPropertyValueMaxLength) {
        ZALogError(@"%@'s length is longer than %ld", itemId, kZAPropertyValueMaxLength);
    }
    
    // 校验 properties
    NSMutableDictionary *propertyMDict = [ZAUtilCheck zaCheckProperties:propertyDict];
    
    // 处理 $project
    id project = propertyMDict[kZAEventCommonOptionalPropertyProject];
    if (project) {
        itemProperties[kZAEventProject] = project;
        [propertyMDict removeObjectForKey:kZAEventCommonOptionalPropertyProject];
    }
    
    if (propertyMDict.count > 0) {
        itemProperties[kZAEventProperties] = propertyMDict;
    }
    
    itemProperties[kZAEventLib] = [self.presetProperty libPropertiesWithLibMethod:kZALibMethodCode];

    NSNumber *timeStamp = @(za_current_system_time());
    itemProperties[kZAEventTime] = timeStamp;

    ZALogDebug(@"\n【track event】:\n%@", itemProperties);

    [self.eventTracker trackEvent:itemProperties];
}


#pragma mark Profile
- (void)profile:(NSString *)type properties:(NSDictionary *)properties {
     
    ZAEventProfileObject *object = [[ZAEventProfileObject alloc] initWithType:type];
    [self asyncTrackEventObject:object properties:properties];
}

- (void)set:(NSDictionary *)profileDict{
    [self profile:ZA_PROFILE_SET properties:profileDict];
}


- (void)setOnce:(NSDictionary *)profileDict{
    [self profile:ZA_PROFILE_SET_ONCE properties:profileDict];

}

- (void)set:(NSString *) profile to:(id)content{
    if (profile && content) {
        [self profile:ZA_PROFILE_SET properties:@{profile: content}];
    }

}


- (void)setOnce:(NSString *) profile to:(id)content{
    if (profile && content) {
        [self profile:ZA_PROFILE_SET_ONCE properties:@{profile: content}];
    }

}

- (void)unset:(NSString *) profile{
    [self profile:ZA_PROFILE_UNSET properties:@{profile: @""}];

}


- (void)increment:(NSString *)profile by:(NSNumber *)amount{
    ZAEventProfileIncrementObject *object = [[ZAEventProfileIncrementObject alloc] initWithType:ZA_PROFILE_INCREMENT];
    [self asyncTrackEventObject:object properties:@{profile: amount}];

}


- (void)increment:(NSDictionary *)profileDict{
    ZAEventProfileIncrementObject *object = [[ZAEventProfileIncrementObject alloc] initWithType:ZA_PROFILE_INCREMENT];
    [self asyncTrackEventObject:object properties:profileDict];

}

- (void)append:(NSString *)profile by:(NSObject<NSFastEnumeration> *)content{
    if (profile && content) {
        if ([content isKindOfClass:[NSSet class]] || [content isKindOfClass:[NSArray class]]) {
            ZAEventProfileAppendObject *object = [[ZAEventProfileAppendObject alloc] initWithType:ZA_PROFILE_APPEND];
            [self asyncTrackEventObject:object properties:@{profile: content}];
        }
    }
}

- (void)deleteUser{
    
    [self profile:ZA_PROFILE_DELETE properties:@{}];
}

- (void)clearKeychainData {
    [ZAKeyChainItemWrapper deletePasswordWithAccount:kZAUdidAccount service:kZAService];
}
- (void)profilePushKey:(NSString *)pushTypeKey pushId:(NSString *)pushId{
    if ([pushTypeKey isKindOfClass:NSString.class] && pushTypeKey.length && [pushId isKindOfClass:NSString.class] && pushId.length) {
        NSString * keyOfPushId = [NSString stringWithFormat:@"za_%@", pushTypeKey];
        NSString * valueOfPushId = [NSUserDefaults.standardUserDefaults valueForKey:keyOfPushId];
        NSString * newValueOfPushId = [NSString stringWithFormat:@"%@_%@", self.distinctId, pushId];
        if (![valueOfPushId isEqualToString:newValueOfPushId]) {
            [self set:@{pushTypeKey:pushId}];
            [NSUserDefaults.standardUserDefaults setValue:newValueOfPushId forKey:keyOfPushId];
        }
    }
}

- (void)profileUnsetPushKey:(NSString *)pushTypeKey{
    NSAssert(([pushTypeKey isKindOfClass:[NSString class]] && pushTypeKey.length), @"pushTypeKey should be a non-empty string object!!!❌❌❌");
    NSString *localKey = [NSString stringWithFormat:@"za_%@", pushTypeKey];
    NSString *localValue = [NSUserDefaults.standardUserDefaults valueForKey:localKey];
    if ([localValue hasPrefix:self.distinctId]) {
        [self unset:pushTypeKey];
        [NSUserDefaults.standardUserDefaults removeObjectForKey:localKey];
    }
}
- (NSDictionary *)getLastScreenTrackProperties {
    return [ZAReferrerManager sharedInstance].referrerProperties;
}


@end
#pragma clang diagnostic pop
