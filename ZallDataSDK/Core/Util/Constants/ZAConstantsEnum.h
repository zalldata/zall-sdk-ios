//
// ZAConstantsEnum.h
// ZallDataSDK
//
// Created by guo on 2022/1/11.
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

#ifndef ZAConstantsEnum_h
#define ZAConstantsEnum_h

/**
 *@abstract AutoTrack 事件枚举
 *
 *@discussion ZAAutoTrackEventType
 *
 */
typedef NS_OPTIONS(NSInteger, ZAAutoTrackEventType) {
    ZAAutoTrackEventTypeNone            = 0,
    ZAAutoTrackEventTypeAppStart        = 1 << 0,
    ZAAutoTrackEventTypeAppEnd          = 1 << 1,
    ZAAutoTrackEventTypeAppClick        = 1 << 2,
    ZAAutoTrackEventTypeAppViewScreen   = 1 << 3,
    ZAAutoTrackEventTypeAppViewLeave    = 1 << 4,
    ZAAutoTrackEventTypeALL             = 0xFF,
};

/**
 * @abstract
 * Debug 模式，用于检验数据导入是否正确。该模式下，事件会逐条实时发送到 ZallDataSDK，并根据返回值检查
 * 数据导入是否正确。
 *
 * @discussion
 * Debug 模式的具体使用方式，请参考:
 *
 *
 * Debug模式有三种选项:
 *   ZADebugModeTypeOff - 关闭 DEBUG 模式
 *   ZADebugModeTypeOnly - 打开 DEBUG 模式，但该模式下发送的数据仅用于调试，不进行数据导入
 *   ZADebugModeTypeTrack - 打开 DEBUG 模式，并将数据导入到 ZallDataSDK 中
 */
typedef NS_ENUM(NSInteger, ZADebugModeType) {
    ZADebugModeTypeOff = 0,
    ZADebugModeTypeOnly,
    ZADebugModeTypeTrack,
};


#endif /* ZAConstantsEnum_h */
