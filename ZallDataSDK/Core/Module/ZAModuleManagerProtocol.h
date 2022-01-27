//
// ZAModuleManagerProtocol.h
// ZallDataSDK
//
// Created by guo on 2021/12/31.
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
#import "ZAConfigOptions.h"
#import "ZAConstantsEnum.h"
NS_ASSUME_NONNULL_BEGIN


#define ZASDKModules "ZASDKModules"
#define ZAAnnotationModulesDATA __attribute((used,section("__DATA,"ZASDKModules"")))
 
/**
 *  Use this to annotation a `module`
 *  like this: @ZAAppLoadModule()
 *  默认同一个模块协议只会做一次加载
 */
#define ZAAppLoadModule(modName) \
class ZAModuleProtocol;\
char const * gcZAAppLoadModule_##modName ZAAnnotationModulesDATA = ""#modName"";

@class ZAEventBaseObject;

/// 协议和功能模块是一对一出现
@protocol ZAModuleProtocol <NSObject>
/// 功能模块开启
@property (nonatomic, assign, getter=isEnable) BOOL enable;

@property (nonatomic, strong) ZAConfigOptions *configOptions;


+ (instancetype)defaultManager;

@optional
- (void)updateServerURL:(NSString *)serverURL;

@end

#pragma mark - ModuleProperty

@protocol ZAModulePropertyProtocol <NSObject>

@optional
@property (nonatomic, copy, readonly, nullable) NSDictionary *properties;

@end

#pragma mark - ModuleOpenURL

@protocol ZAModuleOpenURLProtocol <NSObject>

- (BOOL)canHandleURL:(NSURL *)url;
- (BOOL)handleURL:(NSURL *)url;

@end


#pragma mark - 渠道信息 ChannelMatch

@protocol ZAModuleChannelMatchProtocol <NSObject>

/// 获取事件的渠道信息
///
/// 注意：这个方法需要在 serialQueue 中调用，保证线程安全
///
/// @param event 事件名
- (NSDictionary *)channelInfoWithEvent:(NSString *)event;

@end

#pragma mark - DebugMode

@protocol ZAModuleDebugModeProtocol <NSObject>

/// Debug Mode 属性，设置或获取 Debug 模式
@property (nonatomic) ZADebugModeType debugMode;

@property (nonatomic,readonly) BOOL isDebugMode;

/// 设置在 Debug 模式下，是否弹窗显示错误信息
/// @param isShow 是否显示
- (void)setShowDebugAlertView:(BOOL)isShow;

/// 设置 SDK 的 DebugMode 在 Debug 模式时弹窗警告
/// @param mode Debug 模式
- (void)handleDebugMode:(ZADebugModeType)mode;

/// Debug 模式下，弹窗显示错误信息
/// @param message 错误信息
- (void)showDebugModeWarning:(NSString *)message;

@end

#pragma mark - ModuleEncrypt

@protocol ZAModuleEncryptProtocol <NSObject>

@property (nonatomic, readonly) BOOL hasSecretKey;

/// 用于远程配置回调中处理并保存密钥
/// @param encryptConfig 返回的
- (void)handleEncryptWithConfig:(NSDictionary *)encryptConfig;

/// 加密数据
/// @param obj 需要加密的 JSON 数据
/// @return 返回加密后的数据
- (nullable NSDictionary *)encryptJSONObject:(id)obj;

@end

#pragma mark - ModuleDeeplink

@protocol ZAModuleDeeplinkProtocol <NSObject>

/// DeepLink 回调函数
/// @param linkHandlerCallback  callback 请求成功后的回调函数
///     - params：创建渠道链接时填写的 App 内参数
///     - succes：deeplink 唤起结果
///     - appAwakePassedTime：获取渠道信息所用时间
- (void)setLinkHandlerCallback:(void (^ _Nonnull)(NSString * _Nullable, BOOL, NSInteger))linkHandlerCallback;

/// 最新的来源渠道信息
@property (nonatomic, copy, nullable, readonly) NSDictionary *latestUtmProperties;

/// 当前 DeepLink 启动时的来源渠道信息
@property (nonatomic, copy, readonly) NSDictionary *utmProperties;

/// 清除本次 DeepLink 解析到的 utm 信息
- (void)clearUtmProperties;

/// 触发 $AppDeepLinkLaunch 事件
/// @param url 唤起 App 的 DeepLink url
- (void)trackDeepLinkLaunchWithURL:(NSString *)url;

@end

#pragma mark - ModuleAutoTrack

@protocol ZAModuleAutoTrackProtocol <NSObject>

/// 触发 App 崩溃时的退出事件
- (void)trackAppEndWhenCrashed;
- (void)trackPageLeaveWhenCrashed;

@end

#pragma mark - ModuleJavaScriptBridge

@protocol ZAModuleJavaScriptBridgeProtocol <NSObject>

- (nullable NSString *)javaScriptSource;
@end
#pragma mark - ModuleRemoteConfig

@protocol ZAModuleRemoteConfigProtocol <NSObject>

/// 重试远程配置请求
/// @param isForceUpdate 是否强制请求最新的远程配置
- (void)retryRequestRemoteConfigWithForceUpdateFlag:(BOOL)isForceUpdate;

/// 事件对象是否被远程控制忽略
/// @param obj 事件对象
- (BOOL)isIgnoreEventObject:(ZAEventBaseObject *)obj;

- (BOOL)isDisableSDK;

@end
#pragma mark - ModuleVisualized

@protocol ZAModuleVisualizedProtocol <NSObject>

/// 元素相关属性
/// @param view 需要采集的 view
- (nullable NSDictionary *)propertiesWithView:(id)view;

#pragma mark visualProperties

/// 采集元素自定义属性
/// @param view 触发事件的元素
/// @param completionHandler 采集完成回调
- (void)visualPropertiesWithView:(id)view completionHandler:(void (^)(NSDictionary *_Nullable visualProperties))completionHandler;

/// 根据配置，采集属性
/// @param propertyConfigs 自定义属性配置
/// @param completionHandler 采集完成回调
- (void)queryVisualPropertiesWithConfigs:(NSArray <NSDictionary *>*)propertyConfigs completionHandler:(void (^)(NSDictionary *_Nullable properties))completionHandler;

@end

#pragma mark Exception
@protocol ZAModuleExceptionProtocol <NSObject>

@end




@protocol ZAModuleManagerProtocol <ZAModuleChannelMatchProtocol,ZAModuleDebugModeProtocol,ZAModuleEncryptProtocol,ZAModuleAutoTrackProtocol,ZAModuleJavaScriptBridgeProtocol,ZAModuleRemoteConfigProtocol,ZAModuleVisualizedProtocol,ZAModuleDeeplinkProtocol,ZAModuleExceptionProtocol>


@end

NS_ASSUME_NONNULL_END
