//
// ZAReferrerManager.m
// ZallDataSDK
//
// Created by guo on 2020/12/9.
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

#import "ZAReferrerManager.h"

#import "ZAConstantsDefin.h"
#import "ZAQueueManage.h"

@interface ZAReferrerManager ()

@property (atomic, copy, readwrite) NSDictionary *referrerProperties;
@property (atomic, copy, readwrite) NSString *referrerURL;
@property (nonatomic, copy, readwrite) NSString *referrerTitle;
@property (nonatomic, copy) NSString *currentTitle;

@end

@implementation ZAReferrerManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static ZAReferrerManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[ZAReferrerManager alloc] init];
    });
    return manager;
}

- (NSDictionary *)propertiesWithURL:(NSString *)currentURL eventProperties:(NSDictionary *)eventProperties {
    NSString *referrerURL = self.referrerURL;
    NSMutableDictionary *newProperties = [NSMutableDictionary dictionaryWithDictionary:eventProperties];

    // 客户自定义属性中包含 $url 时，以客户自定义内容为准
    if (!newProperties[kZAEventPropertyScreenUrl]) {
        newProperties[kZAEventPropertyScreenUrl] = currentURL;
    }
    // 客户自定义属性中包含 $referrer 时，以客户自定义内容为准
    if (referrerURL && !newProperties[kZAEventPropertyScreenReferrerUrl]) {
        newProperties[kZAEventPropertyScreenReferrerUrl] = referrerURL;
    }
    // $referrer 内容以最终页面浏览事件中的 $url 为准
    self.referrerURL = newProperties[kZAEventPropertyScreenUrl];
    self.referrerProperties = newProperties;
    [ZAQueueManage sdkOperationQueueAsync:^{
        [self cacheReferrerTitle:newProperties];
    }];
    return newProperties;
}

- (void)cacheReferrerTitle:(NSDictionary *)properties {
    self.referrerTitle = self.currentTitle;
    self.currentTitle = properties[kZAEventPropertyTitle];
}

- (void)clearReferrer {
    if (self.isClearReferrer) {
        // 需求层面只需要清除 $referrer，不需要清除 $referrer_title
        self.referrerURL = nil;
    }
}

@end
