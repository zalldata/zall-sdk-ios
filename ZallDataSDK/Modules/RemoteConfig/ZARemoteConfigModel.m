//
//  ZARemoteConfigModel.m
//  ZallDataSDK
//
// Created by guo on 2020/7/20.
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

#import "ZARemoteConfigModel.h"
#import "ZAUtilCheck.h"
#import "ZAConstantsDefin.h"
#import "ZAQuickUtil.h"
 
@implementation ZARemoteConfigModel

#pragma mark - Life Cycle

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        za_quick_safe_dict(dictionary);
        _originalVersion = dictionary[@"v"];
        _localLibVersion = dictionary[@"localLibVersion"];
        
        NSDictionary *configs = dictionary[@"configs"]?:@{};
        _latestVersion = configs[@"nv"];
        _disableSDK =  [configs[@"disableSDK"] boolValue];
        _disableDebugMode = [configs[@"disableDebugMode"] boolValue];
        _eventBlackList = configs[@"event_blacklist"];
        
        [self setupAutoTrackMode:configs];
        [self setupEffectMode:configs];
    }
    return self;
}

- (void)setupAutoTrackMode:(NSDictionary *)dictionary {
    _autoTrackMode = kZAAutoTrackModeDefault;
    za_quick_safe_dict(dictionary);
    NSNumber *autoTrackMode = dictionary[@"autoTrackMode"];
    if (autoTrackMode) {
        NSInteger remoteAutoTrackMode = autoTrackMode.integerValue;
        if (remoteAutoTrackMode >= kZAAutoTrackModeDefault && remoteAutoTrackMode <= kZAAutoTrackModeEnabledAll) {
            _autoTrackMode = remoteAutoTrackMode;
        }
    }
}

- (void)setupEffectMode:(NSDictionary *)dictionary {
    _effectMode = ZARemoteConfigEffectModeNext;
    za_quick_safe_dict(dictionary);
    NSNumber *effectMode = dictionary[@"effect_mode"];
    if (effectMode && (effectMode.integerValue == 1)) {
        _effectMode = ZARemoteConfigEffectModeNow;
    }
}

#pragma mark - Public Methods

- (NSDictionary *)toDictionary {
    NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithCapacity:3];
    mDic[@"v"] = self.originalVersion;
    mDic[@"localLibVersion"] = self.localLibVersion;
    mDic[@"configs"] = [self configsDictionary];
    return mDic;
}

#pragma mark – Private Methods

- (NSDictionary *)configsDictionary {
    NSMutableDictionary *configs = [NSMutableDictionary dictionaryWithCapacity:6];
    configs[@"nv"] = self.latestVersion;
    configs[@"disableSDK"] = [NSNumber numberWithBool:self.disableSDK];
    configs[@"disableDebugMode"] = [NSNumber numberWithBool:self.disableDebugMode];
    configs[@"event_blacklist"] = self.eventBlackList;
    configs[@"autoTrackMode"] = [NSNumber numberWithInteger:self.autoTrackMode];
    configs[@"effect_mode"] = [NSNumber numberWithInteger:self.effectMode];
    return configs;
}

- (NSString *)description {
    return [[NSString alloc] initWithFormat:@"<%@:%p>, \n v=%@, \n configs=%@, \n localLibVersion=%@", self.class, self, self.originalVersion, [self configsDictionary], self.localLibVersion];
}

@end
