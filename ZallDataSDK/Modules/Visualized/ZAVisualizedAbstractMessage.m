//
//  ZAVisualizedAbstractMessage.m
//  ZallDataSDK
//
//  Created by guo on 2018/9/4.
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

#import "ZAVisualizedAbstractMessage.h"
#import "UIViewController+AutoTrack.h"
#import "ZAVisualizedObjectSerializerManager.h"
#import "ZAVisualizedUtils.h"
#import "ZAVisualizedManager.h"
#import "UIViewController+ZAAdd.h"
#import "ZAAutoTrackProperty.h"
#import "ZallDataSDK+ZAPrivate.h"

@interface ZAVisualizedAbstractMessage ()

@property (nonatomic, copy, readwrite) NSString *type;

@end

@implementation ZAVisualizedAbstractMessage {
    NSMutableDictionary *_payload;
}

+ (instancetype)messageWithType:(NSString *)type payload:(NSDictionary *)payload {
    return [[self alloc] initWithType:type payload:payload];
}

- (instancetype)initWithType:(NSString *)type {
    return [self initWithType:type payload:nil];
}

- (instancetype)initWithType:(NSString *)type payload:(NSDictionary *)payload {
    self = [super init];
    if (self) {
        _type = type;
        if (payload) {
             _payload = [payload mutableCopy];
        } else {
            _payload = [NSMutableDictionary dictionary];
        }
    }

    return self;
}

- (void)setPayloadObject:(id)object forKey:(NSString *)key {
    _payload[key] = object;
}

- (id)payloadObjectForKey:(NSString *)key {
    id object = _payload[key];
    return object;
}

- (void)removePayloadObjectForKey:(NSString *)key {
    if (!key) {
        return;
    }
    _payload[key] = nil;
}

- (NSDictionary *)payload {
    return [_payload copy];
}

- (NSData *)JSONDataWithFeatureCode:(NSString *)featureCode {
    NSMutableDictionary *jsonObject = [[NSMutableDictionary alloc] init];
    jsonObject[@"type"] = _type;
    jsonObject[@"os"] = @"iOS"; // 操作系统类型
    jsonObject[@"lib"] = @"iOS"; // SDK 类型

    ZAVisualizedObjectSerializerManager *serializerManager = [ZAVisualizedObjectSerializerManager sharedInstance];
    NSString *screenName = nil;
    NSString *pageName = nil;
    NSString *title = nil;

    @try {
        // 获取当前页面
        UIViewController *currentViewController = serializerManager.lastViewScreenController;
        if (!currentViewController) {
            currentViewController = [UIViewController za_currentViewController];
        }

        // 解析页面信息
        NSDictionary *autoTrackScreenProperties = [ZAAutoTrackProperty propertiesWithViewController:currentViewController];
        screenName = autoTrackScreenProperties[kZAEventPropertyScreenName];
        pageName = autoTrackScreenProperties[kZAEventPropertyScreenName];
        title = autoTrackScreenProperties[kZAEventPropertyTitle];

        // 获取 RN 页面信息
        NSDictionary <NSString *, NSString *> *RNScreenInfo = [ZAVisualizedUtils currentRNScreenVisualizeProperties];
        if (RNScreenInfo[kZAEventPropertyScreenName]) {
            pageName = RNScreenInfo[kZAEventPropertyScreenName];
            screenName = RNScreenInfo[kZAEventPropertyScreenName];
            title = RNScreenInfo[kZAEventPropertyTitle];
        }
    } @catch (NSException *exception) {
        ZALogError(@"%@ error: %@", self, exception);
    }

    jsonObject[@"page_name"] = pageName;
    jsonObject[@"screen_name"] = screenName;
    jsonObject[@"title"] = title;
    jsonObject[@"app_version"] = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
    jsonObject[@"feature_code"] = featureCode;
    jsonObject[@"is_webview"] = @(serializerManager.isContainWebView);
    // 增加 appId
    jsonObject[@"app_id"] = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];

    // 上传全埋点配置开启状态
    NSMutableArray<NSString *>* autotrackOptions = [NSMutableArray array];
    ZAAutoTrackEventType eventType = ZAConfigOptions.sharedInstance.autoTrackEventType;
    if (eventType &  ZAAutoTrackEventTypeAppClick) {
        [autotrackOptions addObject:kZAEventNameAppClick];
    }
    if (eventType &  ZAAutoTrackEventTypeAppViewScreen) {
        [autotrackOptions addObject:kZAEventNameAppViewScreen];
    }
    jsonObject[@"app_autotrack"] = autotrackOptions;

    // 自定义属性开关状态
        jsonObject[@"app_enablevisualizedproperties"] = @(ZAConfigOptions.sharedInstance.enableVisualizedProperties);


    // 添加前端弹框信息
    if (serializerManager.alertInfos.count > 0) {
        jsonObject[@"app_alert_infos"] = [serializerManager.alertInfos copy];
    }
    
    // H5 页面信息
    if (serializerManager.webPageInfo) {
        ZAVisualizedWebPageInfo *webPageInfo = serializerManager.webPageInfo;
        jsonObject[@"h5_url"] = webPageInfo.url;
        jsonObject[@"h5_title"] = webPageInfo.title;
        jsonObject[@"web_lib_version"] = webPageInfo.webLibVersion;
    }
    
    // SDK 版本号
    jsonObject[@"lib_version"] = ZallDataSDK.libVersion;
    // 可视化全埋点配置版本号
    jsonObject[@"config_version"] = [ZAVisualizedManager defaultManager].configSources.configVersion;

    if (_payload.count == 0) {
        return [ZAJSONUtil dataWithJSONObject:jsonObject];
    }
    // 如果使用 GZip 压缩
    // 1. 序列化 Payload
    NSData *jsonData = [ZAJSONUtil dataWithJSONObject:_payload];
    
    // 2. 使用 GZip 进行压缩
    NSData *zippedData = [ZAQuickUtil  gzipDeflateWith:jsonData];
    
    // 3. Base64 Encode
    NSString *b64String = [zippedData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
    
    jsonObject[@"gzip_payload"] = b64String;
    
    return [ZAJSONUtil dataWithJSONObject:jsonObject];
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@:%p type='%@'>", NSStringFromClass([self class]), (__bridge void *)self, self.type];
}

@end
