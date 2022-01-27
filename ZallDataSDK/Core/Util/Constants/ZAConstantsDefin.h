//
// ZAConstantsDefin.h
// ZallDataSDK
//
// Created by guo on 2021/12/28.
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define ZAPropertyError(errorCode, fromat, ...) \
    [NSError errorWithDomain:@"ZallDataSDKErrorDomain" \
                        code:errorCode \
                    userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:fromat,##__VA_ARGS__]}] \


#pragma mark - Track Timer
FOUNDATION_EXPORT NSString * const kZAEventIdSuffix;

#pragma mark - event
FOUNDATION_EXPORT NSString * const kZAEventTime;
FOUNDATION_EXPORT NSString * const kZAEventTrackId;
FOUNDATION_EXPORT NSString * const kZAEventName;
FOUNDATION_EXPORT NSString * const kZAEventDistinctId;
FOUNDATION_EXPORT NSString * const kZAEventProperties;
FOUNDATION_EXPORT NSString * const kZAEventType;
FOUNDATION_EXPORT NSString * const kZAEventLib;
FOUNDATION_EXPORT NSString * const kZAEventProject;
FOUNDATION_EXPORT NSString * const kZAEventToken;
FOUNDATION_EXPORT NSString * const kZAEventHybridH5;
FOUNDATION_EXPORT NSString * const kZAEventLoginId;
FOUNDATION_EXPORT NSString * const kZAEventAnonymousId;
FOUNDATION_EXPORT NSString * const kZAEventIdentities;

#pragma mark - Item
FOUNDATION_EXPORT NSString * const ZA_EVENT_ITEM_TYPE;
FOUNDATION_EXPORT NSString * const ZA_EVENT_ITEM_ID;
FOUNDATION_EXPORT NSString * const ZA_EVENT_ITEM_SET;
FOUNDATION_EXPORT NSString * const ZA_EVENT_ITEM_DELETE;

#pragma mark - event name
// App 启动或激活
FOUNDATION_EXPORT NSString * const kZAEventNameAppStart;
// App 退出或进入后台
FOUNDATION_EXPORT NSString * const kZAEventNameAppEnd;
// App 浏览页面
FOUNDATION_EXPORT NSString * const kZAEventNameAppViewScreen;
// App 元素点击
FOUNDATION_EXPORT NSString * const kZAEventNameAppClick;
// web 元素点击
FOUNDATION_EXPORT NSString * const kZAEventNameWebClick;

// 自动追踪相关事件及属性
FOUNDATION_EXPORT NSString * const kZAEventNameAppStartPassively;

FOUNDATION_EXPORT NSString * const kZAEventNameSignUp;

FOUNDATION_EXPORT NSString * const kZAEventNameAppCrashed;

FOUNDATION_EXPORT NSString * const kZAEventNameAppTrackingClose;


// 远程控制配置变化
FOUNDATION_EXPORT NSString * const kZAEventNameAppRemoteConfigChanged;

// 绑定事件
FOUNDATION_EXPORT NSString * const kZAEventNameBind;
// 解绑事件
FOUNDATION_EXPORT NSString * const kZAEventNameUnbind;

#pragma mark - app install property
FOUNDATION_EXPORT NSString * const ZA_EVENT_PROPERTY_APP_INSTALL_SOURCE;
FOUNDATION_EXPORT NSString * const ZA_EVENT_PROPERTY_APP_INSTALL_DISABLE_CALLBACK;
FOUNDATION_EXPORT NSString * const ZA_EVENT_PROPERTY_APP_INSTALL_FIRST_VISIT_TIME;
#pragma mark - autoTrack property
// App 浏览页面 Url
FOUNDATION_EXPORT NSString * const kZAEventPropertyScreenUrl;
// App 浏览页面 Referrer Url
FOUNDATION_EXPORT NSString * const kZAEventPropertyScreenReferrerUrl;
FOUNDATION_EXPORT NSString * const kZAEventPropertyElementId;
FOUNDATION_EXPORT NSString * const kZAEventPropertyScreenName;
FOUNDATION_EXPORT NSString * const kZAEventPropertyTitle;
FOUNDATION_EXPORT NSString * const kZAEventPropertyElementPosition;
FOUNDATION_EXPORT NSString * const kZAEventPropertyElementSelector;

FOUNDATION_EXPORT NSString * const kZAEeventPropertyReferrerTitle;

// 模糊路径
FOUNDATION_EXPORT NSString * const kZAEventPropertyElementPath;
FOUNDATION_EXPORT NSString * const kZAEventPropertyElementContent;
FOUNDATION_EXPORT NSString * const kZAEventPropertyElementType;
// 远程控制配置信息
FOUNDATION_EXPORT NSString * const kZAEventPropertyAppRemoteConfig;

#pragma mark - common property
FOUNDATION_EXPORT NSString * const kZAEventCommonOptionalPropertyProject;
FOUNDATION_EXPORT NSString * const kZAEventCommonOptionalPropertyToken;
FOUNDATION_EXPORT NSString * const kZAEventCommonOptionalPropertyTime;
//卓尔成立时间，2015-05-15 10:24:00.000，某些时间戳判断（毫秒）
FOUNDATION_EXPORT int64_t const kZAEventCommonOptionalPropertyTimeInt;

#pragma mark--lib method
FOUNDATION_EXPORT NSString * const kZALibMethodAuto;
FOUNDATION_EXPORT NSString * const kZALibMethodCode;

#pragma mark--track type
FOUNDATION_EXPORT NSString * const kZAEventTypeTrack;
FOUNDATION_EXPORT NSString * const kZAEventTypeSignup;
FOUNDATION_EXPORT NSString * const kZAEventTypeBind;
FOUNDATION_EXPORT NSString * const kZAEventTypeUnbind;

#pragma mark - profile
FOUNDATION_EXPORT NSString * const ZA_PROFILE_SET;
FOUNDATION_EXPORT NSString * const ZA_PROFILE_SET_ONCE;
FOUNDATION_EXPORT NSString * const ZA_PROFILE_UNSET;
FOUNDATION_EXPORT NSString * const ZA_PROFILE_DELETE;
FOUNDATION_EXPORT NSString * const ZA_PROFILE_APPEND;
FOUNDATION_EXPORT NSString * const ZA_PROFILE_INCREMENT;

#pragma mark - NSUserDefaults
FOUNDATION_EXPORT NSString * const ZA_HAS_TRACK_INSTALLATION;
FOUNDATION_EXPORT NSString * const ZA_HAS_TRACK_INSTALLATION_DISABLE_CALLBACK;

#pragma mark - bridge name
FOUNDATION_EXPORT NSString * const ZA_SCRIPT_MESSAGE_HANDLER_NAME;


FOUNDATION_EXPORT NSString * const kZAAppLifeCycleMonitorNewStateKey;
FOUNDATION_EXPORT NSString * const kZAAppLifeCycleMonitorOldStateKey;

FOUNDATION_EXPORT NSString * const kZAIdentities;
FOUNDATION_EXPORT NSString * const kZAIdentitiesLoginId;
FOUNDATION_EXPORT NSString * const kZAIdentitiesAnonymousId;
FOUNDATION_EXPORT NSString * const kZAIdentitiesCookieId;

//中国运营商 mcc 标识
FOUNDATION_EXPORT NSString* const ZACarrierChinaMCC;

#pragma mark - device
/// 设备 ID
FOUNDATION_EXPORT NSString * const kZAEventPresetPropertyDeviceId;
/// 运营商
FOUNDATION_EXPORT NSString * const ZAEventPresetPropertyCarrier;
/// 型号
FOUNDATION_EXPORT NSString * const ZAEventPresetPropertyModel;
/// 生产商
FOUNDATION_EXPORT NSString * const ZAEventPresetPropertyManufacturer;
/// 屏幕高
FOUNDATION_EXPORT NSString * const ZAEventPresetPropertyScreenHeight;
/// 屏幕宽
FOUNDATION_EXPORT NSString * const ZAEventPresetPropertyScreenWidth;

#pragma mark - os
/// 系统
FOUNDATION_EXPORT NSString * const ZAEventPresetPropertyOS;
/// 系统版本
FOUNDATION_EXPORT NSString * const ZAEventPresetPropertyOSVersion;

#pragma mark - app
/// 应用版本
FOUNDATION_EXPORT NSString * const kZAEventPresetPropertyAppVersion;
/// 应用 ID
FOUNDATION_EXPORT NSString * const ZAEventPresetPropertyAppID;
/// 应用名称
FOUNDATION_EXPORT NSString * const ZAEventPresetPropertyAppName;
/// 时区偏移量
FOUNDATION_EXPORT NSString * const ZAEventPresetPropertyTimezoneOffset;

#pragma mark - state
/// 网络类型
FOUNDATION_EXPORT NSString * const kZAEventPresetPropertyNetworkType;
/// 是否 WI-FI
FOUNDATION_EXPORT NSString * const kZAEventPresetPropertyWifi;
/// 是否首日
FOUNDATION_EXPORT NSString * const kZAEventPresetPropertyIsFirstDay;

#pragma mark - lib
/// SDK 类型
FOUNDATION_EXPORT NSString * const kZAEventPresetPropertyLib;
/// SDK 方法
FOUNDATION_EXPORT NSString * const kZAEventPresetPropertyLibMethod;
/// SDK 版本
FOUNDATION_EXPORT NSString * const kZAEventPresetPropertyLibVersion;
/// SDK 版本
FOUNDATION_EXPORT NSString * const kZAEventPresetPropertyLibDetail;

 
FOUNDATION_EXPORT NSString * const kZAIdentitiesUniqueID;
FOUNDATION_EXPORT NSString * const kZAIdentitiesUUID;
 

FOUNDATION_EXPORT NSString * const kZALoginIDKey;
FOUNDATION_EXPORT NSString * const kZAIdentitiesCacheType;

#pragma mark - App 状态即将改变

/// App 状态即将改变
FOUNDATION_EXPORT NSNotificationName const kZAAppLifeCycleMonitorWillChangeNotification;
/// App 状态已经改变
FOUNDATION_EXPORT NSNotificationName const kZAAppLifeCycleMonitorDidChangeNotification;


#pragma mark - SF related notifications
FOUNDATION_EXPORT NSNotificationName const ZA_TRACK_EVENT_NOTIFICATION;
FOUNDATION_EXPORT NSNotificationName const ZA_TRACK_LOGIN_NOTIFICATION;
FOUNDATION_EXPORT NSNotificationName const ZA_TRACK_LOGOUT_NOTIFICATION;
FOUNDATION_EXPORT NSNotificationName const ZA_TRACK_IDENTIFY_NOTIFICATION;
FOUNDATION_EXPORT NSNotificationName const ZA_TRACK_RESETANONYMOUSID_NOTIFICATION;
FOUNDATION_EXPORT NSNotificationName const ZA_TRACK_EVENT_H5_NOTIFICATION;

#pragma mark - ABTest related notifications
FOUNDATION_EXPORT NSNotificationName const ZA_H5_BRIDGE_NOTIFICATION;

FOUNDATION_EXPORT NSNotificationName const ZA_H5_MESSAGE_NOTIFICATION;

#pragma mark - other
// 远程配置更新
FOUNDATION_EXPORT NSNotificationName const ZA_REMOTE_CONFIG_MODEL_CHANGED_NOTIFICATION;

// App 内嵌 H5 接收可视化相关 H5 页面元素信息
FOUNDATION_EXPORT NSNotificationName const ZA_VISUALIZED_H5_MESSAGE_NOTIFICATION;

//page leave
FOUNDATION_EXPORT NSString * const kZAPageLeaveTimestamp;
FOUNDATION_EXPORT NSString * const kZAPageLeaveAutoTrackProperties;
FOUNDATION_EXPORT NSString * const kZAEventDurationProperty;
FOUNDATION_EXPORT NSString * const kZAEventNameAppPageLeave;


FOUNDATION_EXPORT NSInteger kZAEventNameMaxLength;
FOUNDATION_EXPORT NSInteger kZAPropertyValueMaxLength;

FOUNDATION_EXPORT NSString *const kZAProperNameValidateRegularExpression;





NS_ASSUME_NONNULL_END
