//
//  ZAAutoTrackProperty.h
//  ZallDataSDK
//
//  Created by guo on 2019/4/23.
//  Copyright © 2019-2020 Zall Data Co., Ltd. All rights reserved.
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
    

#import <Foundation/Foundation.h>

#pragma mark - ViewController
@protocol ZAAutoTrackViewControllerProperty <NSObject>
@property (nonatomic, readonly) BOOL za_property_isIgnored;
@property (nonatomic, copy, readonly) NSString *za_property_screenName;
@property (nonatomic, copy, readonly) NSString *za_property_title;
@end

#pragma mark - View
@protocol ZAAutoTrackViewProperty <NSObject>
@property (nonatomic, readonly) BOOL za_property_isIgnored;
/// 记录上次触发点击事件的开机时间
@property (nonatomic, assign) NSTimeInterval za_property_timeIntervalForLastAppClick;

@property (nonatomic, copy, readonly) NSString *za_property_elementType;
@property (nonatomic, copy, readonly) NSString *za_property_elementContent;
@property (nonatomic, copy, readonly) NSString *za_property_elementId;

/// 元素位置，UISegmentedControl 中返回选中的 index，
@property (nonatomic, copy, readonly) NSString *za_property_elementPosition;

/// 获取 view 所在的 viewController，或者当前的 viewController
@property (nonatomic, readonly) UIViewController<ZAAutoTrackViewControllerProperty> *za_property_viewController;
@end

#pragma mark - Item
@protocol ZAAutoTrackItemProperty <ZAAutoTrackViewProperty>
- (NSString *)za_property_elementPositionWithIndexPath:(NSIndexPath *)indexPath;
@end

@protocol ZAAutoTrackProperties <NSObject>

@required
- (NSDictionary *)getTrackProperties;

@end

@protocol ZAScreenAutoTrackProperties <ZAAutoTrackProperties>

@required
- (NSString *)getScreenUrl;

@end
