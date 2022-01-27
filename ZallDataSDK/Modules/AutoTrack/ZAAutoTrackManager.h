//
// ZAAutoTrackManager.h
// ZallDataSDK
//
// Created by guo on 2021/4/2.
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
#import "ZallDataSDK.h"
#import "ZATrackerAppClick.h"
#import "ZAModuleManagerProtocol.h"
#import "ZAAutoTrackProperty.h"
#import "ZATrackerAppViewScreen.h"
#import "ZATrackerAppPageLeave.h"
#import "ZAAutoTrackPropertyProtocol.h"
#import "ZATrackerAppStart.h"
#import "ZATrackerAppEnd.h"
#import "ZATrackerAppTimer.h"
#import "ZAConstantsEnum.h"
NS_ASSUME_NONNULL_BEGIN

/// 自动触发状态
typedef NS_ENUM(NSInteger, ZAAutoTrackModeState) {
    ZAAutoTrackModeStateDefault      = -1,
    ZAAutoTrackModeStateDisabledAll  =  0,
    ZAAutoTrackModeStateEnabledAll   = 15,
};

@interface ZAAutoTrackManager : NSObject <ZAModuleProtocol,ZAModuleAutoTrackProtocol>


@property (nonatomic, strong) ZATrackerAppStart         * trackerappStart;
@property (nonatomic, strong) ZATrackerAppEnd           * trackerAppEnd;
@property (nonatomic, strong) ZATrackerAppClick         * trackerAppClick;
@property (nonatomic, strong) ZATrackerAppViewScreen    * trackerAppViewScreen;
@property (nonatomic, strong) ZATrackerAppPageLeave     * trackerAppPageLeave;


#pragma mark - Public

/// 是否忽略某些全埋点
/// @param eventType 全埋点类型
- (BOOL)isAutoTrackEventTypeIgnored:(ZAAutoTrackEventType)eventType;

/// 更新全埋点事件类型
- (void)updateAutoTrackEventType;

/// 校验可视化全埋点元素能否选中
/// @param obj 控件元素
/// @return 返回校验结果
- (BOOL)isGestureVisualView:(id)obj;

///  在间隔时间内是否采集 $AppClick 全埋点
+ (BOOL)isValidAppClickForObject:(id<ZAAutoTrackViewProperty>)object;

@end

NS_ASSUME_NONNULL_END
 
