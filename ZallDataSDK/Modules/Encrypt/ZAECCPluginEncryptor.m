//
// ZAECCPluginEncryptor.m
// ZallDataSDK
//
// Created by guo on 2021/4/14.
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

#import "ZAECCPluginEncryptor.h"
#import "ZAAESEncryptor.h"
#import "ZAECCEncryptor.h"

@interface ZAECCPluginEncryptor ()

@property (nonatomic, strong) ZAAESEncryptor *aesEncryptor;
@property (nonatomic, strong) ZAECCEncryptor *eccEncryptor;

@end

@implementation ZAECCPluginEncryptor

+ (BOOL)isAvaliable {
    return NSClassFromString(kZAEncryptECCClassName) != nil;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _aesEncryptor = [[ZAAESEncryptor alloc] init];
        _eccEncryptor = [[ZAECCEncryptor alloc] init];
    }
    return self;
}

- (NSString *)symmetricEncryptType {
    return [_aesEncryptor algorithm];
}

- (NSString *)asymmetricEncryptType {
    return [_eccEncryptor algorithm];
}

- (NSString *)encryptEvent:(NSData *)event {
    return [_aesEncryptor encryptData:event];
}

- (NSString *)encryptSymmetricKeyWithPublicKey:(NSString *)publicKey {
    if (![_eccEncryptor.key isEqualToString:publicKey]) {
        _eccEncryptor.key = publicKey;
    }
    return [_eccEncryptor encryptData:_aesEncryptor.key];
}

@end
