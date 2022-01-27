//
// UIView+ZAElementPath.h
// ZallDataSDK
//
// Created by guo on 2020/3/6.
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
#import <WebKit/WebKit.h>
#import "ZAWebElementView.h"
#import "ZAAutoTrackProperty.h"
#import "ZAVisualizedViewPathProperty.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - UIView
@interface UIView (ZAElementPath)<ZAVisualizedViewPathProperty, ZAVisualizedExtensionProperty, ZAAutoTrackViewPathProperty>

/// 判断 ReactNative 元素是否可点击
- (BOOL)zalldata_clickableForRNView;

/// 判断一个 view 是否显示
- (BOOL)zalldata_isVisible;

@end

@interface UIScrollView (ZAElementPath)<ZAVisualizedExtensionProperty>
@end

@interface WKWebView (ZAElementPath)<ZAVisualizedViewPathProperty>

@end

@interface UIWindow (ZAElementPath)<ZAVisualizedViewPathProperty>
@end

@interface ZAWebElementView (ZAElementPath)<ZAVisualizedViewPathProperty>
@end

#pragma mark - UIControl
@interface UISwitch (ZAElementPath)<ZAVisualizedViewPathProperty>
@end

@interface UIStepper (ZAElementPath)<ZAVisualizedViewPathProperty>
@end

@interface UISegmentedControl(ZAElementPath)<ZAAutoTrackViewPathProperty>
@end

@interface UISlider (ZAElementPath)<ZAVisualizedViewPathProperty>
@end

@interface UIPageControl (ZAElementPath)<ZAVisualizedViewPathProperty>
@end

#pragma mark - TableView & Cell
@interface UITableView (ZAElementPath)<ZAVisualizedViewPathProperty>
@end

@interface UITableViewHeaderFooterView (ZAElementPath)
@end

@interface UICollectionView (ZAElementPath)<ZAVisualizedViewPathProperty>
@end

@interface UITableViewCell (ZAElementPath)<ZAAutoTrackViewProperty>
@end

@interface UICollectionViewCell (ZAElementPath)<ZAAutoTrackViewProperty>
@end

NS_ASSUME_NONNULL_END
