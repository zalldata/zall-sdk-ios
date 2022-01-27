//
// ZAConstantsDefin.m
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

#import "ZAConstantsDefin.h"


#pragma mark - event name
// App 启动或激活
NSString * const kZAEventNameAppStart = @"$AppStart";
// App 退出或进入后台
NSString * const kZAEventNameAppEnd = @"$AppEnd";
// App 浏览页面
NSString * const kZAEventNameAppViewScreen = @"$AppViewScreen";
// App 元素点击
NSString * const kZAEventNameAppClick = @"$AppClick";
// web 元素点击
NSString * const kZAEventNameWebClick = @"$WebClick";

// 自动追踪相关事件及属性
NSString * const kZAEventNameAppStartPassively = @"$AppStartPassively";

NSString * const kZAEventNameSignUp = @"$SignUp";

NSString * const kZAEventNameAppCrashed = @"AppCrashed";

NSString * const kZAEventNameAppTrackingClose= @"$AppDataTrackingClose";


// 远程控制配置变化
NSString * const kZAEventNameAppRemoteConfigChanged = @"$AppRemoteConfigChanged";

// 绑定事件
NSString * const kZAEventNameBind = @"$BindID";
// 解绑事件
NSString * const kZAEventNameUnbind = @"$UnbindID";

#pragma mark - app install property
NSString * const ZA_EVENT_PROPERTY_APP_INSTALL_SOURCE = @"$ios_install_source";
NSString * const ZA_EVENT_PROPERTY_APP_INSTALL_DISABLE_CALLBACK = @"$ios_install_disable_callback";
NSString * const ZA_EVENT_PROPERTY_APP_INSTALL_FIRST_VISIT_TIME = @"$first_visit_time";
#pragma mark - autoTrack property
// App 浏览页面 Url
NSString * const kZAEventPropertyScreenUrl = @"$url";
// App 浏览页面 Referrer Url
NSString * const kZAEventPropertyScreenReferrerUrl = @"$referrer";
NSString * const kZAEventPropertyElementId = @"$element_id";
NSString * const kZAEventPropertyScreenName = @"$screen_name";
NSString * const kZAEventPropertyTitle = @"$title";
NSString * const kZAEventPropertyElementPosition = @"$element_position";
NSString * const kZAEventPropertyElementSelector = @"$element_selector";

NSString * const kZAEeventPropertyReferrerTitle = @"$referrer_title";

// 模糊路径
NSString * const kZAEventPropertyElementPath = @"$element_path";
NSString * const kZAEventPropertyElementContent = @"$element_content";
NSString * const kZAEventPropertyElementType = @"$element_type";
// 远程控制配置信息
NSString * const kZAEventPropertyAppRemoteConfig = @"$app_remote_config";

#pragma mark - common property
NSString * const kZAEventCommonOptionalPropertyProject = @"$project";
NSString * const kZAEventCommonOptionalPropertyToken = @"$token";
NSString * const kZAEventCommonOptionalPropertyTime = @"$time";
int64_t const kZAEventCommonOptionalPropertyTimeInt = 1431656640000;


//中国运营商 mcc 标识
NSString* const ZACarrierChinaMCC = @"460";

#pragma mark - device
/// 设备 ID
NSString * const kZAEventPresetPropertyDeviceId = @"$device_id";
/// 运营商
NSString * const ZAEventPresetPropertyCarrier = @"$carrier";
/// 型号
NSString * const ZAEventPresetPropertyModel = @"$model";
/// 生产商
NSString * const ZAEventPresetPropertyManufacturer = @"$manufacturer";
/// 屏幕高
NSString * const ZAEventPresetPropertyScreenHeight = @"$screen_height";
/// 屏幕宽
NSString * const ZAEventPresetPropertyScreenWidth = @"$screen_width";

#pragma mark - os
/// 系统
NSString * const ZAEventPresetPropertyOS = @"$os";
/// 系统版本
NSString * const ZAEventPresetPropertyOSVersion = @"$os_version";

#pragma mark - app
/// 应用版本
NSString * const kZAEventPresetPropertyAppVersion = @"$app_version";
/// 应用 ID
NSString * const ZAEventPresetPropertyAppID = @"$app_id";
/// 应用名称
NSString * const ZAEventPresetPropertyAppName = @"$app_name";
/// 时区偏移量
NSString * const ZAEventPresetPropertyTimezoneOffset = @"$timezone_offset";

#pragma mark - state
/// 网络类型
NSString * const kZAEventPresetPropertyNetworkType = @"$network_type";
/// 是否 WI-FI
NSString * const kZAEventPresetPropertyWifi = @"$wifi";
/// 是否首日
NSString * const kZAEventPresetPropertyIsFirstDay = @"$is_first_day";

#pragma mark - lib
/// SDK 类型
NSString * const kZAEventPresetPropertyLib = @"$lib";
/// SDK 方法
NSString * const kZAEventPresetPropertyLibMethod = @"$lib_method";
/// SDK 版本
NSString * const kZAEventPresetPropertyLibVersion = @"$lib_version";
/// SDK 版本
NSString * const kZAEventPresetPropertyLibDetail = @"$lib_detail";


#pragma mark - Track Timer
NSString *const kZAEventIdSuffix = @"_ZATimer";

#pragma mark - event
NSString * const kZAEventTime = @"time";
NSString * const kZAEventTrackId = @"_track_id";
NSString * const kZAEventName = @"event";
NSString * const kZAEventDistinctId = @"distinct_id";
NSString * const kZAEventProperties = @"properties";
NSString * const kZAEventType = @"type";
NSString * const kZAEventLib = @"lib";
NSString * const kZAEventProject = @"project";
NSString * const kZAEventToken = @"token";
NSString * const kZAEventHybridH5 = @"_hybrid_h5";
NSString * const kZAEventLoginId = @"login_id";
NSString * const kZAEventAnonymousId = @"anonymous_id";
NSString * const kZAEventIdentities = @"identities";

#pragma mark - Item
NSString * const ZA_EVENT_ITEM_TYPE = @"item_type";
NSString * const ZA_EVENT_ITEM_ID = @"item_id";
NSString * const ZA_EVENT_ITEM_SET = @"item_set";
NSString * const ZA_EVENT_ITEM_DELETE = @"item_delete";


#pragma mark--lib method
NSString * const kZALibMethodAuto = @"autoTrack";
NSString * const kZALibMethodCode = @"code";

#pragma mark--track type
NSString * const kZAEventTypeTrack = @"track";
NSString * const kZAEventTypeSignup = @"track_signup";
NSString * const kZAEventTypeBind = @"track_id_bind";
NSString * const kZAEventTypeUnbind = @"track_id_unbind";

#pragma mark - profile
NSString * const ZA_PROFILE_SET = @"profile_set";
NSString * const ZA_PROFILE_SET_ONCE = @"profile_set_once";
NSString * const ZA_PROFILE_UNSET = @"profile_unset";
NSString * const ZA_PROFILE_DELETE = @"profile_delete";
NSString * const ZA_PROFILE_APPEND = @"profile_append";
NSString * const ZA_PROFILE_INCREMENT = @"profile_increment";


#pragma mark - NSUserDefaults
NSString * const ZA_HAS_TRACK_INSTALLATION = @"HasTrackInstallation";
NSString * const ZA_HAS_TRACK_INSTALLATION_DISABLE_CALLBACK = @"HasTrackInstallationWithDisableCallback";

#pragma mark - bridge name
NSString * const ZA_SCRIPT_MESSAGE_HANDLER_NAME = @"zalldataNativeTracker";


#pragma mark - NotificationContent
NSString * const kZAAppLifeCycleMonitorNewStateKey = @"new";
NSString * const kZAAppLifeCycleMonitorOldStateKey = @"old";


#pragma mark - Identitie
NSString * const kZAIdentities = @"com.zalldata.identities";
NSString * const kZAIdentitiesLoginId = @"$identity_login_id";
NSString * const kZAIdentitiesAnonymousId = @"$identity_anonymous_id";
NSString * const kZAIdentitiesCookieId = @"$identity_cookie_id";

NSString * const kZAIdentitiesUniqueID = @"$identity_idfv";
NSString * const kZAIdentitiesUUID = @"$identity_ios_uuid";
NSString * const kZALoginIDKey = @"com.zalldata.loginidkey";
NSString * const kZAIdentitiesCacheType = @"Base64:";


#pragma mark - App 状态即将改变
NSNotificationName const kZAAppLifeCycleMonitorWillChangeNotification = @"kZAAppLifeCycleMonitorWillChangeNotification";
NSNotificationName const kZAAppLifeCycleMonitorDidChangeNotification = @"kZAAppLifeCycleMonitorDidChangeNotification";

#pragma mark - SF related notifications
NSNotificationName const ZA_TRACK_EVENT_NOTIFICATION = @"ZallDataSDKTrackEventNotification";
NSNotificationName const ZA_TRACK_LOGIN_NOTIFICATION = @"ZallDataSDKTrackLoginNotification";
NSNotificationName const ZA_TRACK_LOGOUT_NOTIFICATION = @"ZallDataSDKTrackLogoutNotification";
NSNotificationName const ZA_TRACK_IDENTIFY_NOTIFICATION = @"ZallDataSDKTrackIdentifyNotification";
NSNotificationName const ZA_TRACK_RESETANONYMOUSID_NOTIFICATION = @"ZallDataSDKTrackResetAnonymousIdNotification";
NSNotificationName const ZA_TRACK_EVENT_H5_NOTIFICATION = @"ZallDataSDKTrackEventFromH5Notification";

#pragma mark - ABTest related notifications
NSNotificationName const ZA_H5_BRIDGE_NOTIFICATION = @"ZallDataSDKRegisterJavaScriptBridgeNotification";

NSNotificationName const ZA_H5_MESSAGE_NOTIFICATION = @"ZallDataSDKMessageFromH5Notification";

#pragma mark - other
// 远程配置更新
NSNotificationName const ZA_REMOTE_CONFIG_MODEL_CHANGED_NOTIFICATION = @"cn.zalldata.ZA_REMOTE_CONFIG_MODEL_CHANGED_NOTIFICATION";

// App 内嵌 H5 接收可视化相关 H5 页面元素信息
NSNotificationName const ZA_VISUALIZED_H5_MESSAGE_NOTIFICATION = @"ZallDataSDKVisualizedMessageFromH5Notification";

//page leave
NSString * const kZAPageLeaveTimestamp = @"timestamp";
NSString * const kZAPageLeaveAutoTrackProperties = @"properties";
NSString * const kZAEventDurationProperty = @"event_duration";
NSString * const kZAEventNameAppPageLeave = @"$AppPageLeave";

//event name、property key、value max length
NSInteger kZAEventNameMaxLength = 100;
NSInteger kZAPropertyValueMaxLength = 1024;

NSString *const kZAProperNameValidateRegularExpression = @"^((?!^distinct_id$|^original_id$|^time$|^properties$|^id$|^first_id$|^second_id$|^users$|^events$|^event$|^user_id$|^date$|^datetime$|^user_tag.*|^user_group.*)[a-zA-Z_$][a-zA-Z\\d_$]*)$";


