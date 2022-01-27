//
//  ZANetwork.h
//  ZallDataSDK
//
//  Created by guo on 2019/3/8.
//  Copyright © 2015-2020 Zall Data Co., Ltd. All rights reserved.
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
#import "ZallDataSDK.h"
#import "ZASecurityPolicy.h"
#import "ZAHTTPSession.h"


NS_ASSUME_NONNULL_BEGIN

typedef void(^ZAURLSessionTaskCompletionHandler)(NSData * _Nullable data, NSHTTPURLResponse * _Nullable response, NSError * _Nullable error);

@interface ZANetwork : NSObject

/**
 * @abstract
 * 设置 Cookie
 *
 * @param cookie NSString cookie
 * @param encode BOOL 是否 encode
 */
- (void)setCookie:(NSString *)cookie isEncoded:(BOOL)encode;

/**
 * @abstract
 * 返回已设置的 Cookie
 *
 * @param decode BOOL 是否 decode
 * @return NSString cookie
 */
- (NSString *)cookieWithDecoded:(BOOL)decode;

@end

@interface ZANetwork (ServerURL)

@property (nonatomic, copy, readonly) NSURL *serverURL;
/// 通过 serverURL 获取的 host
@property (nonatomic, copy, readonly, nullable) NSString *host;
/// 在 serverURL 中获取的 project 名称
@property (nonatomic, copy, readonly, nullable) NSString *project;
/// 在 serverURL 中获取的 token 名称
@property (nonatomic, copy, readonly, nullable) NSString *token;

@property (nonatomic, copy, readonly, nullable) NSURLComponents *baseURLComponents;

- (BOOL)isSameProjectWithURLString:(NSString *)URLString;
- (BOOL)isValidServerURL;

@end

@interface ZANetwork (Type)

/// 当前网络类型（NS_OPTIONS 形式）
+ (ZANetworkType)networkTypeOptions;

/// 当前网络类型（NSString 形式）
+ (NSString *)networkTypeString;

@end

NS_ASSUME_NONNULL_END
