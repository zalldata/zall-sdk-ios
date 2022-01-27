//
// ZallDataSDK+Business.h
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


/**
 * @abstract
 * 设置 Cookie
 *
 * @param cookie NSString cookie
 * @param encode BOOL 是否 encode
 */
- (void)setCookie:(NSString *)cookie withEncode:(BOOL)encode;

/**
 * @abstract
 * 返回已设置的 Cookie
 *
 * @param decode BOOL 是否 decode
 * @return NSString cookie
 */
- (NSString *)getCookieWithDecode:(BOOL)decode;

/**
 * @abstract
 * 获取最后一个页面的ScreenUrl
 *
 * @return LastScreenUrl
 */
- (NSString *)getLastScreenUrl ;


#pragma mark - Properties
/**
 * @abstract
 * 返回预置的属性
 *
 * @return NSDictionary 返回预置的属性
 */
- (NSDictionary *)getPresetProperties;


/**
 * @abstract
 * 注册公共属性
 *
 * @discussion
 * 当 track 的 Properties，superProperties 和 SDK 自动生成的 automaticProperties 有相同的 key 时，遵循如下的优先级：
 *    track.properties > superProperties > automaticProperties
 * 另外，当这个接口被多次调用时，是用新传入的数据去 merge 先前的数据，并在必要时进行 merge
 * 例如，在调用接口前，dict 是 @{@"a":1, @"b": "bbb"}，传入的 dict 是 @{@"b": 123, @"c": @"asd"}，则 merge 后的结果是
 * @{"a":1, @"b": 123, @"c": @"asd"}，同时，SDK 会自动将 superProperties 保存到文件中，下次启动时也会从中读取
 *
 * @param propertyDict 公共属性的 dict
 */
- (void)registerSuperProperties:(NSDictionary *)propertyDict;

/**
 * @abstract
 * 用来设置事件的动态公共属性
 *
 * @discussion
 * 当 track 的 Properties，superProperties 和 SDK 自动生成的 automaticProperties 有相同的 key 时，遵循如下的优先级：
 *    track.properties > dynamicSuperProperties > superProperties > automaticProperties
 *
 * 例如，track.properties 是 @{@"a":1, @"b": "bbb"}，返回的 eventCommonProperty 是 @{@"b": 123, @"c": @"asd"}，
 * superProperties 是  @{@"a":1, @"b": "bbb",@"c":@"ccc"}，automaticProperties 是 @{@"a":1, @"b": "bbb",@"d":@"ddd"},
 * 则 merge 后的结果是 @{"a":1, @"b": "bbb", @"c": @"asd",@"d":@"ddd"}
 * 返回的 NSDictionary 需满足以下要求
 * 重要：1,key 必须是 NSString
 *          2,key 的名称必须符合要求
 *          3,value 的类型必须是 NSString、NSNumber、NSSet、NSArray、NSDate
 *          4,value 类型为 NSSet、NSArray 时，NSSet、NSArray 中的所有元素必须为 NSString
 * @param dynamicSuperProperties 用来返回事件的动态公共属性
 */
- (void)registerDynamicSuperProperties:(NSDictionary<NSString *, id> *(^)(void))dynamicSuperProperties;

/**
 * @abstract
 * 注销公共属性
 *
 * @param property 待删除的 property 的名称
 */
- (void)unregisterSuperProperty:(NSString *)property;

/**
 * @abstract
 * 清空公共属性
 */
- (void)clearSuperProperties;

/**
 * @abstract
 * 拿到当前的 superProperty 的副本
 *
 * @return 当前的 superProperty 的副本
 */
- (NSDictionary *)currentSuperProperties;

#pragma mark loginId

/**
 * @abstract
 * 登录，设置当前用户的 loginId
 *
 * @param loginId 当前用户的 loginId
 */
- (void)login:(NSString *)loginId;

/**
 *@abstract 获取到当前用户ID
 *
 *@discussion 获取到当前用户ID
 *
 *@return loginId
 */
- (NSString *)loginId;

/**
 登录，设置当前用户的 loginId

 触发 $SignUp 事件。

 @param loginId 当前用户的登录 id
 @param properties $SignUp 事件的事件属性
 */
- (void)login:(NSString *)loginId withProperties:(NSDictionary * _Nullable )properties;

/**
 * @abstract
 * 注销，清空当前用户的 loginId
 *
 */
- (void)logout;

/**
 * @property
 *
 * @abstract
 * 获取用户的唯一用户标识
 */
- (NSString *)distinctId;

/**
 * @abstract
 * 获取匿名 id
 *
 * @return anonymousId 匿名 id
 */
- (NSString *)anonymousId;

/**
 * @abstract
 * 重置默认匿名 id
 */
- (void)resetAnonymousId;

 
/**
 @abstract
 指定 匿名ID
 @param anonymousId 当前用户的 anonymousId
 */
- (void)identify:(NSString *)anonymousId;

/**
 @abstract
 bind 绑定

 @param key 绑定业务 ID 的键名
 @param value 绑定业务 ID 的键值
 */
- (void)bind:(NSString *)key value:(NSString *)value;

/**
 @abstract
 bind 解绑

 @param key 解绑业务 ID 的键名
 @param value 解绑业务 ID 的键值
 */
- (void)unbind:(NSString *)key value:(NSString *)value;


#pragma mark Item 操作

/**
 设置 item
 @param itemType item 类型
 @param itemId item Id
 @param propertyDict item 相关属性
 */
- (void)itemSetWithType:(NSString *)itemType itemId:(NSString *)itemId properties:(nullable NSDictionary <NSString *, id> *)propertyDict;

/**
 删除 item

 @param itemType item 类型
 @param itemId item Id
 */
- (void)itemDeleteWithType:(NSString *)itemType itemId:(NSString *)itemId;


#pragma mark - Profile
/**
 * @abstract
 * 直接设置用户的一个或者几个 Profiles
 *
 * @discussion
 * 这些 Profile 的内容用一个 NSDictionary 来存储
 * 其中的 key 是 Profile 的名称，必须是 NSString
 * Value 则是 Profile 的内容，只支持 NSString、NSNumberNSSet、NSArray、NSDate 这些类型
 * 特别的，NSSet 或者 NSArray 类型的 value 中目前只支持其中的元素是 NSString
 * 如果某个 Profile 之前已经存在了，则这次会被覆盖掉；不存在，则会创建
 *
 * @param profileDict 要替换的那些 Profile 的内容
 */
- (void)set:(NSDictionary *)profileDict;

/**
 * @abstract
 * 直接设置用户的pushId
 *
 * @discussion
 * 设置用户的 pushId 比如 @{@"jgId":pushId}，并触发 profileSet 设置对应的用户属性。
 * 当 disctinct_id 或者 pushId 没有发生改变的时,不会触发 profileSet。
 * @param pushTypeKey  pushId 的 key
 * @param pushId  pushId 的值
 */
- (void)profilePushKey:(NSString *)pushTypeKey pushId:(NSString *)pushId;

/**
 * @abstract
 * 删除用户设置的 pushId
 *
 * *@discussion
 * 删除用户设置的 pushId 比如 @{@"jgId":pushId}，并触发 profileUnset 删除对应的用户属性。
 * 当 disctinct_id 未找到本地缓存记录时, 不会触发 profileUnset。
 * @param pushTypeKey  pushId 的 key
 */
- (void)profileUnsetPushKey:(NSString *)pushTypeKey;

/**
 * @abstract
 * 首次设置用户的一个或者几个 Profiles
 *
 * @discussion
 * 与 set 接口不同的是，如果该用户的某个 Profile 之前已经存在了，会被忽略；不存在，则会创建
 *
 * @param profileDict 要替换的那些 Profile 的内容
 */
- (void)setOnce:(NSDictionary *)profileDict;

/**
 * @abstract
 * 设置用户的单个 Profile 的内容
 *
 * @discussion
 * 如果这个 Profile 之前已经存在了，则这次会被覆盖掉；不存在，则会创建
 *
 * @param profile Profile 的名称
 * @param content Profile 的内容
 */
- (void)set:(NSString *) profile to:(id)content;

/**
 * @abstract
 * 首次设置用户的单个 Profile 的内容
 *
 * @discussion
 * 与 set 类接口不同的是，如果这个 Profile 之前已经存在了，则这次会被忽略；不存在，则会创建
 *
 * @param profile Profile 的名称
 * @param content Profile 的内容
 */
- (void)setOnce:(NSString *) profile to:(id)content;

/**
 * @abstract
 * 删除某个 Profile 的全部内容
 *
 * @discussion
 * 如果这个 Profile 之前不存在，则直接忽略
 *
 * @param profile Profile 的名称
 */
- (void)unset:(NSString *) profile;

/**
 * @abstract
 * 给一个数值类型的 Profile 增加一个数值
 *
 * @discussion
 * 只能对 NSNumber 类型的 Profile 调用这个接口，否则会被忽略
 * 如果这个 Profile 之前不存在，则初始值当做 0 来处理
 *
 * @param profile  待增加数值的 Profile 的名称
 * @param amount   要增加的数值
 */
- (void)increment:(NSString *)profile by:(NSNumber *)amount;

/**
 * @abstract
 * 给多个数值类型的 Profile 增加数值
 *
 * @discussion
 * profileDict 中，key 是 NSString ，value 是 NSNumber
 * 其它与 - (void)increment:by: 相同
 *
 * @param profileDict 多个
 */
- (void)increment:(NSDictionary *)profileDict;

/**
 * @abstract
 * 向一个 NSSet 或者 NSArray 类型的 value 添加一些值
 *
 * @discussion
 * 如前面所述，这个 NSSet 或者 NSArray 的元素必须是 NSString，否则，会忽略
 * 同时，如果要 append 的 Profile 之前不存在，会初始化一个空的 NSSet 或者 NSArray
 *
 * @param profile profile
 * @param content description
 */
- (void)append:(NSString *)profile by:(NSObject<NSFastEnumeration> *)content;

/**
 * @abstract
 * 删除当前这个用户的所有记录
 */
- (void)deleteUser;

/**
 * @abstract
 * 清除 keychain 缓存数据
 *
 * @discussion
 * 注意：清除 keychain 中 kZAService 名下的数据，包括 distinct_id 标记。
 *
 */
- (void)clearKeychainData ;


/**
 * @abstract
 * 获取最后设置的属性
 *
 * @return LastScreenTrackProperties
 */
- (NSDictionary *)getLastScreenTrackProperties ;


@end

NS_ASSUME_NONNULL_END
