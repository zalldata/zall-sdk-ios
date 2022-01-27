//
// ZAPresetProperty.m
// ZallDataSDK
//
// Created by guo on 2020/5/12.
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

#import "ZAPresetProperty.h"
#import "ZAUtilCheck.h"
#import "ZAIdentifier.h"
#import "ZallDataSDK.h"
#import "ZAQuickUtil.h"
#import "ZAReachability.h"
#import "ZALog.h"
#import "ZAFileStore.h"
#import "ZAConstantsDefin.h"
#import "ZAModuleManager.h"
#import "ZAJSONUtil.h"
#import "ZANetwork.h"
#import "ZAQueueManage.h"

#import "ZAQuickUtil.h"

#pragma mark -

@interface ZAPresetProperty ()

@property (nonatomic, strong) NSMutableDictionary *automaticProperties;
@property (nonatomic, copy) NSString *firstDay;

@end

@implementation ZAPresetProperty

- (instancetype)init
{
    self = [super init];
    if (self) {
        [ZAQueueManage readWriteQueueAsync:^{
            [self unarchiveFirstDay];
        }];
    }
    return self;
}
 
#pragma mark – Public Methods

- (NSDictionary *)libPropertiesWithLibMethod:(NSString *)libMethod {
    NSMutableDictionary *libProperties = [NSMutableDictionary dictionary];
    libProperties[kZAEventPresetPropertyLib] = self.automaticProperties[kZAEventPresetPropertyLib];
    libProperties[kZAEventPresetPropertyLibVersion] = self.automaticProperties[kZAEventPresetPropertyLibVersion];
    libProperties[kZAEventPresetPropertyAppVersion] = self.automaticProperties[kZAEventPresetPropertyAppVersion];
    NSString *method = za_check_empty_string(libMethod) ? kZALibMethodCode :libMethod;
    libProperties[kZAEventPresetPropertyLibMethod] = method;
    return libProperties;
}

- (BOOL)isFirstDay {
 
    NSDateFormatter *dateFormatter = [ZAQuickUtil zaDateFormatter];
    NSString *current = [dateFormatter stringFromDate:[NSDate date]];
 
    return [self.firstDay isEqualToString:current];;
}

- (NSDictionary *)currentNetworkProperties {
    NSString *networkType = [ZANetwork networkTypeString];

    NSMutableDictionary *networkProperties = [NSMutableDictionary dictionary];
    networkProperties[kZAEventPresetPropertyNetworkType] = networkType;
    networkProperties[kZAEventPresetPropertyWifi] = @([networkType isEqualToString:@"WIFI"]);
    return networkProperties;
}

- (NSDictionary *)currentPresetProperties {
    NSMutableDictionary *presetProperties = [NSMutableDictionary dictionary];
    [presetProperties addEntriesFromDictionary:self.automaticProperties];
    [presetProperties addEntriesFromDictionary:[self currentNetworkProperties]];
    presetProperties[kZAEventPresetPropertyIsFirstDay] = @([self isFirstDay]);
    return presetProperties;
}

- (NSString *)appVersion {
    return self.automaticProperties[kZAEventPresetPropertyAppVersion];
}

- (NSString *)deviceID {
    return self.automaticProperties[kZAEventPresetPropertyDeviceId];
}

#pragma mark – Private Methods

- (void)unarchiveFirstDay {
    self.firstDay = [ZAFileStore unarchiveWithFileName:@"first_day"];
    if (!self.firstDay) {
        NSDateFormatter *dateFormatter = [ZAQuickUtil zaDateFormatter];
        self.firstDay = [dateFormatter stringFromDate:[NSDate date]];
        [ZAFileStore archiveWithFileName:@"first_day" value:self.firstDay];
    }
}
 
#pragma mark – Getters and Setters

- (NSMutableDictionary *)automaticProperties {
    if (!_automaticProperties) {
        __block NSMutableDictionary * dic = @{}.mutableCopy;
        dispatch_block_t block = ^{
             
            dic[kZAEventPresetPropertyDeviceId] = [ZAQuickUtil hardwareID];
            dic[ZAEventPresetPropertyModel] = [ZAQuickUtil zaGetDeviceModelArchitecture];
            dic[ZAEventPresetPropertyManufacturer] = @"Apple";

            dic[ZAEventPresetPropertyCarrier] = [ZAQuickUtil zaGetTelecomCompanyName];
            dic[ZAEventPresetPropertyOS] = @"iOS";
            dic[ZAEventPresetPropertyOSVersion] = [[UIDevice currentDevice] systemVersion];
            dic[kZAEventPresetPropertyLib] = @"iOS";

            CGSize size = [UIScreen mainScreen].bounds.size;


            dic[ZAEventPresetPropertyAppID] = [ZAQuickUtil zaGetAppIdentifier];
            dic[ZAEventPresetPropertyAppName] = [ZAQuickUtil zaGetAppName];
            dic[kZAEventPresetPropertyAppVersion] = [ZAQuickUtil zaGetAppShortVersion];

            dic[ZAEventPresetPropertyScreenHeight] = @((NSInteger)size.height);
            dic[ZAEventPresetPropertyScreenWidth] = @((NSInteger)size.width);

            dic[kZAEventPresetPropertyLibVersion] = [ZallDataSDK libVersion];
            // 计算时区偏移（保持和 JS 获取时区偏移的计算结果一致，这里首先获取分钟数，然后取反）
            NSInteger minutesOffsetGMT = - ([[NSTimeZone defaultTimeZone] secondsFromGMT] / 60);
            dic[ZAEventPresetPropertyTimezoneOffset] = @(minutesOffsetGMT);
        };
        [ZAQueueManage readWriteQueueSync:block];
        _automaticProperties = dic;
    }
    return _automaticProperties;
   
 }

@end
