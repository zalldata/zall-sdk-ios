//
// ZallDataSDK.h
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

#import <Foundation/Foundation.h>
#import "ZAConstantsDefin.h"
#import "ZAConstantsEnum.h"
#import "ZAConfigOptions.h"

FOUNDATION_EXPORT double ZallDataSDKVersionNumber;

//! Project version string for TestKit.
FOUNDATION_EXPORT const unsigned char ZallDataSDKVersionString[];



NS_ASSUME_NONNULL_BEGIN
@interface ZallDataSDK : NSObject
#pragma mark- init instance
/**
 *  @abstract
 *  通过配置参数，配置卓尔 SDK
 *  @see application:didFinishLaunchingWithOptions:
 *  @warning $AppStart $AppViewScreen 未初始化会有丢失
 */
+ (void)completeConfigOption:(ZAConfigOptions *)config;

/**
 * @abstract
 * 返回之前所初始化好的单例
 *
 * @see launchingWithConfigOptions:
 *
 * @return 返回的单例
 */
+ (instancetype _Nullable)sharedInstance;



/**
 *@abstract SDK开关
 *
 *@discussion 默认是打开状态
 *
 *@param isDisable 设置打开或者关闭
 */
+ (void)disableSDK:(BOOL)isDisable;
  

/**
 * @abstract
 * 设置当前远程可配置的URL
 * @param serverUrl 当前的 serverUrl
 */
+ (void)updateServerUrl:(NSString *)serverUrl;

/**
 * @abstract
 * App 退出或进到后台时清空 referrer，默认情况下不清空
 */
+ (void)clearReferrerWhenAppEnd ;

/**
 * @abstract
 * 得到 SDK 的版本
 *
 * @return SDK 的版本
 */
+ (NSString *)libVersion;


/**
 * @abstract 判断是否为符合要求的 openURL
 * @param url 打开的 URL
 * @return YES/NO
 */
+ (BOOL)canHandleURL:(NSURL *)url ;

/**
 * @abstract
 * 处理 url scheme 跳转打开 App
 *
 * @param url 打开本 app 的回调的 url
 */
+ (BOOL)handleSchemeUrl:(NSURL *)url ;


@end
NS_ASSUME_NONNULL_END

/// 单例实例对象
NS_INLINE ZallDataSDK* _Nullable ZallDataSharedSDK(void){
    return [ZallDataSDK sharedInstance];
}

#if __has_include("ZallDataSDK+Business.h")
#import "ZallDataSDK+Business.h"
#endif

#if __has_include("ZallDataSDK+ZATrack.h")
#import "ZallDataSDK+ZATrack.h"
#endif

#if __has_include("ZallDataSDK+ZAAutoTrack.h")
#import "ZallDataSDK+ZAAutoTrack.h"
#endif

#if __has_include("ZallDataSDK+ZARemoteConfig.h")
#import "ZallDataSDK+ZARemoteConfig.h"
#endif

#if __has_include("ZallDataSDK+ZAEncrypt.h")
#import "ZallDataSDK+ZAEncrypt.h"
#endif

#if __has_include("ZallDataSDK+ZAJSBridge.h")
#import "ZallDataSDK+ZAJSBridge.h"
#endif

#if __has_include("WKWebView+ZABridge.h")
#import "WKWebView+ZABridge.h"
#endif

#if __has_include("ZallDataSDK+ZADeviceOrientation.h")
#import "ZallDataSDK+ZADeviceOrientation.h"
#endif

#if __has_include("ZallDataSDK+ZAAppPush.h")
#import "ZallDataSDK+ZAAppPush.h"
#endif

#if __has_include("ZallDataSDK+ZADebugMode.h")
#import "ZallDataSDK+ZADebugMode.h"
#endif

#if __has_include("ZallDataSDK+ZADeeplink.h")
#import "ZallDataSDK+ZADeeplink.h"
#endif

#if __has_include("ZallDataSDK+ZAChannelMatch.h")
#import "ZallDataSDK+ZAChannelMatch.h"
#endif

#if __has_include("ZallDataSDK+ZALocation.h")
#import "ZallDataSDK+ZALocation.h"
#endif

#if __has_include("ZallDataSDK+ZAException.h")
#import "ZallDataSDK+ZAException.h"
#endif

#if __has_include("ZallDataSDK+ZAVisualized.h")
#import "ZallDataSDK+ZAVisualized.h"
#endif

