//
// UIApplication+PushClick.m
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

#import "UIApplication+PushClick.h"
#import "ZAApplicationDelegateProxy.h"
#import <objc/runtime.h>

static void *const kZALaunchOptions = (void *)&kZALaunchOptions;

@implementation UIApplication (PushClick)

- (void)zalldata_setDelegate:(id<UIApplicationDelegate>)delegate {
    //resolve optional selectors
    [ZAApplicationDelegateProxy resolveOptionalSelectorsForDelegate:delegate];
    
    [self zalldata_setDelegate:delegate];
    
    if (!self.delegate) {
        return;
    }
    [ZAApplicationDelegateProxy proxyDelegate:self.delegate selectors:[NSSet setWithArray:@[@"application:didReceiveLocalNotification:", @"application:didReceiveRemoteNotification:fetchCompletionHandler:"]]];
}

- (NSDictionary *)zalldata_launchOptions {
    return objc_getAssociatedObject(self, kZALaunchOptions);
}

- (void)setZalldata_launchOptions:(NSDictionary *)zalldata_launchOptions {
    objc_setAssociatedObject(self, kZALaunchOptions, zalldata_launchOptions, OBJC_ASSOCIATION_COPY);
}

@end
