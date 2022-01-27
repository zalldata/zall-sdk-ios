//
// ZallDataSDK+ZATrack.h
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

NS_ASSUME_NONNULL_BEGIN

@interface ZallDataSDK ()
#pragma mark - trackTimer
/**
 * 开始事件计时
 *
 * @discussion
 * 若需要统计某个事件的持续时间，先在事件开始时调用 trackTimerStart:"Event" * 记录事件开始时间，该方法并不会真正发送事件；
 * 随后在事件结束时，调用 trackTimerEnd:"Event" withProperties:properties，
 * SDK 会追踪 "Event" 事件，并自动将事件持续时间记录在事件属性 "event_duration" * 中，时间单位为秒。
 *
 * @param event 事件名称
 * @return 返回计时事件的 eventId，用于交叉计时场景。普通计时可忽略
 */
- (nullable NSString *)trackTimerStart:(NSString *)event;

/**
 * 结束事件计时
 *
 * @discussion
 * 多次调用 trackTimerEnd: 时，以首次调用为准
 *
 * @param event 事件名称或事件的 eventId
 * @param propertyDict 自定义属性
 */
- (void)trackTimerEnd:(NSString *)event withProperties:(nullable NSDictionary *)propertyDict;

/**
 * 结束事件计时
 *
 * @discussion
 * 多次调用 trackTimerEnd: 时，以首次调用为准
 *
 * @param event 事件名称或事件的 eventId
 */
- (void)trackTimerEnd:(NSString *)event;

/**
 * 暂停事件计时
 *
 * @discussion
 * 多次调用 trackTimerPause: 时，以首次调用为准。
 *
 * @param event 事件名称或事件的 eventId
 */
- (void)trackTimerPause:(NSString *)event;

/**
 * 恢复事件计时
 *
 * @discussion
 * 多次调用 trackTimerResume: 时，以首次调用为准。
 *
 * @param event 事件名称或事件的 eventId
 */
- (void)trackTimerResume:(NSString *)event;

/**
 * 删除事件计时
 *
 * @discussion
 * 多次调用 removeTimer: 时，只有首次调用有效。
 *
 * @param event 事件名称或事件的 eventId
 */
- (void)trackRemoveTimer:(NSString *)event;

/**
 * 清除所有事件计时器
 */
- (void)clearTrackTimer;


#pragma mark track event

/**
 @abstract
 * Track App Extension groupIdentifier 中缓存的数据
 *
 * @param groupIdentifier groupIdentifier
 * @param completion  完成 track 后的 callback
 */
- (void)trackEventFromExtensionWithGroupIdentifier:(NSString *)groupIdentifier completion:(void (^)(NSString *groupIdentifier, NSArray *events)) completion;

/**
 * @abstract
 * 调用 track 接口，追踪一个无私有属性的 event
 *
 * @param event event 的名称
 */
- (void)track:(NSString *)event;

/**
 * @abstract
 * 调用 track 接口，追踪一个带有属性的 event
 *
 * @discussion
 * propertyDict 是一个 Map。
 * 其中的 key 是 Property 的名称，必须是 NSString
 * value 则是 Property 的内容，只支持 NSString、NSNumber、NSSet、NSArray、NSDate 这些类型
 * 特别的，NSSet 或者 NSArray 类型的 value 中目前只支持其中的元素是 NSString
 *
 * @param event             event的名称
 * @param propertyDict     event的属性
 */
- (void)track:(NSString *)event withProperties:(nullable NSDictionary *)propertyDict;

/**
 * @abstract
 * 修改入库之前的事件属性
 *
 * @param willBlock 传入事件名称和事件属性，可以修改或删除事件属性。请返回一个 BOOL 值，true 表示事件将入库， false 表示事件将被抛弃
 */
- (void)trackEventWillSave:(BOOL (^)(NSString *eventName, NSMutableDictionary<NSString *, id> *properties))willBlock;

/**
 * @abstract
 * 强制上传埋点事件
 *
 * @discussion
 * 主动调用 flush 接口，则不论 flushInterval 和 flushBulkSize 限制条件是否满足，都尝试向服务器上传一次数据
 */
- (void)trackForceSendAll;

/**
 * @abstract
 * 删除本地缓存的全部事件
 *
 * @discussion
 * 一旦调用该接口，将会删除本地缓存的全部事件，请慎用！
 */
- (void)trackDeleteAll;
 

@end

NS_ASSUME_NONNULL_END
