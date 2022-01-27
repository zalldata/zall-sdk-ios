//
// UIView+ZAVisualPropertiey.h
// ZallDataSDK
//
// Created by guo on 2021/1/6.
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

#import <UIKit/UIKit.h>
#import "ZAViewNode.h"

@interface UIView (ZAVisualProperties)

- (void)zalldata_visualize_didMoveToSuperview;

- (void)zalldata_visualize_didMoveToWindow;

- (void)zalldata_visualize_didAddSubview:(UIView *)subview;

- (void)zalldata_visualize_bringSubviewToFront:(UIView *)view;

- (void)zalldata_visualize_sendSubviewToBack:(UIView *)view;

/// 视图对应的节点
@property (nonatomic, strong) ZAViewNode *zalldata_viewNode;

@end

@interface UITableViewCell(ZAVisualProperties)

- (void)zalldata_visualize_prepareForReuse;

@end

@interface UICollectionViewCell(ZAVisualProperties)

- (void)zalldata_visualize_prepareForReuse;

@end

@interface UITableViewHeaderFooterView(ZAVisualProperties)

- (void)zalldata_visualize_prepareForReuse;

@end

@interface UIWindow (ZAVisualProperties)

- (void)zalldata_visualize_becomeKeyWindow;

@end


@interface UITabBar (ZAVisualProperties)
- (void)zalldata_visualize_setSelectedItem:(UITabBarItem *)selectedItem;
@end


#pragma mark - 属性内容
@interface UIView (PropertiesContent)

@property (nonatomic, copy, readonly) NSString *zalldata_propertyContent;

@end
