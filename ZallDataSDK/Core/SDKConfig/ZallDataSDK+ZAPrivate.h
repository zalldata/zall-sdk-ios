//
// ZallDataSDK+ZAPrivate.h
// ZallDataSDK
//
// Created by guo on 2022/1/13.
// Copyright © 2022 Zall Data Co., Ltd. All rights reserved.
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

#import "ZallDataSDK.h"
#import "ZAAppLifeCycleMonitor.h"
#import "ZAPresetProperty.h"
#import "ZASuperProperty.h"
#import "ZANetwork.h"
#import "ZATrackerAppTimer.h"
#import "ZAIdentifier.h"
#import "ZAEventTracker.h"
#import "ZAModuleManager.h"
#import "ZAReachability.h"
#import "ZAReferrerManager.h"
#import "ZAEventTrackObject.h"
#import "ZAQuickUtil.h"
#import "ZAQueueManage.h"
#import "ZAUtilCheck.h"
#import "ZALog.h"
#import "ZAConstantsDefin.h"
#import "ZAJSONUtil.h"




NS_ASSUME_NONNULL_BEGIN

@interface ZallDataSDK ()

@property(nonatomic, strong) ZAAppLifeCycleMonitor * appLifeCycle;
@property(nonatomic, strong) ZAPresetProperty *presetProperty;
@property(nonatomic, strong) ZASuperProperty *superProperty;
@property(nonatomic, strong) ZAIdentifier * identifier;
@property(nonatomic, strong) ZANetwork * network;

@property (nonatomic, strong) ZATrackerAppTimer *trackTimer;
@property (nonatomic, strong) ZAEventTracker *eventTracker;

@property (nonatomic, copy) BOOL (^trackEventCallback)(NSString *, NSMutableDictionary<NSString *, id> *);


/**
 * @abstract
 * 返回之前所初始化好的单例
 *
 * @see launchingWithConfigOptions:
 *
 * @return 返回的单例
 */
+(instancetype)sdkInstance;

/// 开始计时
- (void)startFlushTimer;
/// 取消计时
- (void)stopForceTimer;

/// 事件采集: 切换到 serialQueue 中执行
/// @param object 事件对象
/// @param properties 事件属性
- (void)asyncTrackEventObject:(ZAEventBaseObject *)object properties:(NSDictionary * _Nullable  )properties;

/// 触发事件
/// @param object 事件对象
/// @param properties 事件属性
- (void)trackEventObject:(ZAEventBaseObject *)object properties:(NSDictionary *)properties;


@end

NS_ASSUME_NONNULL_END

/// 其它私有载入
#if __has_include("ZallDataSDK+ZAJSPrivate.h")
#import "ZallDataSDK+ZAJSPrivate.h"
#endif
