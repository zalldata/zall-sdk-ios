//
// ZAScriptMessageHandler.m
// ZallDataSDK
//
// Created by guo on 2020/3/18.
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

#import "ZAJavaScriptBridgeManager.h"
#import "ZALog.h"
#import "ZAModuleManager.h"
#import "WKWebView+ZABridge.h"
#import "ZAJSONUtil.h"
#import "ZASwizzle.h"
#import "ZallDataSDK+ZAJSBridge.h"
#import "ZAConfigOptions+ZAPrivately.h"
#import "ZAModuleManager.h"
@ZAAppLoadModule(ZAJavaScriptBridgeManager)
@implementation ZAJavaScriptBridgeManager

+ (instancetype)defaultManager {
    static dispatch_once_t onceToken;
    static ZAJavaScriptBridgeManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[ZAJavaScriptBridgeManager alloc] init];
    });
    return manager;
}

#pragma mark - ZAModuleProtocol

- (void)setEnable:(BOOL)enable {
    _enable = enable;
    if (enable) {
        [self swizzleWebViewMethod];
    }
}

- (void)setConfigOptions:(ZAConfigOptions *)configOptions {
    _configOptions = configOptions;
    self.enable = configOptions.enableJavaScriptBridge;
}

#pragma mark - ZAJavaScriptBridgeModuleProtocol

- (NSString *)javaScriptSource {
    if (!self.configOptions.enableJavaScriptBridge) {
        return nil;
    }
    if (self.configOptions.serverURL) {
        return [ZAJavaScriptBridgeBuilder buildJSBridgeWithServerURL:self.configOptions.serverURL];
    }

    ZALogError(@"%@ get network serverURL is failed!", self);
    return nil;
}

#pragma mark - Private

- (void)swizzleWebViewMethod {
    static dispatch_once_t onceTokenWebView;
    dispatch_once(&onceTokenWebView, ^{
        NSError *error = NULL;

        [WKWebView za_swizzleMethod:@selector(loadRequest:)
                         withMethod:@selector(zalldata_loadRequest:)
                              error:&error];

        [WKWebView za_swizzleMethod:@selector(loadHTMLString:baseURL:)
                         withMethod:@selector(zalldata_loadHTMLString:baseURL:)
                              error:&error];

        if (@available(iOS 9.0, *)) {
            [WKWebView za_swizzleMethod:@selector(loadFileURL:allowingReadAccessToURL:)
                             withMethod:@selector(zalldata_loadFileURL:allowingReadAccessToURL:)
                                  error:&error];

            [WKWebView za_swizzleMethod:@selector(loadData:MIMEType:characterEncodingName:baseURL:)
                             withMethod:@selector(zalldata_loadData:MIMEType:characterEncodingName:baseURL:)
                                  error:&error];
        }

        if (error) {
            ZALogError(@"Failed to swizzle on WKWebView. Details: %@", error);
            error = NULL;
        }
    });
}

- (void)addScriptMessageHandlerWithWebView:(WKWebView *)webView {
    if ([ZAConfigOptions.sharedInstance isDisableSDK]) {
        return;
    }

    NSAssert([webView isKindOfClass:[WKWebView class]], @"此注入方案只支持 WKWebView！❌");
    if (![webView isKindOfClass:[WKWebView class]]) {
        return;
    }

    @try {
        WKUserContentController *contentController = webView.configuration.userContentController;
        [contentController removeScriptMessageHandlerForName:ZA_SCRIPT_MESSAGE_HANDLER_NAME];
        [contentController addScriptMessageHandler:[ZAJavaScriptBridgeManager defaultManager] name:ZA_SCRIPT_MESSAGE_HANDLER_NAME];

        NSString *javaScriptSource = [ZAModuleManager.sharedInstance javaScriptSource];
        if (javaScriptSource.length == 0) {
            return;
        }

        NSArray<WKUserScript *> *userScripts = contentController.userScripts;
        __block BOOL isContainJavaScriptBridge = NO;
        [userScripts enumerateObjectsUsingBlock:^(WKUserScript *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            if ([obj.source containsString:kZAJSBridgeServerURL] || [obj.source containsString:kZAJSBridgeVisualizedMode]) {
                isContainJavaScriptBridge = YES;
                *stop = YES;
            }
        }];

        if (!isContainJavaScriptBridge) {
            // forMainFrameOnly:标识脚本是仅应注入主框架（YES）还是注入所有框架（NO）
            WKUserScript *userScript = [[WKUserScript alloc] initWithSource:[NSString stringWithString:javaScriptSource] injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
            [contentController addUserScript:userScript];

            // 通知其他模块，开启打通 H5
            if ([javaScriptSource containsString:kZAJSBridgeServerURL]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:ZA_H5_BRIDGE_NOTIFICATION object:webView];
            }
        }
    } @catch (NSException *exception) {
        ZALogError(@"%@ error: %@", self, exception);
    }
}

#pragma mark - Delegate

// Invoked when a script message is received from a webpage
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if (![message.name isEqualToString:ZA_SCRIPT_MESSAGE_HANDLER_NAME]) {
        return;
    }
    
    if (![message.body isKindOfClass:[NSString class]]) {
        ZALogError(@"Message body is not kind of 'NSString' from JS SDK");
        return;
    }
    
    @try {
        NSString *body = message.body;
        NSData *messageData = [body dataUsingEncoding:NSUTF8StringEncoding];
        if (!messageData) {
            ZALogError(@"Message body is invalid from JS SDK");
            return;
        }
        
        NSDictionary *messageDic = [ZAJSONUtil JSONObjectWithData:messageData];
        if (![messageDic isKindOfClass:[NSDictionary class]]) {
            ZALogError(@"Message body is formatted failure from JS SDK");
            return;
        }
        
        NSString *callType = messageDic[@"callType"];
        if ([callType isEqualToString:@"app_h5_track"]) {
            // H5 发送事件
            NSDictionary *trackMessageDic = messageDic[@"data"];
            if (![trackMessageDic isKindOfClass:[NSDictionary class]]) {
                ZALogError(@"Data of message body is not kind of 'NSDictionary' from JS SDK");
                return;
            }
            
            NSString *trackMessageString = [ZAJSONUtil stringWithJSONObject:trackMessageDic];
            [[ZallDataSDK sharedInstance] trackFromH5WithEvent:trackMessageString];
        } else if ([callType isEqualToString:@"visualized_track"] || [callType isEqualToString:@"app_alert"] || [callType isEqualToString:@"page_info"]) {
            /* 缓存 H5 页面信息
             visualized_track：H5 可点击元素数据，数组；
             app_alert：H5 弹框信息，提示配置错误信息；
             page_info：H5 页面信息，包括 url、title 和 lib_version
             */
            [[NSNotificationCenter defaultCenter] postNotificationName:ZA_VISUALIZED_H5_MESSAGE_NOTIFICATION object:message];
        } else if ([callType isEqualToString:@"abtest"]) {
            // 通知 ZallABTest，接收到 H5 的请求数据
            [[NSNotificationCenter defaultCenter] postNotificationName:ZA_H5_MESSAGE_NOTIFICATION object:message];
        }
    } @catch (NSException *exception) {
        ZALogError(@"%@ error: %@", self, exception);
    }
}

@end

/// 打通 Bridge
NSString * const kZAJSBridgeObject = @"window.SensorsData_iOS_JS_Bridge = {};";

/// 打通设置 serverURL
NSString * const kZAJSBridgeServerURL = @"window.SensorsData_iOS_JS_Bridge.sensorsdata_app_server_url";

/// 可视化 Bridge
NSString * const kZAVisualBridgeObject = @"window.SensorsData_App_Visual_Bridge = {};";

/// 标识扫码进入可视化模式
NSString * const kZAJSBridgeVisualizedMode = @"window.SensorsData_App_Visual_Bridge.sensorsdata_visualized_mode";

/// 自定义属性 Bridge
NSString * const kZAVisualPropertyBridge = @"window.SensorsData_APP_New_H5_Bridge = {};";

/// 写入自定义属性配置
NSString * const kZAJSBridgeVisualConfig = @"window.SensorsData_APP_New_H5_Bridge.sensorsdata_get_app_visual_config";

/// js 方法调用
NSString * const kZAJSBridgeCallMethod = @"window.sensorsdata_app_call_js";

@implementation ZAJavaScriptBridgeBuilder

#pragma mark 注入 js

/// 注入打通bridge，并设置 serverURL
/// @param serverURL 数据接收地址
+ (nullable NSString *)buildJSBridgeWithServerURL:(NSString *)serverURL {
    if (serverURL.length == 0) {
        return nil;
    }
    return [NSString stringWithFormat:@"%@%@ = '%@';", kZAJSBridgeObject, kZAJSBridgeServerURL, serverURL];
}

/// 注入可视化 bridge，并设置扫码模式
/// @param isVisualizedMode 是否为可视化扫码模式
+ (nullable NSString *)buildVisualBridgeWithVisualizedMode:(BOOL)isVisualizedMode {
    return [NSString stringWithFormat:@"%@%@ = %@;", kZAVisualBridgeObject, kZAJSBridgeVisualizedMode, isVisualizedMode ? @"true" : @"false"];
}

/// 注入自定义属性 bridge，配置信息
/// @param originalConfig 配置信息原始 json
+ (nullable NSString *)buildVisualPropertyBridgeWithVisualConfig:(NSDictionary *)originalConfig {
    if (originalConfig.count == 0) {
        return nil;
    }
    NSMutableString *javaScriptSource = [NSMutableString stringWithString:kZAVisualPropertyBridge];
    [javaScriptSource appendString:kZAJSBridgeVisualConfig];

    // 注入完整配置信息
    NSData *callJSData = [ZAJSONUtil dataWithJSONObject:originalConfig];
    // base64 编码，避免转义字符丢失的问题
    NSString *callJSJsonString = [callJSData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
    [javaScriptSource appendFormat:@" = '%@';", callJSJsonString];
    return [javaScriptSource copy];
}

#pragma mark JS 方法调用
+ (nullable NSString *)buildCallJSMethodStringWithType:(ZAJavaScriptCallJSType)type jsonObject:(nullable id)object {
    NSString *typeString = [self callJSTypeStringWithType:type];
    if (!typeString) {
        return nil;
    }
    NSMutableString *javaScriptSource = [NSMutableString stringWithString:kZAJSBridgeCallMethod];
    if (!object) {
        [javaScriptSource appendFormat:@"('%@')", typeString];
        return [javaScriptSource copy];
    }

    NSData *callJSData = [ZAJSONUtil dataWithJSONObject:object];
    if (!callJSData) {
        return nil;
    }
    // base64 编码，避免转义字符丢失的问题
    NSString *callJSJsonString = [callJSData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
    [javaScriptSource appendFormat:@"('%@', '%@')", typeString, callJSJsonString];
    return [javaScriptSource copy];
}

+ (nullable NSString *)callJSTypeStringWithType:(ZAJavaScriptCallJSType)type {
    switch (type) {
        case ZAJavaScriptCallJSTypeVisualized:
            return @"visualized";
        case ZAJavaScriptCallJSTypeCheckJSSDK:
            return @"sensorsdata-check-jssdk";
        case ZAJavaScriptCallJSTypeUpdateVisualConfig:
            return @"updateH5VisualConfig";
        case ZAJavaScriptCallJSTypeWebVisualProperties:
            return @"getJSVisualProperties";
        default:
            return nil;
    }
}

@end
