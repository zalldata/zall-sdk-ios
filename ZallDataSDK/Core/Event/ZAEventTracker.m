//
// ZAEventTracker.m
// ZallDataSDK
//
// Created by guo on 2020/6/18.
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

#import "ZAEventTracker.h"
#import "ZAEventFlush.h"
#import "ZAEventStore.h"
#import "ZADatabase.h"
#import "ZANetwork.h"
#import "ZAFileStore.h"
#import "ZAJSONUtil.h"
#import "ZALog.h"
#import "ZAQueueManage.h"
#import "ZAModuleManager.h"
#import "ZAConfigOptions+ZAPrivately.h"
#import "ZallDataSDK+ZAPrivate.h"
#import "ZAUtilCheck.h"
#import "ZAReferrerManager.h"
#import "ZAConstantsDefin.h"


static NSInteger kZAFlushMaxRepeatCount = 100;

@interface ZAEventTracker ()

@property (nonatomic, strong) ZAEventStore *eventStore;

@property (nonatomic, strong) ZAEventFlush *eventFlush;

@end

@implementation ZAEventTracker

- (instancetype)init
{
    self = [super init];
    if (self) {
        [ZAQueueManage sdkOperationQueueAsync:^{
            self.eventStore = [[ZAEventStore alloc] initWithFilePath:[ZAFileStore filePath:@"tracker_message" withType:@"db"]];
            self.eventFlush = [[ZAEventFlush alloc] init];
        }];
        
    }
    return self;
}
 
- (void)trackEvent:(NSDictionary *)event {
    [self trackEvent:event isSignUp:NO];
}

/// 事件入库
/// 注意: SF 和 A/B Testing 会 Hook 该方法修改 distinct_id, 因此该方法不能被修改
/// @param event 事件信息
/// @param isSignUp 是否是用户关联事件, 用户关联事件会触发 flush
- (void)trackEvent:(NSDictionary *)event isSignUp:(BOOL)isSignUp {
   
    ZAEventRecord *record = [[ZAEventRecord alloc] initWithEvent:event type:@"POST"];
    // 尝试加密
    NSDictionary *obj = [ZAModuleManager.sharedInstance encryptJSONObject:record.event];
    [record setSecretObject:obj];

    [self.eventStore insertRecord:record];

    // $SignUp 事件或者本地缓存的数据是超过 flushBulkSize
    if (isSignUp || self.eventStore.count > ZAConfigOptions.sharedInstance.sendMaxSize || ZAModuleManager.sharedInstance.isDebugMode) {
        // 添加异步队列任务，保证数据继续入库
        [ZAQueueManage sdkOperationQueueAsync:^{
            [self trackForceSendAllEventRecords];
        }];
        
    }
}

- (BOOL)canFlush {
    // serverURL 是否有效
    if (ZAConfigOptions.sharedInstance.serverURL.length == 0) {
        return NO;
    }
    // 判断当前网络类型是否符合同步数据的网络策略
    if (!([ZANetwork networkTypeOptions] & ZAConfigOptions.sharedInstance.sendNetworkPolicy)) {
        return NO;
    }
    return YES;
}

/// 筛选加密数据，并对未加密的数据尝试加密
/// 即使未开启加密，也可以进行筛选，可能存在加密开关的情况
/// @param records 数据
- (NSArray<ZAEventRecord *> *)encryptEventRecords:(NSArray<ZAEventRecord *> *)records {
    NSMutableArray *encryptRecords = [NSMutableArray arrayWithCapacity:records.count];
    for (ZAEventRecord *record in records) {
        if (record.isEncrypted) {
            [encryptRecords addObject:record];
        } else {
            // 缓存数据未加密，再加密
            NSDictionary *obj = [ZAModuleManager.sharedInstance encryptJSONObject:record.event];
            if (obj) {
                [record setSecretObject:obj];
                [encryptRecords addObject:record];
            }
        }
    }
    return encryptRecords.count == 0 ? records : encryptRecords;
}

- (void)trackForceSendAllEventRecords {
    [self trackForceSendAllEventRecordsWithCompletion:nil];
}

- (void)trackForceSendAllEventRecordsWithCompletion:(void(^)(void))completion {
    if (![self canFlush]) {
        if (completion) {
            completion();
        }
        return;
    }
    [self flushRecordsWithSize:ZAModuleManager.sharedInstance.isDebugMode ? 1 : 50 repeatCount:kZAFlushMaxRepeatCount completion:completion];
}

- (void)flushRecordsWithSize:(NSUInteger)size repeatCount:(NSInteger)repeatCount completion:(void(^)(void))completion {
    // 防止在数据量过大时, 递归 flush, 导致堆栈溢出崩溃; 因此需要限制递归次数
    if (repeatCount <= 0) {
        if (completion) {
            completion();
        }
        return;
    }
    // 从数据库中查询数据
    NSArray<ZAEventRecord *> *records = [self.eventStore selectRecords:size];
    if (records.count == 0) {
        if (completion) {
            completion();
        }
        return;
    }

    // 尝试加密，筛选加密数据
    NSArray<ZAEventRecord *> *encryptRecords = [self encryptEventRecords:records];

    // 获取查询到的数据的 id
    NSMutableArray *recordIDs = [NSMutableArray arrayWithCapacity:encryptRecords.count];
    for (ZAEventRecord *record in encryptRecords) {
        [recordIDs addObject:record.recordID];
    }

    // 更新数据状态
    [self.eventStore updateRecords:recordIDs status:ZAEventRecordStatusFlush];

    // flush
    __weak typeof(self) weakSelf = self;
    [self.eventFlush flushEventRecords:encryptRecords completion:^(BOOL success) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        void(^block)(void) = ^ {
            if (!success) {
                [strongSelf.eventStore updateRecords:recordIDs status:ZAEventRecordStatusNone];
                if (completion) {
                    completion();
                }
                return;
            }
            // 5. 删除数据
            if ([strongSelf.eventStore deleteRecords:recordIDs]) {
                [strongSelf flushRecordsWithSize:size repeatCount:repeatCount - 1 completion:completion];
            }
        };
        [ZAQueueManage sdkOperationQueueSync:block];
    }];
}
- (void)trackEventObject:(ZAEventBaseObject *)object properties:(NSDictionary *)properties{
    // 1. 远程控制校验
    if ([ZAModuleManager.sharedInstance isIgnoreEventObject:object]) {
        return;
    }

    // 2. 事件名校验
    NSError *error = nil;
    [object validateEventWithError:&error];
    if (error) {
        ZALogError(@"%@", error.localizedDescription);
        [ZAModuleManager.sharedInstance showDebugModeWarning:error.localizedDescription];
    }
    
    
    ZallDataSDK * sdk = ZallDataSDK.sharedInstance;
    // 3. 设置用户关联信息
    NSString *anonymousId = sdk.anonymousId;
    object.distinctId = sdk.distinctId;
    object.loginId = sdk.loginId;
    object.anonymousId = anonymousId;
    object.originalId = anonymousId;
    object.identities = [sdk.identifier identitiesWithEventType:object.type];

    // 4. 添加属性
    [object addEventProperties:sdk.presetProperty.automaticProperties];
    [object addSuperProperties:sdk.superProperty.currentSuperProperties];
    [object addEventProperties:object.dynamicSuperProperties];
    [object addEventProperties:sdk.presetProperty.currentNetworkProperties];
    NSNumber *eventDuration = [sdk.trackTimer eventDurationFromEventId:object.eventId currentSysUpTime:object.currentSystemUpTime];
    [object addDurationProperty:eventDuration];
    [object addLatestUtmProperties:ZAModuleManager.sharedInstance.latestUtmProperties];
    [object addChannelProperties:[ZAModuleManager.sharedInstance channelInfoWithEvent:object.event]];

    [object addReferrerTitleProperty:[ZAReferrerManager sharedInstance].referrerTitle];

    // 5. 添加的自定义属性需要校验
    [object addCustomProperties:properties];
    [object addModuleProperties:@{kZAEventPresetPropertyIsFirstDay: @(sdk.presetProperty.isFirstDay)}];
    [object addModuleProperties:ZAModuleManager.sharedInstance.properties];
    // 公共属性, 动态公共属性, 自定义属性不允许修改 $device_id 属性, 因此需要将修正逻操作放在所有属性添加后
    [object correctDeviceID:sdk.presetProperty.deviceID];

    // 6. trackEventCallback 接口调用
    if (![self willEnqueueWithObject:object]) {
        return;
    }

    // 7. 发送通知 & 事件采集
    NSDictionary *result = [object jsonObject];
    za_quick_post_observer(ZA_TRACK_EVENT_NOTIFICATION, nil, result);
    [self trackEvent:result isSignUp:object.isSignUp];
    ZALogDebug(@"\n【track event】:\n%@", result);
}

- (BOOL)willEnqueueWithObject:(ZAEventBaseObject *)obj {
    ZallDataSDK * sdk = ZallDataSDK.sharedInstance;
    NSString *eventName = obj.event;
    if (!sdk.trackEventCallback || za_check_empty_string(eventName)) {
        return YES;
    }
    BOOL willEnque = sdk.trackEventCallback(eventName, obj.properties);
    if (!willEnque) {
        ZALogDebug(@"\n【track event】: %@ can not enter database.", eventName);
        return NO;
    }
    // 校验 properties
    obj.properties = [ZAUtilCheck zaCheckProperties:obj.properties];;
    return YES;
}

- (void)trackFromH5WithEvent:(NSString *)eventInfo enableVerify:(BOOL)enableVerify{
     ZallDataSDK * sdk = ZallDataSDK.sharedInstance;
      NSMutableDictionary *eventDict = [ZAJSONUtil JSONObjectWithString:eventInfo options:NSJSONReadingMutableContainers];
     if (!eventDict) {
         return;
     }

     if (enableVerify) {
         NSString *serverUrl = eventDict[@"server_url"];
         if (![sdk.network isSameProjectWithURLString:serverUrl]) {
             ZALogError(@"Server_url verified faild, Web event lost! Web server_url = '%@'", serverUrl);
             return;
         }
     }
     [ZAQueueManage sdkOperationQueueAsync:^{
         NSString *type = eventDict[kZAEventType];
         NSMutableDictionary *propertiesDict = eventDict[kZAEventProperties];

         if ([type isEqualToString:kZAEventTypeSignup]) {
             eventDict[@"original_id"] = sdk.anonymousId;
         } else {
             eventDict[kZAEventDistinctId] = sdk.distinctId;
         }
         eventDict[kZAEventTrackId] = @(arc4random());

         NSMutableDictionary *libMDic = eventDict[kZAEventLib];
         //update lib $app_version from super properties
         NSDictionary *superProperties = [sdk.superProperty currentSuperProperties];
         id appVersion = superProperties[kZAEventPresetPropertyAppVersion] ? : sdk.presetProperty.appVersion;
         if (appVersion) {
             libMDic[kZAEventPresetPropertyAppVersion] = appVersion;
         }

         NSMutableDictionary *automaticPropertiesCopy = [NSMutableDictionary dictionaryWithDictionary:sdk.presetProperty.automaticProperties];
         [automaticPropertiesCopy removeObjectForKey:kZAEventPresetPropertyLib];
         [automaticPropertiesCopy removeObjectForKey:kZAEventPresetPropertyLibVersion];

         BOOL isTrackEvent = [type isEqualToString:kZAEventTypeTrack] || [type isEqualToString:kZAEventTypeSignup] || [type isEqualToString:kZAEventTypeBind] || [type isEqualToString:kZAEventTypeUnbind];
         if (isTrackEvent) {
             // track / track_signup 类型的请求，还是要加上各种公共property
             // 这里注意下顺序，按照优先级从低到高，依次是automaticProperties, superProperties,dynamicSuperPropertiesDict,propertieDict
             [propertiesDict addEntriesFromDictionary:automaticPropertiesCopy];

             NSDictionary *dynamicSuperPropertiesDict = [sdk.superProperty acquireDynamicSuperProperties];
             [propertiesDict addEntriesFromDictionary:sdk.superProperty.currentSuperProperties];
             [propertiesDict addEntriesFromDictionary:dynamicSuperPropertiesDict];

             // 每次 track 时手机网络状态
             [propertiesDict addEntriesFromDictionary:[sdk.presetProperty currentNetworkProperties]];
         }

         NSString *visualProperties = eventDict[kZAEventProperties][@"zalldata_app_visual_properties"];
         // 是否包含自定义属性配置
         if (!visualProperties || ![eventDict[kZAEventName] isEqualToString:kZAEventNameWebClick]) {
             eventDict[kZAEventProperties] = propertiesDict;
             [self trackFromH5WithEventDict:eventDict];
             return;
         }

         NSData *data = [[NSData alloc] initWithBase64EncodedString:visualProperties options:NSDataBase64DecodingIgnoreUnknownCharacters];
         NSArray <NSDictionary *> *visualPropertyConfigs = [ZAJSONUtil JSONObjectWithData:data];

         // 查询 App 自定义属性值
         NSDate *currentTime = [NSDate date];
         [ZAModuleManager.sharedInstance queryVisualPropertiesWithConfigs:visualPropertyConfigs completionHandler:^(NSDictionary *_Nullable properties) {

             // 切换到 serialQueue 执行
             [ZAQueueManage sdkOperationQueueAsync:^{
                 if (properties.count > 0) {
                     [propertiesDict addEntriesFromDictionary:properties];
                 }

                 // 设置 $time，自定义时间，防止事件序列错误
                 if (!propertiesDict[kZAEventCommonOptionalPropertyTime]) {
                     propertiesDict[kZAEventCommonOptionalPropertyTime] = currentTime;
                 }
                 propertiesDict[@"zalldata_app_visual_properties"] = nil;
                 eventDict[kZAEventProperties] = propertiesDict;
                 [self trackFromH5WithEventDict:eventDict];
             }];
         }];
     }];
 }

 - (void)trackFromH5WithEventDict:(NSMutableDictionary *)eventDict {
     ZallDataSDK * sdk = ZallDataSDK.sharedInstance;
     NSNumber *timeStamp = @(za_current_system_time());
     NSString *type = eventDict[kZAEventType];
     @try {
         // 校验 properties
         NSMutableDictionary *propertiesDict = [ZAUtilCheck zaCheckProperties:eventDict[kZAEventProperties]];
         
         [eventDict removeObjectForKey:@"_nocache"];
         [eventDict removeObjectForKey:@"server_url"];
         
         if (([type isEqualToString:kZAEventTypeTrack] || [type isEqualToString:kZAEventTypeSignup])) {
             //  是否首日访问
             if ([type isEqualToString:kZAEventTypeTrack]) {
                 propertiesDict[kZAEventPresetPropertyIsFirstDay] = @([sdk.presetProperty isFirstDay]);
             }
             [propertiesDict removeObjectForKey:@"_nocache"];

             // 添加 DeepLink 来源渠道参数。优先级最高，覆盖 H5 传过来的同名字段
             [propertiesDict addEntriesFromDictionary:ZAModuleManager.sharedInstance.latestUtmProperties];
         }

         // $project & $token
         NSString *project = propertiesDict[kZAEventCommonOptionalPropertyProject];
         NSString *token = propertiesDict[kZAEventCommonOptionalPropertyToken];
         id timeNumber = propertiesDict[kZAEventCommonOptionalPropertyTime];

         if (project) {
             [propertiesDict removeObjectForKey:kZAEventCommonOptionalPropertyProject];
             eventDict[kZAEventProject] = project;
         }
         if (token) {
             [propertiesDict removeObjectForKey:kZAEventCommonOptionalPropertyToken];
             eventDict[kZAEventToken] = token;
         }
         if (timeNumber) {     //包含 $time
             NSNumber *customTime = nil;
             if ([timeNumber isKindOfClass:[NSDate class]]) {
                 customTime = @([(NSDate *)timeNumber timeIntervalSince1970] * 1000);
             } else if ([timeNumber isKindOfClass:[NSNumber class]]) {
                 customTime = timeNumber;
             }

             if (!customTime) {
                 ZALogError(@"H5 $time '%@' invalid，Please check the value", timeNumber);
             } else if ([customTime compare:@(kZAEventCommonOptionalPropertyTimeInt)] == NSOrderedAscending) {
                 ZALogError(@"H5 $time error %@，Please check the value", timeNumber);
             } else {
                 timeStamp = @([customTime unsignedLongLongValue]);
             }
             [propertiesDict removeObjectForKey:kZAEventCommonOptionalPropertyTime];
         }

         eventDict[kZAEventProperties] = propertiesDict;
         eventDict[kZAEventTime] = timeStamp;

         //JS SDK Data add _hybrid_h5 flag
         eventDict[kZAEventHybridH5] = @(YES);

         NSMutableDictionary *enqueueEvent = [[self willEnqueueWithType:type andEvent:eventDict] mutableCopy];

         if (!enqueueEvent) {
             return;
         }
         // 只有当本地 loginId 不为空时才覆盖 H5 数据
         if (sdk.loginId) {
             enqueueEvent[kZAEventLoginId] = sdk.loginId;
         }
         enqueueEvent[kZAEventAnonymousId] = sdk.anonymousId;

         NSDictionary *identities = enqueueEvent[kZAEventIdentities];

         dispatch_block_t trackBlock = ^{
             // 先设置 loginId 后再设置 identities。identities 对 loginId 有依赖
             enqueueEvent[kZAEventIdentities] = [sdk.identifier mergeH5Identities:identities eventType:type];
             [[NSNotificationCenter defaultCenter] postNotificationName:ZA_TRACK_EVENT_H5_NOTIFICATION object:nil userInfo:[enqueueEvent copy]];
             [self trackEvent:enqueueEvent isSignUp:YES];
             ZALogDebug(@"\n【track event from H5】:\n%@", enqueueEvent);
             [[NSNotificationCenter defaultCenter] postNotificationName:ZA_TRACK_LOGIN_NOTIFICATION object:nil];
         };

         void(^loginBlock)(NSString *)  = ^(NSString *newLoginId){
             if ([sdk.identifier isValidLoginId:newLoginId]) {
                 [sdk.identifier login:newLoginId];
                 enqueueEvent[kZAEventLoginId] = newLoginId;
                 trackBlock();
             }
         };

         if([type isEqualToString:kZAEventTypeSignup]) {
             if (identities) {
                 
                 NSString *newLoginId = identities[ZAConfigOptions.sharedInstance.loginIDKey];
                 if (newLoginId) {
                     // 当可以从 identities 中获取到登录 ID 时正常处理登录逻辑
                     loginBlock(newLoginId);
                 } else {
                     // 当 identities 中无法获取到登录 ID 时，只触发事件不进行 loginId 处理
                     // 场景示例 ：H5 和 App 端自定义 loginIDKey 不一致
                     trackBlock();
                 }
             } else {
                 // 2.0 版本逻辑，保持不变
                 loginBlock(eventDict[kZAEventDistinctId]);
             }
         } else {
             // 打通场景下，除登录事件外其他事件
             enqueueEvent[kZAEventIdentities] = [sdk.identifier mergeH5Identities:identities eventType:type];
             eventDict[kZAEventIdentities] = [sdk.identifier mergeH5Identities:identities eventType:type];

             [[NSNotificationCenter defaultCenter] postNotificationName:ZA_TRACK_EVENT_H5_NOTIFICATION object:nil userInfo:[enqueueEvent copy]];

             eventDict[kZAEventProperties][@"zalldata_web_visual_eventName"] = nil;
             [self trackEvent:enqueueEvent];
             ZALogDebug(@"\n【track event from H5】:\n%@", enqueueEvent);
         }
     } @catch (NSException *exception) {
         ZALogError(@"%@: %@", self, exception);
     }
 }

- (NSDictionary<NSString *, id> *)willEnqueueWithType:(NSString *)type andEvent:(NSDictionary *)event {
    ZallDataSDK * sdk = ZallDataSDK.sharedInstance;
    if (!sdk.trackEventCallback || !event[@"event"]) {
        return [event copy];
    }
    NSMutableDictionary *mevent = [event mutableCopy];
    NSMutableDictionary<NSString *, id> *originProperties = mevent[@"properties"];
    BOOL isIncluded = sdk.trackEventCallback(mevent[@"event"], originProperties);
    if (!isIncluded) {
        ZALogDebug(@"\n【track event】: %@ can not enter database.", mevent[@"event"]);
        return nil;
    }
    // 校验 properties
    NSDictionary *validProperties = [ZAUtilCheck zaCheckProperties:originProperties];
    mevent[@"properties"] = validProperties;
    return mevent;
}


@end
