//
// ZallDataSDK+ZATrack.m
// ZallDataSDK
//
// Created by guo on 2021/12/30.
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

#if __has_include("ZAAppExtensionDataManager.h")
#import "ZAAppExtensionDataManager.h"
#endif

@implementation ZallDataSDK (ZATrack)


#pragma mark - trackTimer


- (BOOL)checkEventName:(NSString *)eventName {
    NSError *error = [ZAUtilCheck zaCheckKey:eventName];
    
    if (!error) {
        return YES;
    }
    ZALogError(@"%@", error.localizedDescription);
    if (error.code == ZACheckdatorErrorInvalid || error.code == ZACheckdatorErrorOverflow) {
        return YES;
    }
    return NO;
}

- (nullable NSString *)trackTimerStart:(NSString *)event{
    if (![self checkEventName:event]) {
        return nil;
    }
    NSString *eventId = [self.trackTimer generateEventIdByEventName:event];
    UInt64 currentSysUpTime = za_current_system_time();
    [ZAQueueManage sdkOperationQueueAsync:^{
        [self.trackTimer trackTimerStart:eventId currentSysUpTime:currentSysUpTime];
    }];
    
    
    return eventId;
}

 
- (void)trackTimerEnd:(NSString *)event withProperties:(nullable NSDictionary *)propertyDict{
    ZAEventCustomTrackObject *object = [[ZAEventCustomTrackObject alloc] initWithEventId:event];
    [self asyncTrackEventObject:object properties:propertyDict];

}

 
- (void)trackTimerEnd:(NSString *)event{
    [self trackTimerEnd:event withProperties:nil];
}

 
- (void)trackTimerPause:(NSString *)event{
    if (![self checkEventName:event]) {
        return;
    }
    UInt64 currentSysUpTime = za_current_system_time();
    [ZAQueueManage sdkOperationQueueAsync:^{
        [self.trackTimer trackTimerPause:event currentSysUpTime:currentSysUpTime];
    }];
}

 
- (void)trackTimerResume:(NSString *)event{
    if (![self checkEventName:event]) {
        return;
    }
    UInt64 currentSysUpTime = za_current_system_time();
    [ZAQueueManage sdkOperationQueueAsync:^{
        [self.trackTimer trackTimerResume:event currentSysUpTime:currentSysUpTime];
    }];
}

 
- (void)trackRemoveTimer:(NSString *)event{
    if (![self checkEventName:event]) {
        return;
    }
    [ZAQueueManage sdkOperationQueueAsync:^{
        [self.trackTimer trackTimerRemove:event];
    }];
}
 
- (void)clearTrackTimer{
    [ZAQueueManage sdkOperationQueueAsync:^{
        [self.trackTimer clearAllEventTimers];
    }];
    
}


#pragma mark track event

- (void)trackEventFromExtensionWithGroupIdentifier:(NSString *)groupIdentifier completion:(void (^)(NSString *groupIdentifier, NSArray *events)) completion{
    
    @try {
        if (groupIdentifier == nil || [groupIdentifier isEqualToString:@""]) {
            return;
        }
        id appExtension = za_quick_get_method(@"ZAAppExtensionDataManager", @"sharedInstance");
        if (appExtension) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            NSArray *eventArray = [appExtension performSelector:@selector(readAllEventsWithGroupIdentifier:) withObject:groupIdentifier];
            if (eventArray) {
                for (NSDictionary *dict in eventArray) {
                    ZAEventCustomTrackObject *object = [[ZAEventCustomTrackObject alloc] initWithEventId:dict[kZAEventName]];
                    [self asyncTrackEventObject:object properties:dict[kZAEventProperties]];
                }
                [appExtension performSelector:@selector(deleteEventsWithGroupIdentifier:) withObject:groupIdentifier];
                
                if (completion) {
                    completion(groupIdentifier, eventArray);
                }
            }
#pragma clang diagnostic pop
        }
        
        
 
    } @catch (NSException *exception) {
        ZALogError(@"%@ error: %@", self, exception);
    }

}

 
 

- (void)trackEventObject:(ZAEventBaseObject *)object properties:(NSDictionary *)properties {
 
    // 1. 远程控制校验or本地SDK开关
    if ([ZAModuleManager.sharedInstance isIgnoreEventObject:object] || ZAConfigOptions.sharedInstance.disableSDK) {
        return;
    }

    // 2. 事件名校验
    NSError *error = nil;
    [object validateEventWithError:&error];
    if (error) {
        ZALogError(@"%@", error.localizedDescription);
        [ZAModuleManager.sharedInstance showDebugModeWarning:error.localizedDescription];
    }

    [self.eventTracker trackEventObject:object properties:properties];
   
}

- (void)asyncTrackEventObject:(ZAEventBaseObject *)object properties:(NSDictionary *)properties {
    
    object.dynamicSuperProperties = [self.superProperty acquireDynamicSuperProperties];
    [ZAQueueManage sdkOperationQueueAsync:^{
        [self trackEventObject:object properties:properties];
    }];
  
}

 
- (void)track:(NSString *)event{
    [self track:event withProperties:nil];

}


- (void)track:(NSString *)event withProperties:(nullable NSDictionary *)propertyDict{
    ZAEventCustomTrackObject *object = [[ZAEventCustomTrackObject alloc] initWithEventId:event];
    [self asyncTrackEventObject:object properties:propertyDict];
}

 
- (void)trackEventWillSave:(BOOL (^)(NSString *eventName, NSMutableDictionary<NSString *, id> *properties))willBlock{
    if (!willBlock) {
        return;
    }
    ZALogDebug(@"SDK have set trackEventWillSave");
    [ZAQueueManage sdkOperationQueueAsync:^{
        self.trackEventCallback = willBlock;
    }];
}
 
- (void)trackForceSendAll{
    [ZAQueueManage sdkOperationQueueAsync:^{
        [self.eventTracker trackForceSendAllEventRecords];
    }];
 
}
 
- (void)trackDeleteAll{
    [ZAQueueManage sdkOperationQueueAsync:^{
        [self.eventTracker.eventStore deleteAllRecords];
    }];
    
}


@end
#pragma clang diagnostic pop
