//
// ZAConfigOptions.h
// ZallDataSDK
//
// Created by guo on 2021/12/29.
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
#import "ZASecurityPolicy.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZAConfigOptions : NSObject

/**
 *@abstract 初始化对象
 *
 *@discussion 必须使用此方法初始化
 *
 *@param serverURL 数据上报地址
 *
 *@param launchOptions launchOptions
 *
 *@return ZAConfigOptions对象
 */
+ (instancetype)configWithServerURL:(NSString *)serverURL launchOptions:(id)launchOptions ;

/// 返回初始化
+(instancetype)sharedInstance;


/// 禁用 init 初始化
- (instancetype)init NS_UNAVAILABLE;

/// 禁用 new 初始化
+ (instancetype)new NS_UNAVAILABLE;


/**
 @abstract
 用于评估是否为服务器信任的安全链接。

 @discussion
 默认使用 defaultPolicy
 */
@property (nonatomic, strong) ZASecurityPolicy *securityPolicy ;

/**
 * @abstract
 * 设置 发送 时网络发送策略
 *
 * @discussion
 * 默认 3G、4G、WI-FI 环境下都会尝试 flush
 */
@property (nonatomic) ZANetworkType sendNetworkPolicy;

/**
 * @property
 *
 * @abstract
 * 两次数据发送的最小时间间隔，单位毫秒
 *
 * @discussion
 * 默认值为 15 * 1000 毫秒， 在每次调用 track 和 profileSet 等接口的时候，
 * 都会检查如下条件，以判断是否向服务器上传数据:
 * 1. 是否 WIFI/3G/4G/5G 网络
 * 2. 是否满足以下数据发送条件之一:
 *   1) 与上次发送的时间间隔是否大于 flushInterval
 *   2) 本地缓存日志数目是否达到 flushBulkSize
 * 如果满足这两个条件之一，则向服务器发送一次数据；如果都不满足，则把数据加入到队列中，等待下次检查时把整个队列的内容一并发送。
 * 需要注意的是，为了避免占用过多存储，队列最多只缓存10000条数据。
 */
@property (nonatomic) NSInteger sendInterval;

/**
 * @property
 *
 * @abstract
 * 本地缓存的最大事件数目，当累积日志量达到阈值时发送数据
 *
 * @discussion
 * 默认值为 100，在每次调用 track 和 profileSet 等接口的时候，都会检查如下条件，以判断是否向服务器上传数据:
 * 1. 是否 WIFI/3G/4G/5G 网络
 * 2. 是否满足以下数据发送条件之一:
 *   1) 与上次发送的时间间隔是否大于 flushInterval
 *   2) 本地缓存日志数目是否达到 flushBulkSize
 * 如果同时满足这两个条件，则向服务器发送一次数据；如果不满足，则把数据加入到队列中，等待下次检查时把整个队列的内容一并发送。
 * 需要注意的是，为了避免占用过多存储，队列最多只缓存 10000 条数据。
 */
@property (nonatomic) NSInteger sendMaxSize;

/// 设置本地缓存最多事件条数，默认为 10000 条事件
@property (nonatomic) NSInteger cacheMaxSize;

/// 开启 log 打印
@property (nonatomic, assign) BOOL enableLog;

/// 禁用 SDK，默认为 NO
///
/// 禁用后，SDK 将不会触发事件，也不会发送网络请求
@property (nonatomic, assign,getter=isDisableSDK) BOOL disableSDK;


/// App 进入后台时是否等待数据发送结果。默认 NO，不会等待数据发送结果；设置 YES，会等待数据发送结果
@property (nonatomic, assign) BOOL flushBeforeEnterBackground;


/// login 时自定义登录 ID 字段名
@property (nonatomic, copy) NSString *loginIDKey;



@end

NS_ASSUME_NONNULL_END
