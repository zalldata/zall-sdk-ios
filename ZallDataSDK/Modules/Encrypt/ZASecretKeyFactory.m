//
// ZASecretKeyFactory.m
// ZallDataSDK
//
// Created by guo on 2021/4/20.
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

#import "ZASecretKeyFactory.h"
#import "ZAConfigOptions.h"
#import "ZASecretKey.h"
#import "ZAAlgorithmProtocol.h"
#import "ZAECCPluginEncryptor.h"
#import "ZAJSONUtil.h"
#import "ZAUtilCheck.h"



static NSString *const kZAEncryptVersion = @"pkv";
static NSString *const kZAEncryptPublicKey = @"public_key";
static NSString *const kZAEncryptType = @"type";
static NSString *const kZAEncryptTypeSeparate = @"+";

@implementation ZASecretKeyFactory

#pragma mark - Encryptor Plugin 2.0
+ (ZASecretKey *)createSecretKeyByVersion2:(NSDictionary *)version2 {
    // key_v2 不存在时直接跳过 2.0 逻辑
    if (!version2) {
        return nil;
    }

    NSNumber *pkv = version2[kZAEncryptVersion];
    NSString *type = version2[kZAEncryptType];
    NSString *publicKey = version2[kZAEncryptPublicKey];

    // 检查相关参数是否有效
    if (!pkv || za_check_empty_string(type) || za_check_empty_string(publicKey)) {
        return nil;
    }

    NSArray *types = [type componentsSeparatedByString:kZAEncryptTypeSeparate];
    // 当 type 分隔数组个数小于 2 时 type 不合法，不处理秘钥信息
    if (types.count < 2) {
        return nil;
    }

    // 非对称加密类型，例如: SM2
    NSString *asymmetricType = types[0];

    // 对称加密类型，例如: SM4
    NSString *symmetricType = types[1];

    return [[ZASecretKey alloc] initWithKey:publicKey version:[pkv integerValue] asymmetricEncryptType:asymmetricType symmetricEncryptType:symmetricType];
}

+ (ZASecretKey *)createSecretKeyByVersion1:(NSDictionary *)version1 {
    if (!version1) {
        return nil;
    }
    // 1.0 历史版本逻辑，只处理 key 字段中内容
    NSString *eccContent = version1[@"key_ec"];

    // 当 key_ec 存在且加密库存在时，使用 EC 加密插件
    // 不论秘钥是否创建成功，都不再切换使用其他加密插件

    // 这里为了检查 ECC 插件是否存在，手动生成 ECC 模拟秘钥
    if (eccContent && [ZAECCPluginEncryptor isAvaliable]) {
        NSDictionary *config = [ZAJSONUtil JSONObjectWithString:eccContent];
        return [ZASecretKeyFactory createECCSecretKey:config];
    }

    // 当远程配置不包含自定义秘钥且 EC 不可用时，使用 RSA 秘钥
    return [ZASecretKeyFactory createRZASecretKey:version1];
}

#pragma mark - Encryptor Plugin 1.0
+ (ZASecretKey *)createECCSecretKey:(NSDictionary *)config {
    if (za_check_empty_dict(config)) {
        return nil;
    }
    NSNumber *pkv = config[kZAEncryptVersion];
    NSString *publicKey = config[kZAEncryptPublicKey];
    NSString *type = config[kZAEncryptType];
    if (!pkv || za_check_empty_string(type) || za_check_empty_string(publicKey)) {
        return nil;
    }
    NSString *key = [NSString stringWithFormat:@"%@:%@", type, publicKey];
    return [[ZASecretKey alloc] initWithKey:key version:[pkv integerValue] asymmetricEncryptType:type symmetricEncryptType:kZAAlgorithmTypeAES];
}

+ (ZASecretKey *)createRZASecretKey:(NSDictionary *)config {
    if (za_check_empty_dict(config)) {
        return nil;
    }
    NSNumber *pkv = config[kZAEncryptVersion];
    NSString *publicKey = config[kZAEncryptPublicKey];
    if (!pkv || za_check_empty_string(publicKey)) {
        return nil;
    }
    return [[ZASecretKey alloc] initWithKey:publicKey version:[pkv integerValue] asymmetricEncryptType:kZAAlgorithmTypeRSA symmetricEncryptType:kZAAlgorithmTypeAES];
}

@end
