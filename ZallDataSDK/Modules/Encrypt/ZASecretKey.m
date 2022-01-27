//
// ZASecretKey.m
// ZallDataSDK
//
// Created by guo on 2021/6/26.
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

#import "ZASecretKey.h"
#import "ZAAlgorithmProtocol.h"

@interface ZASecretKey ()

/// 密钥版本
@property (nonatomic, assign) NSInteger version;

/// 密钥值
@property (nonatomic, copy) NSString *key;

/// 对称加密类型
@property (nonatomic, copy) NSString *symmetricEncryptType;

/// 非对称加密类型
@property (nonatomic, copy) NSString *asymmetricEncryptType;

@end

@implementation ZASecretKey

- (instancetype)initWithKey:(NSString *)key
                    version:(NSInteger)version
      asymmetricEncryptType:(NSString *)asymmetricEncryptType
       symmetricEncryptType:(NSString *)symmetricEncryptType {
    self = [super init];
    if (self) {
        self.version = version;
        self.key = key;
        [self updateAsymmetricType:asymmetricEncryptType symmetricType:symmetricEncryptType];

    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInteger:self.version forKey:@"version"];
    [coder encodeObject:self.key forKey:@"key"];
    [coder encodeObject:self.symmetricEncryptType forKey:@"symmetricEncryptType"];
    [coder encodeObject:self.asymmetricEncryptType forKey:@"asymmetricEncryptType"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.version = [coder decodeIntegerForKey:@"version"];
        self.key = [coder decodeObjectForKey:@"key"];

        NSString *symmetricType = [coder decodeObjectForKey:@"symmetricEncryptType"];
        NSString *asymmetricType = [coder decodeObjectForKey:@"asymmetricEncryptType"];
        [self updateAsymmetricType:asymmetricType symmetricType:symmetricType];
    }
    return self;
}

- (void)updateAsymmetricType:(NSString *)asymmetricType symmetricType:(NSString *)symmetricType {
    // 兼容老版本保存的秘钥
    if (!symmetricType) {
        self.symmetricEncryptType = kZAAlgorithmTypeAES;
    } else {
        self.symmetricEncryptType = symmetricType;
    }

    // 兼容老版本保存的秘钥
    if (!asymmetricType) {
        BOOL isECC = [self.key hasPrefix:kZAAlgorithmTypeECC];
        self.asymmetricEncryptType = isECC ? kZAAlgorithmTypeECC : kZAAlgorithmTypeRSA;
    } else {
        self.asymmetricEncryptType = asymmetricType;
    }
}

@end
