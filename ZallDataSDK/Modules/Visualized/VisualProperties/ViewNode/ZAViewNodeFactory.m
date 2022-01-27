//
// ZAViewNodeFactory.m
// ZallDataSDK
//
// Created by guo on 2021/1/29.
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

#import "ZAViewNodeFactory.h"
#import "ZAVisualizedUtils.h"
#import "UIView+ZAAdd.h"
#import "ZAViewNode.h"

@implementation ZAViewNodeFactory

+ (nullable ZAViewNode *)viewNodeWithView:(UIView *)view {
    if ([NSStringFromClass(view.class) isEqualToString:@"UISegment"]) {
        return [[ZASegmentNode alloc] initWithView:view];
    } else if ([view isKindOfClass:UISegmentedControl.class]) {
        return [[ZASegmentedControlNode alloc] initWithView:view];
    } else if ([view isKindOfClass:UITableViewHeaderFooterView.class]) {
        return [[ZATableViewHeaderFooterViewNode alloc] initWithView:view];
    } else if ([view isKindOfClass:UITableViewCell.class] || [view isKindOfClass:UICollectionViewCell.class]) {
        return [[ZACellNode alloc] initWithView:view];
    } else if ([NSStringFromClass(view.class) isEqualToString:@"UITabBarButton"]) {
        // UITabBarItem 点击事件，支持限定元素位置
        return [[ZATabBarButtonNode alloc] initWithView:view];
    } else if ([view za_isKindOfRNView]) {
        return [[ZARNViewNode alloc] initWithView:view];
    } else if ([view isKindOfClass:WKWebView.class]) {
        return [[ZAWKWebViewNode alloc] initWithView:view];
    } else if ([ZAVisualizedUtils isIgnoredItemPathWithView:view]) {
        /* 忽略路径
         1. UITableViewWrapperView 为 iOS11 以下 UITableView 与 cell 之间的 view
         
         2. _UITextFieldCanvasView 和 _UISearchBarFieldEditor 都是 UISearchBar 内部私有 view
         在输入状态下层级关系为：  ...UISearchBarTextField/_UISearchBarFieldEditor/_UITextFieldCanvasView
         非输入状态下层级关系为： .../UISearchBarTextField/_UITextFieldCanvasView
         并且 _UITextFieldCanvasView 是个私有 view,无法获取元素内容。_UISearchBarFieldEditor 是私有 UITextField，可以获取内容
         不论是否输入都准确标识，为方便路径统一，所以忽略 _UISearchBarFieldEditor 路径
         
         3.  UIFieldEditor 是 UITextField 内，只有编辑状态才包含的一层 view，路径忽略，方便统一（自定义属性一般圈选的为 _UITextFieldCanvasView）
         */
        return [[ZAIgnorePathNode alloc] initWithView:view];
    } else {
        return [[ZAViewNode alloc] initWithView:view];
    }
}

@end
