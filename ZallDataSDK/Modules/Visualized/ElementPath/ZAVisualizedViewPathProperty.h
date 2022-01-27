//
// ZAVisualizedViewPathProperty.h
// ZallDataSDK
//
// Created by guo on 2020/3/28.
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

#pragma mark - ViewPath
@protocol ZAAutoTrackViewPathProperty <NSObject>

/// $AppClick 某个元素的相对路径，拼接 $element_selector。单个元素不包含序号
@property (nonatomic, copy, readonly) NSString *zalldata_heatMapPath;

@optional
/// $AppClick 某个元素的相对路径，拼接 $element_path，单个元素包含序号
@property (nonatomic, copy, readonly) NSString *zalldata_itemPath;

/// 元素相似路径，可能包含 [-]
@property (nonatomic, copy, readonly) NSString *zalldata_similarPath;
@end


#pragma mark - Visualized
// 可视化全埋点&点击分析 上传页面信息相关协议
@protocol ZAVisualizedViewPathProperty <NSObject>

@optional
/// 当前元素，前端是否渲染成可交互
@property (nonatomic, assign, readonly) BOOL zalldata_enableAppClick;

/// 当前元素的有效内容
@property (nonatomic, copy, readonly) NSString *zalldata_elementValidContent;

/// 元素子视图
@property (nonatomic, copy, readonly) NSArray *zalldata_subElements;

/// 当前元素的路径
@property (nonatomic, copy, readonly) NSString *zalldata_elementPath;

/// 当前元素的元素选择器
@property (nonatomic, copy, readonly) NSString *zalldata_elementSelector;

/// 相对 keywindow 的坐标
@property (nonatomic, assign, readonly) CGRect zalldata_frame;

/// 当前元素所在页面名称
@property (nonatomic, copy, readonly) NSString *zalldata_screenName;

/// 当前元素所在页面标题
@property (nonatomic, copy, readonly) NSString *zalldata_title;

/// 是否为 Web 元素
@property (nonatomic, assign) BOOL zalldata_isFromWeb;

/// 是否为列表（本身支持限定位置，比如 Cell）
@property (nonatomic, assign) BOOL zalldata_isListView;

@end

#pragma mark - Extension
@protocol ZAVisualizedExtensionProperty <NSObject>

@optional
/// 一个 view 上子视图可见区域
@property (nonatomic, assign, readonly) CGRect zalldata_visibleFrame;

/// 是否禁用 RCTView 子视图交互
@property (nonatomic, assign) BOOL zalldata_isDisableRNSubviewsInteractive;
@end
