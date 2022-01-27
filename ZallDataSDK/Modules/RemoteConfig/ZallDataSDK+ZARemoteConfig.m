//
// ZallDataSDK+ZARemoteConfig.m
// ZallDataSDK
//
// Created by guo on 2022/1/12.
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
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

#import "ZallDataSDK+ZARemoteConfig.h"
#import "ZAConfigOptions.h"
#import "ZAModuleManager.h"
#import "ZAQueueManage.h"
#import "ZAConfigOptions+ZAPrivately.h"
#import "ZAUtilCheck.h"

@implementation ZallDataSDK (ZARemoteConfig)

+ (void)updateServerUrl:(NSString *)serverUrl isRequestRemoteConfig:(BOOL)isRequestRemoteConfig{
    NSParameterAssert(za_check_empty_class(serverUrl,NSString.class));
    if ([ZAConfigOptions.sharedInstance.serverURL isEqualToString:serverUrl]) {
        return;
    }
    [ZAQueueManage sdkOperationQueueAsync:^{
        ZAConfigOptions.sharedInstance.serverURL = serverUrl;
         
        [[ZAModuleManager sharedInstance] retryRequestRemoteConfigWithForceUpdateFlag:isRequestRemoteConfig];
        if (isRequestRemoteConfig) {
            [self updateRemoteConfigServerRequest];
        }
    }];
}

+ (void)updateRemoteConfigServerRequest{
    [[ZAModuleManager sharedInstance] retryRequestRemoteConfigWithForceUpdateFlag:YES];
}


@end

@implementation ZAConfigOptions (RemoteConfig)

@end
#pragma clang diagnostic pop
