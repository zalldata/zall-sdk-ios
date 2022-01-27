//
// ZAUNUserNotificationCenterDelegateProxy.m
// ZallDataSDK
//
// Created by guo on 2021/1/7.
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

#import "ZAUNUserNotificationCenterDelegateProxy.h"
#import "ZAClassHelper.h"
#import "NSObject+HookProxy.h"
#import "ZAAppPushConstants.h"
#import "ZallDataSDK.h"
#import "ZALog.h"
#import "ZANotificationUtil.h"
#import <objc/message.h>

@implementation ZAUNUserNotificationCenterDelegateProxy

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler  API_AVAILABLE(ios(10.0)){
    SEL selector = @selector(userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:);
    [ZAUNUserNotificationCenterDelegateProxy invokeWithTarget:self selector:selector, center, response, completionHandler];
    [ZAUNUserNotificationCenterDelegateProxy trackEventWithTarget:self notificationCenter:center notificationResponse:response];
}

+ (void)trackEventWithTarget:(NSObject *)target notificationCenter:(UNUserNotificationCenter *)center notificationResponse:(UNNotificationResponse *)response  API_AVAILABLE(ios(10.0)){
    // 当 target 和 delegate 不相等时为消息转发, 此时无需重复采集事件
    if (target != center.delegate) {
        return;
    }
    //track notification
    NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
    UNNotificationRequest *request = response.notification.request;
    BOOL isRemoteNotification = [request.trigger isKindOfClass:[UNPushNotificationTrigger class]];
    if (isRemoteNotification) {
        properties[kZAEventPropertyNotificationChannel] = kZAEventPropertyNotificationChannelApple;
    } else {
        properties[kZAEventPropertyNotificationServiceName] = kZAEventPropertyNotificationServiceNameLocal;
    }
    
    properties[kZAEventPropertyNotificationTitle] = request.content.title;
    properties[kZAEventPropertyNotificationContent] = request.content.body;
    
    NSDictionary *userInfo = request.content.userInfo;
    if (userInfo) {
        [properties addEntriesFromDictionary:[ZANotificationUtil propertiesFromUserInfo:userInfo]];
        if (userInfo[kZAPushServiceKeySF]) {
            properties[kSFMessageTitle] = request.content.title;
            properties[kSFMessageContent] = request.content.body;
        }
    }
    
    [[ZallDataSDK sharedInstance] track:kZAEventNameNotificationClick withProperties:properties];
}

+ (NSSet<NSString *> *)optionalSelectors {
    return [NSSet setWithArray:@[@"userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:"]];
}

@end
