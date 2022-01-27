//
// ZallDataSDK+ZAEncrypt.h
// ZallDataSDK
//
// Created by guo on 2022/1/14.
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
#import "ZAConfigOptions.h"
#import "ZASecretKey.h"
#import "ZAEncryptProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface ZallDataSDK (ZAEncrypt)

@end

@interface ZAConfigOptions ()
/// 是否开启加密
@property (nonatomic, assign) BOOL enableEncrypt API_UNAVAILABLE(macos);

@property (atomic, strong) NSMutableArray *encryptors;


- (void)registerEncryptor:(id<ZAEncryptProtocol>)encryptor API_UNAVAILABLE(macos);

/// 存储公钥的回调。务必保存秘钥所有字段信息
@property (nonatomic, copy) void (^saveSecretKey)(ZASecretKey * _Nonnull secretKey) API_UNAVAILABLE(macos);

/// 获取公钥的回调。务必回传秘钥所有字段信息
@property (nonatomic, copy) ZASecretKey * _Nonnull (^loadSecretKey)(void) API_UNAVAILABLE(macos);
@end

@interface ZAConfigOptions (ZAEncrypt)

@end

NS_ASSUME_NONNULL_END
