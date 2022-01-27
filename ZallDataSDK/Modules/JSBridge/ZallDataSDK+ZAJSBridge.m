//
// ZallDataSDK+ZAJSBridge.m
// ZallDataSDK
//
// Created by guo on 2022/1/17.
// Copyright © 2022 Zall Data Co., Ltd. All rights reserved.
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

#import <Foundation/Foundation.h>
#import "ZallDataSDK+ZAJSBridge.h"
#import "ZallDataSDK+ZAPrivate.h"
#import "ZAModuleManager.h"

@implementation ZallDataSDK (ZAJSBridge)
- (void)trackFromH5WithEvent:(NSString *)eventInfo{
    [self trackFromH5WithEvent:eventInfo enableVerify:NO];
}

- (void)trackFromH5WithEvent:(NSString *)eventInfo enableVerify:(BOOL)enableVerify{
    if (!eventInfo) {
        return;
    }
    [self.eventTracker trackFromH5WithEvent:eventInfo enableVerify:enableVerify];
}
 
- (void)appendWebViewUserAgent {
    if (!self.zaWebViewUserAgent) {
        // 没有开启老版打通
        return;
    }

    if (ZAConfigOptions.sharedInstance.disableSDK) {
        return;
    }
    
    NSString *currentUserAgent = [ZAQuickUtil zaGetUserAgent];
    if ([currentUserAgent containsString:self.zaWebViewUserAgent]) {
        return;
    }
    
    NSMutableString *newUserAgent = [NSMutableString string];
    if (currentUserAgent) {
        [newUserAgent appendString:currentUserAgent];
    }
    [newUserAgent appendString:self.zaWebViewUserAgent];
    [ZAQuickUtil zaSaveUserAgent:newUserAgent];
}

- (void)removeWebViewUserAgent {
    if (!self.zaWebViewUserAgent) {
        // 没有开启老版打通
        return;
    }
    
    NSString *currentUserAgent = [ZAQuickUtil zaGetUserAgent];
    if (![currentUserAgent containsString:self.zaWebViewUserAgent]) {
        return;
    }
    
    NSString *newUserAgent = [currentUserAgent stringByReplacingOccurrencesOfString:self.zaWebViewUserAgent withString:@""];
    
    [ZAQuickUtil zaSaveUserAgent:newUserAgent];
}


@end
