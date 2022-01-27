//
// ZallDataSDK+ZARemoteConfig.h
// ZallDataSDK
//
// Created by guo on 2022/1/12.
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
#import <ZallDataSDK/ZallDataSDK.h>



NS_ASSUME_NONNULL_BEGIN

@interface ZallDataSDK (ZARemoteConfig)

/**
* @abstract
* 设置当前 serverUrl，并选择是否请求远程配置
*
* @param serverUrl 当前的 serverUrl
* @param isRequestRemoteConfig 是否请求远程配置
*/
+ (void)updateServerUrl:(NSString *)serverUrl isRequestRemoteConfig:(BOOL)isRequestRemoteConfig;

/**
 *@abstract 发起远程请求
 *
 *@discussion 依赖serverUrl
 *
 *@see setServerUrl:
 */
+(void)updateRemoteConfigServerRequest;


@end


@interface ZAConfigOptions ()

#pragma mark - 请求远程配置策略
@property (nonatomic, assign) BOOL enableRemoteConfig;
/// 请求远程配置地址，默认从 serverURL 解析
@property (nonatomic, copy) NSString *remoteConfigURL;

/// 禁用随机时间请求远程配置
@property (nonatomic, assign) BOOL disableRandomTimeRequestRemoteConfig;

/// 最小间隔时长，单位：小时，默认 24
@property (nonatomic, assign) NSInteger minRequestHourInterval;

/// 最大间隔时长，单位：小时，默认 48
@property (nonatomic, assign) NSInteger maxRequestHourInterval;

@end

@interface ZAConfigOptions (RemoteConfig)

@end
NS_ASSUME_NONNULL_END
