//
// ZAVisualizedManager.h
// ZallDataSDK
//
// Created by guo on 2020/12/25.
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


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ZAVisualPropertiesTracker.h"
#import "ZAVisualizedEventCheck.h"
#import "ZAModuleManagerProtocol.h"

typedef NS_ENUM(NSInteger, ZallAnalyticsVisualizedType) {
    ZallAnalyticsVisualizedTypeUnknown,  // 未知或不允许
    ZallAnalyticsVisualizedTypeHeatMap, // 点击图
    ZallAnalyticsVisualizedTypeAutoTrack  //可视化全埋点
};

NS_ASSUME_NONNULL_BEGIN

@interface ZAVisualizedManager : NSObject<ZAModuleProtocol, ZAModuleOpenURLProtocol, ZAModuleVisualizedProtocol, ZAModuleJavaScriptBridgeProtocol>

+ (instancetype)defaultManager;

@property (nonatomic, assign, getter=isEnable) BOOL enable;
@property (nonatomic, strong) ZAConfigOptions *configOptions;

/// 自定义属性采集
@property (nonatomic, strong, readonly) ZAVisualPropertiesTracker *visualPropertiesTracker;

/// 当前连接类型
@property (nonatomic, assign, readonly) ZallAnalyticsVisualizedType visualizedType;

/// 可视化全埋点配置资源
@property (nonatomic, strong, readonly) ZAVisualPropertiesConfigSources *configSources;

/// 埋点校验
@property (nonatomic, strong, readonly) ZAVisualizedEventCheck *eventCheck;

/// 是否开启埋点校验
- (void)enableEventCheck:(BOOL)enable;

/// 指定页面开启可视化
/// @param controllers  需要开启可视化 ViewController 的类名
- (void)addVisualizeWithViewControllers:(NSArray<NSString *> *)controllers;

/// 判断某个页面是否开启可视化
/// @param viewController 当前页面 viewController
- (BOOL)isVisualizeWithViewController:(UIViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
