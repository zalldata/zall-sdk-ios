//
// UIViewController+ZAElementPath.h
// ZallDataSDK
//
// Created by guo on 2021/3/15.
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ZAVisualizedViewPathProperty.h"

NS_ASSUME_NONNULL_BEGIN


@interface UIViewController (ZAElementPath)<ZAVisualizedViewPathProperty, ZAAutoTrackViewPathProperty>

- (void)zalldata_visualize_viewDidAppear:(BOOL)animated;

@end

@interface UIAlertController(ZAElementPath)<ZAAutoTrackViewPathProperty>

@end

@interface UITabBarController (ZAElementPath)<ZAVisualizedViewPathProperty>

@end

@interface UINavigationController (ZAElementPath)<ZAVisualizedViewPathProperty>

@end

@interface UIPageViewController (ZAElementPath)<ZAVisualizedViewPathProperty>

@end

NS_ASSUME_NONNULL_END
