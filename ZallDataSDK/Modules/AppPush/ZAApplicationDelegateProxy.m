//
// ZAApplicationDelegateProxy.m
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

#import "ZAApplicationDelegateProxy.h"
#import "ZAClassHelper.h"
#import "NSObject+HookProxy.h"
#import "UIApplication+PushClick.h"
#import "ZallDataSDK.h"
#import "ZAAppPushConstants.h"
#import "ZALog.h"
#import "ZANotificationUtil.h"
#import <objc/message.h>

@implementation ZAApplicationDelegateProxy

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    SEL selector = @selector(application:didReceiveRemoteNotification:fetchCompletionHandler:);
    [ZAApplicationDelegateProxy invokeWithTarget:self selector:selector, application, userInfo, completionHandler];
    [ZAApplicationDelegateProxy trackEventWithTarget:self application:application remoteNotification:userInfo];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    SEL selector = @selector(application:didReceiveLocalNotification:);
    [ZAApplicationDelegateProxy invokeWithTarget:self selector:selector, application, notification];
    [ZAApplicationDelegateProxy trackEventWithTarget:self application:application localNotification:notification];
}

+ (void)trackEventWithTarget:(NSObject *)target application:(UIApplication *)application remoteNotification:(NSDictionary *)userInfo {
    // 当 target 和 delegate 不相等时为消息转发, 此时无需重复采集事件
    if (target != application.delegate) {
        return;
    }
    //track notification
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
        ZALogInfo(@"iOS version >= 10.0, callback for %@ was ignored.", @"application:didReceiveRemoteNotification:fetchCompletionHandler:");
        return;
    }
    
    if (application.applicationState != UIApplicationStateInactive) {
        return;
    }
    
    NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
    properties[kZAEventPropertyNotificationChannel] = kZAEventPropertyNotificationChannelApple;
    
    if (userInfo) {
        NSString *title = nil;
        NSString *content = nil;
        id alert = userInfo[kZAPushAppleUserInfoKeyAps][kZAPushAppleUserInfoKeyAlert];
        if ([alert isKindOfClass:[NSDictionary class]]) {
            title = alert[kZAPushAppleUserInfoKeyTitle];
            content = alert[kZAPushAppleUserInfoKeyBody];
        } else if ([alert isKindOfClass:[NSString class]]) {
            content = alert;
        }
        if (userInfo[kZAPushServiceKeySF]) {
            properties[kSFMessageTitle] = title;
            properties[kSFMessageContent] = content;
        }
        properties[kZAEventPropertyNotificationTitle] = title;
        properties[kZAEventPropertyNotificationContent] = content;
        [properties addEntriesFromDictionary:[ZANotificationUtil propertiesFromUserInfo:userInfo]];
    }
    
    [[ZallDataSDK sharedInstance] track:kZAEventNameNotificationClick withProperties:properties];
}

+ (void)trackEventWithTarget:(NSObject *)target application:(UIApplication *)application localNotification:(UILocalNotification *)notification {
    // 当 target 和 delegate 不相等时为消息转发, 此时无需重复采集事件
    if (target != application.delegate) {
        return;
    }
    //track notification
    BOOL isValidPushClick = NO;
    if (application.applicationState == UIApplicationStateInactive) {
        isValidPushClick = YES;
    } else if (application.zalldata_launchOptions[UIApplicationLaunchOptionsLocalNotificationKey]) {
        isValidPushClick = YES;
        application.zalldata_launchOptions = nil;
    }
    
    if (!isValidPushClick) {
        ZALogInfo(@"Invalid app push callback, AppPushClick was ignored.");
        return;
    }
    
    NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
    properties[kZAEventPropertyNotificationContent] = notification.alertBody;
    properties[kSFMessageContent] = notification.alertBody;
    properties[kZAEventPropertyNotificationServiceName] = kZAEventPropertyNotificationServiceNameLocal;
    
    if (@available(iOS 8.2, *)) {
        properties[kZAEventPropertyNotificationTitle] = notification.alertTitle;
        properties[kSFMessageTitle] = notification.alertTitle;
    }
    
    [[ZallDataSDK sharedInstance] track:kZAEventNameNotificationClick withProperties:properties];
}

+ (NSSet<NSString *> *)optionalSelectors {
    return [NSSet setWithArray:@[@"application:didReceiveLocalNotification:", @"application:didReceiveRemoteNotification:fetchCompletionHandler:"]];
}

@end
