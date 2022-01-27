//
// ZANotificationManager.m
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

#import "ZAAppPushManager.h"
#import "ZAApplicationDelegateProxy.h"
#import "ZASwizzle.h"
#import "ZALog.h"
#import "UIApplication+PushClick.h"
#import "ZAMethodHelper.h"

#import "ZAConfigOptions+ZAPrivately.h"
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
#import "ZAUNUserNotificationCenterDelegateProxy.h"
#endif
@ZAAppLoadModule(ZAAppPushManager)
@implementation ZAAppPushManager

+ (instancetype)defaultManager {
    static dispatch_once_t onceToken;
    static ZAAppPushManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[ZAAppPushManager alloc] init];
    });
    return manager;
}

- (void)setEnable:(BOOL)enable {
    _enable = enable;
    if (enable) {
        [self proxyNotifications];
    }
}

- (void)setConfigOptions:(ZAConfigOptions *)configOptions {
    _configOptions = configOptions;
    [UIApplication sharedApplication].zalldata_launchOptions = configOptions.launchOptions;
    self.enable = configOptions.enableTrackPush;
}

- (void)proxyNotifications {
    //处理未实现代理方法也能采集事件的逻辑
    [ZAMethodHelper swizzleRespondsToSelector];
    
    //UIApplicationDelegate proxy
    [ZAApplicationDelegateProxy resolveOptionalSelectorsForDelegate:[UIApplication sharedApplication].delegate];
    [ZAApplicationDelegateProxy proxyDelegate:[UIApplication sharedApplication].delegate selectors:[NSSet setWithArray:@[@"application:didReceiveLocalNotification:", @"application:didReceiveRemoteNotification:fetchCompletionHandler:"]]];
    
    //UNUserNotificationCenterDelegate proxy
    if (@available(iOS 10.0, *)) {
        if ([UNUserNotificationCenter currentNotificationCenter].delegate) {
            [ZAUNUserNotificationCenterDelegateProxy proxyDelegate:[UNUserNotificationCenter currentNotificationCenter].delegate selectors:[NSSet setWithArray:@[@"userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:"]]];
        }
        NSError *error = NULL;
        [UNUserNotificationCenter za_swizzleMethod:@selector(setDelegate:) withMethod:@selector(zalldata_setDelegate:) error:&error];
        if (error) {
            ZALogError(@"proxy notification delegate error: %@", error);
        }
    }
}

@end
