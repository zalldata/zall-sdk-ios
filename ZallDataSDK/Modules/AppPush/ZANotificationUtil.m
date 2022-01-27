//
// ZANotificationUtil.m
// ZallDataSDK
//
// Created by guo on 2021/1/18.
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

#import "ZANotificationUtil.h"
#import "ZAAppPushConstants.h"
#import "ZAJSONUtil.h"
#import "ZALog.h"

@implementation ZANotificationUtil

+ (NSDictionary *)propertiesFromUserInfo:(NSDictionary *)userInfo {
    
    NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
    
    if (userInfo[kZAPushServiceKeyJPUSH]) {
        properties[kZAEventPropertyNotificationServiceName] = kZAEventPropertyNotificationServiceNameJPUSH;
    }
    
    if (userInfo[kZAPushServiceKeyGeTui]) {
        properties[kZAEventPropertyNotificationServiceName] = kZAEventPropertyNotificationServiceNameGeTui;
    }
    
    //SF related properties
    NSString *sfDataString = userInfo[kZAPushServiceKeySF];
    
    if ([sfDataString isKindOfClass:[NSString class]]) {

        NSDictionary *sfProperties = [ZAJSONUtil JSONObjectWithString:sfDataString];
        if ([sfProperties isKindOfClass:[NSDictionary class]]) {
            [properties addEntriesFromDictionary:[self propertiesFromSFData:sfProperties]];
        }
    }
    
    return [properties copy];
}

+ (NSDictionary *)propertiesFromSFData:(NSDictionary *)sfData {
    NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
    properties[kSFPlanStrategyID] = sfData[kSFPlanStrategyID.zalldata_sfPushKey];
    properties[kSFChannelCategory] = sfData[kSFChannelCategory.zalldata_sfPushKey];
    properties[kSFAudienceID] = sfData[kSFAudienceID.zalldata_sfPushKey];
    properties[kSFChannelID] = sfData[kSFChannelID.zalldata_sfPushKey];
    properties[kSFLinkUrl] = sfData[kSFLinkUrl.zalldata_sfPushKey];
    properties[kSFPlanType] = sfData[kSFPlanType.zalldata_sfPushKey];
    properties[kSFChannelServiceName] = sfData[kSFChannelServiceName.zalldata_sfPushKey];
    properties[kSFMessageID] = sfData[kSFMessageID.zalldata_sfPushKey];
    properties[kSFPlanID] = sfData[kSFPlanID.zalldata_sfPushKey];
    properties[kSFStrategyUnitID] = sfData[kSFStrategyUnitID.zalldata_sfPushKey];
    properties[kSFEnterPlanTime] = sfData[kSFEnterPlanTime.zalldata_sfPushKey];
    return [properties copy];
}

@end

@implementation NSString (SFPushKey)

- (NSString *)zalldata_sfPushKey {
    NSString *prefix = @"$";
    if ([self hasPrefix:prefix]) {
        return [self substringFromIndex:[prefix length]];
    }
    return self;
}

@end
