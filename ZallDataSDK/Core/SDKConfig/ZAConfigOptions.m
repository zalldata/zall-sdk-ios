//
// ZAConfigOptions.m
// ZallDataSDK
//
// Created by guo on 2021/12/29.
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
#pragma clang diagnostic ignored "-Wincomplete-implementation"

#import "ZAConfigOptions.h"
#import "ZALog.h"
#import "ZAConfigOptions+ZAPrivately.h"
#import "ZAConstantsDefin.h"
#import "ZAConfigOptions.h"
#import "ZAQuickUtil.h"
#import "ZALog+Private.h"
#import "ZAConsoleLogger.h"


@interface ZAConfigOptions ()



@end

@implementation ZAConfigOptions
 

+ (instancetype)configWithServerURL:(NSString *)serverURL launchOptions:(id)launchOptions{
    ZAConfigOptions * config = ZAConfigOptions.sharedInstance;
    config.serverURL = serverURL;
    config.launchOptions = launchOptions;
    return config;
}

+(instancetype)sharedInstance{
    static ZAConfigOptions *zaConfigOptions;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        zaConfigOptions = [[ZAConfigOptions alloc] init];
    });
    return zaConfigOptions;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _sendInterval = 15 * 1000;
        _sendMaxSize = 100;
        _cacheMaxSize = 10000;
      
        _loginIDKey = kZAIdentitiesLoginId;
   
        _sendNetworkPolicy=
#if TARGET_OS_IOS
        ZANetworkType3G |
        ZANetworkType4G |
#ifdef __IPHONE_14_1
        ZANetworkType5G |
#endif
#endif
        ZANetworkTypeWIFI;
        [self privatelyConfig];
    }
    return self;
}


- (void)privatelyConfig{
#if __has_include("ZallDataSDK+ZAAutoTrack.h")
    _tarckIntervalTime = 0.1;
#endif
#if __has_include("ZallDataSDK+ZAVisualized.h")
    _enableVisualizedProperties = YES;
#endif
}

-(void)setEnableLog:(BOOL)enableLog{
    _enableLog = enableLog;
    [ZALog sharedLog].enableLog = enableLog;
    if (enableLog) {
        ZAConsoleLogger *consoleLogger = [[ZAConsoleLogger alloc] init];
        [ZALog addLogger:consoleLogger];
    }else{
        [ZALog removeAllLoggers];
    }
}

-(void)setSendInterval:(NSInteger)sendInterval{
    _sendInterval = sendInterval >= 5000 ? sendInterval:5000;
    
}
 
-(void)setSendMaxSize:(NSInteger)sendMaxSize{
    _sendMaxSize = sendMaxSize >= 50 ? sendMaxSize : 50;
}
 
-(void)setCacheMaxSize:(NSInteger)cacheMaxSize{
    _cacheMaxSize = cacheMaxSize >= 10000 ? cacheMaxSize : 10000;

}

#if __has_include("ZallDataSDK+ZARemoteConfig.h")
- (void)setMinRequestHourInterval:(NSInteger)minRequestHourInterval {
    if (minRequestHourInterval > 0) {
        _minRequestHourInterval = MIN(minRequestHourInterval, 7*24);
    }
}

- (void)setMaxRequestHourInterval:(NSInteger)maxRequestHourInterval {
    if (maxRequestHourInterval > 0) {
        _maxRequestHourInterval = MIN(maxRequestHourInterval, 7*24);
    }
}
#endif

@end
#pragma clang diagnostic pop
