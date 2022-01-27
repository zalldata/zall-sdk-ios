//
//  ZANetwork.m
//  ZallDataSDK
//
//  Created by guo on 2019/3/8.
//  Copyright © 2015-2020 Zall Data Co., Ltd. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag on this file.
#endif

#import "ZANetwork.h"
#import "ZAURLUtils.h"
#import "ZAModuleManager.h"
#import "ZallDataSDK.h"
#import "ZAUtilCheck.h"
#import "ZALog.h"
#import "ZAJSONUtil.h"
#import "ZAHTTPSession.h"
#import "ZAReachability.h"
#import "ZAConfigOptions+ZAPrivately.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>


@interface ZANetwork ()

@property (nonatomic, copy) NSString *cookie;

@end

@implementation ZANetwork

#pragma mark - cookie
- (void)setCookie:(NSString *)cookie isEncoded:(BOOL)encoded {
    if (encoded) {
        _cookie = [cookie stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet alphanumericCharacterSet]];
    } else {
        _cookie = cookie;
    }
}

- (NSString *)cookieWithDecoded:(BOOL)isDecoded {
    return isDecoded ? _cookie.stringByRemovingPercentEncoding : _cookie;
}

#pragma mark - build

#pragma mark - request


@end

#pragma mark -
@implementation ZANetwork (ServerURL)

- (NSURL *)serverURL {
    
    NSURL *serverURL = [NSURL URLWithString:ZAConfigOptions.sharedInstance.serverURL];
    if (ZAModuleManager.sharedInstance.isDebugMode || serverURL == nil) {
        return serverURL;
    }
    NSURL *url = serverURL;
    // 将 Server URI Path 替换成 Debug 模式的 '/debug'
    if (serverURL.lastPathComponent.length > 0) {
        url = [serverURL URLByDeletingLastPathComponent];
    }
    url = [url URLByAppendingPathComponent:@"debug"];
    if (url.host && [url.host rangeOfString:@"_"].location != NSNotFound) { //包含下划线日志提示
        NSString *referenceURL = @"https://en.wikipedia.org/wiki/Hostname";
        ZALogWarn(@"Server url:%@ contains '_'  is not recommend,see details:%@", serverURL, referenceURL);
    }
    return url;
}

- (NSURLComponents *)baseURLComponents {
    if (self.serverURL.absoluteString.length <= 0) {
        return nil;
    }
    NSURLComponents *components;
    NSURL *url = self.serverURL.lastPathComponent.length > 0 ? [self.serverURL URLByDeletingLastPathComponent] : self.serverURL;
    if (url) {
        components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:YES];
    }
    if (!components.host) {
        ZALogError(@"URLString is malformed, nil is returned.");
        return nil;
    }
    return components;
}

- (NSString *)host {
    return [ZAURLUtils hostWithURL:self.serverURL] ?: @"";
}

- (NSString *)project {
    return [ZAURLUtils queryItemsWithURL:self.serverURL][@"project"] ?: @"default";
}

- (NSString *)token {
    return [ZAURLUtils queryItemsWithURL:self.serverURL][@"token"] ?: @"";
}

- (BOOL)isSameProjectWithURLString:(NSString *)URLString {
    if (![self isValidServerURL] || URLString.length == 0) {
        return NO;
    }
    BOOL isEqualHost = [self.host isEqualToString:[ZAURLUtils hostWithURLString:URLString]];
    NSString *project = [ZAURLUtils queryItemsWithURLString:URLString][@"project"] ?: @"default";
    BOOL isEqualProject = [self.project isEqualToString:project];
    return isEqualHost && isEqualProject;
}

- (BOOL)isValidServerURL {
    return self.serverURL.absoluteString.length > 0;
}

@end

#pragma mark -
@implementation ZANetwork (Type)

+ (ZANetworkType)networkTypeOptions {
    NSString *networkTypeString = [ZANetwork networkTypeString];

    if ([@"NULL" isEqualToString:networkTypeString]) {
        return ZANetworkTypeNONE;
    } else if ([@"WIFI" isEqualToString:networkTypeString]) {
        return ZANetworkTypeWIFI;
    }

    ZANetworkType networkType = ZANetworkTypeNONE;
    networkType = [self networkTypeWWANOptionsWithString:networkTypeString];

    return networkType;
}

+ (NSString *)networkTypeString {
    NSString *networkTypeString = @"NULL";
    @try {
        if ([ZAReachability sharedInstance].isReachableViaWiFi) {
            networkTypeString = @"WIFI";
        }
        else {
            networkTypeString = [self networkTypeWWANString];
        }

    } @catch (NSException *exception) {
        ZALogError(@"%@: %@", self, exception);
    }
    return networkTypeString;
}

+ (ZANetworkType)networkTypeWWANOptionsWithString:(NSString *)networkTypeString {
    if ([@"2G" isEqualToString:networkTypeString]) {
        return ZANetworkType2G;
    } else if ([@"3G" isEqualToString:networkTypeString]) {
        return ZANetworkType3G;
    } else if ([@"4G" isEqualToString:networkTypeString]) {
        return ZANetworkType4G;
#ifdef __IPHONE_14_1
    } else if ([@"5G" isEqualToString:networkTypeString]) {
        return ZANetworkType5G;
#endif
    } else if ([@"UNKNOWN" isEqualToString:networkTypeString]) {
        return ZANetworkType4G;
    }
    return ZANetworkTypeNONE;
}

+ (NSString *)networkTypeWWANString {
    if (![ZAReachability sharedInstance].isReachableViaWWAN) {
        return @"NULL";
    }

    static CTTelephonyNetworkInfo *networkInfo = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    });

    NSString *currentRadioAccessTechnology = nil;
#ifdef __IPHONE_12_0
    if (@available(iOS 12.1, *)) {
        currentRadioAccessTechnology = networkInfo.serviceCurrentRadioAccessTechnology.allValues.lastObject;
    }
#endif
    // 测试发现存在少数 12.0 和 12.0.1 的机型 serviceCurrentRadioAccessTechnology 返回空
    if (!currentRadioAccessTechnology) {
        currentRadioAccessTechnology = networkInfo.currentRadioAccessTechnology;
    }

    return [ZANetwork networkStatusWithRadioAccessTechnology:currentRadioAccessTechnology];
}

+ (NSString *)networkStatusWithRadioAccessTechnology:(NSString *)value {
    if ([value isEqualToString:CTRadioAccessTechnologyGPRS] ||
        [value isEqualToString:CTRadioAccessTechnologyEdge]
        ) {
        return @"2G";
    } else if ([value isEqualToString:CTRadioAccessTechnologyWCDMA] ||
               [value isEqualToString:CTRadioAccessTechnologyHSDPA] ||
               [value isEqualToString:CTRadioAccessTechnologyHSUPA] ||
               [value isEqualToString:CTRadioAccessTechnologyCDMA1x] ||
               [value isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0] ||
               [value isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA] ||
               [value isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB] ||
               [value isEqualToString:CTRadioAccessTechnologyeHRPD]
               ) {
        return @"3G";
    } else if ([value isEqualToString:CTRadioAccessTechnologyLTE]) {
        return @"4G";
    }

#ifdef __IPHONE_14_1
    else if (@available(iOS 14.1, *)) {
        if ([value isEqualToString:CTRadioAccessTechnologyNRNSA] ||
            [value isEqualToString:CTRadioAccessTechnologyNR]
            ) {
            return @"5G";
        }
    }
#endif
    return @"UNKNOWN";
}

@end
