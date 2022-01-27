//
// UNUserNotificationCenter+AutoTrack.m
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

#import "UNUserNotificationCenter+PushClick.h"
#import "ZAUNUserNotificationCenterDelegateProxy.h"

@implementation UNUserNotificationCenter (PushClick)

- (void)zalldata_setDelegate:(id<UNUserNotificationCenterDelegate>)delegate {
    //resolve optional selectors
    [ZAUNUserNotificationCenterDelegateProxy resolveOptionalSelectorsForDelegate:delegate];
    
    [self zalldata_setDelegate:delegate];
    if (!self.delegate) {
        return;
    }
    [ZAUNUserNotificationCenterDelegateProxy proxyDelegate:self.delegate selectors:[NSSet setWithArray:@[@"userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:"]]];
}

@end
