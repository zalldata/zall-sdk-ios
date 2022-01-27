//
// ZAEncryptManager.m
// ZallDataSDK
//
// Created by guo on 2020/11/25.
// Copyright © 2020 Zall Data Co., Ltd. All rights reserved.
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

#import "ZAEncryptManager.h"
#import "ZAURLUtils.h"
#import "ZAAlertViewController.h"
#import "ZAFileStore.h"
#import "ZAJSONUtil.h"
#import "ZALog.h"
#import "ZARSAPluginEncryptor.h"
#import "ZAECCPluginEncryptor.h"
#import "ZASecretKey.h"
#import "ZASecretKeyFactory.h"
#import "ZAUtilCheck.h"
#import "ZAQuickUtil.h"
#import "ZallDataSDK+ZAEncrypt.h"

static NSString * const kZAEncryptSecretKey = @"ZAEncryptSecretKey";

 
@ZAAppLoadModule(ZAEncryptManager)
@interface ZAEncryptManager ()

/// 当前使用的加密插件
@property (nonatomic, strong) id<ZAEncryptProtocol> encryptor;

/// 当前支持的加密插件列表
@property (nonatomic, copy) NSArray<id<ZAEncryptProtocol>> *encryptors;

/// 已加密过的对称秘钥内容
@property (nonatomic, copy) NSString *encryptedSymmetricKey;

/// 非对称加密器的公钥（RSA/ECC 的公钥）
@property (nonatomic, strong) ZASecretKey *secretKey;

@end

@implementation ZAEncryptManager

+ (instancetype)defaultManager {
    static dispatch_once_t onceToken;
    static ZAEncryptManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[ZAEncryptManager alloc] init];
    });
    return manager;
}

#pragma mark - ZAModuleProtocol

- (void)setEnable:(BOOL)enable {
    _enable = enable;

    if (enable) {
        [self updateEncryptor];
    }
}

- (void)setConfigOptions:(ZAConfigOptions *)configOptions {
    _configOptions = configOptions;
    if (configOptions.enableEncrypt) {
        NSAssert((configOptions.saveSecretKey && configOptions.loadSecretKey) || (!configOptions.saveSecretKey && !configOptions.loadSecretKey), @"存储公钥和获取公钥的回调需要全部实现或者全部不实现。");
    }

    NSMutableArray *encryptors = [NSMutableArray array];

    // 当 ECC 加密库未集成时，不注册 ECC 加密插件
    if ([ZAECCPluginEncryptor isAvaliable]) {
        [encryptors addObject:[[ZAECCPluginEncryptor alloc] init]];
    }
    [encryptors addObject:[[ZARSAPluginEncryptor alloc] init]];
    [encryptors addObjectsFromArray:configOptions.encryptors];
    self.encryptors = encryptors;
    self.enable = configOptions.enableEncrypt;
}

#pragma mark - ZAOpenURLProtocol

- (BOOL)canHandleURL:(nonnull NSURL *)url {
    return [url.host isEqualToString:@"encrypt"];
}

- (BOOL)handleURL:(nonnull NSURL *)url {
    NSString *message = @"当前 App 未开启加密，请开启加密后再试";

    if (self.enable) {
        NSDictionary *paramDic = [ZAURLUtils queryItemsWithURL:url];
        NSString *urlVersion = paramDic[@"v"];

        // url 中的 key 为 encode 之后的，这里做 decode
        NSString *urlKey = [paramDic[@"key"] stringByRemovingPercentEncoding];
        
        if (!za_check_empty_string(urlVersion) && !za_check_empty_string(urlKey)) {
            ZASecretKey *secretKey = [self loadCurrentSecretKey];
            NSString *loadVersion = [@(secretKey.version) stringValue];

            // 这里为了兼容新老版本下发的 EC 秘钥中 URL key 前缀和本地保存的 EC 秘钥前缀不一致的问题，都统一删除 EC 前缀后比较内容
            NSString *currentKey = [secretKey.key hasPrefix:kZAEncryptECCPrefix] ? [secretKey.key substringFromIndex:kZAEncryptECCPrefix.length] : secretKey.key;
            NSString *decodeKey = [urlKey hasPrefix:kZAEncryptECCPrefix] ? [urlKey substringFromIndex:kZAEncryptECCPrefix.length] : urlKey;

            if ([loadVersion isEqualToString:urlVersion] && [currentKey isEqualToString:decodeKey]) {
                NSString *asymmetricType = [paramDic[@"asymmetricEncryptType"] stringByRemovingPercentEncoding];
                NSString *symmetricType = [paramDic[@"symmetricEncryptType"] stringByRemovingPercentEncoding];
                BOOL typeMatched = [secretKey.asymmetricEncryptType isEqualToString:asymmetricType] &&
                [secretKey.symmetricEncryptType isEqualToString:symmetricType];
                // 这里为了兼容老版本 ZA 未下发秘钥类型，当某一个类型不存在时即当做老版本 ZA 处理
                if (!asymmetricType || !symmetricType || typeMatched) {
                    message = @"密钥验证通过，所选密钥与 App 端密钥相同";
                } else {
                    message = [NSString stringWithFormat:@"密钥验证不通过，所选密钥与 App 端密钥不相同。所选密钥对称算法类型:%@，非对称算法类型:%@, App 端对称算法类型:%@, 非对称算法类型:%@", symmetricType, asymmetricType, secretKey.symmetricEncryptType, secretKey.asymmetricEncryptType];
                }
            } else if (za_check_empty_string(currentKey)) {
                message = @"密钥验证不通过，App 端密钥为空";
            } else {
                message = [NSString stringWithFormat:@"密钥验证不通过，所选密钥与 App 端密钥不相同。所选密钥版本:%@，App 端密钥版本:%@", urlVersion, loadVersion];
            }
        } else {
            message = @"密钥验证不通过，所选密钥无效";
        }
    }

    ZAAlertViewController *alertController = [[ZAAlertViewController alloc] initWithTitle:nil message:message preferredStyle:ZAAlertControllerStyleAlert];
    [alertController addActionWithTitle:@"确认" style:ZAAlertActionStyleDefault handler:nil];
    [alertController show];
    return YES;
}

#pragma mark - ZAEncryptModuleProtocol
- (BOOL)hasSecretKey {
    // 当可以获取到秘钥时，不需要强制性触发远程配置请求秘钥
    ZASecretKey *sccretKey = [self loadCurrentSecretKey];
    return (sccretKey.key.length > 0);
}

- (NSDictionary *)encryptJSONObject:(id)obj {
    @try {
        if (!obj) {
            ZALogDebug(@"Enable encryption but the input obj is invalid!");
            return nil;
        }

        if (!self.encryptor) {
            ZALogDebug(@"Enable encryption but the secret key is invalid!");
            return nil;
        }

        if (![self encryptSymmetricKey]) {
            ZALogDebug(@"Enable encryption but encrypt symmetric key is failed!");
            return nil;
        }

        // 使用 gzip 进行压缩
        NSData *jsonData = [ZAJSONUtil dataWithJSONObject:obj];
        
        NSData *zippedData = [ZAQuickUtil gzipDeflateWith:jsonData];

        // 加密数据
        NSString *encryptedString =  [self.encryptor encryptEvent:zippedData];
        if (za_check_empty_string(encryptedString)) {
            return nil;
        }

        // 封装加密的数据结构
        NSMutableDictionary *secretObj = [NSMutableDictionary dictionary];
        secretObj[@"pkv"] = @(self.secretKey.version);
        secretObj[@"ekey"] = self.encryptedSymmetricKey;
        secretObj[@"payload"] = encryptedString;
        return [NSDictionary dictionaryWithDictionary:secretObj];
    } @catch (NSException *exception) {
        ZALogError(@"%@ error: %@", self, exception);
        return nil;
    }
}

- (BOOL)encryptSymmetricKey {
    if (self.encryptedSymmetricKey) {
        return YES;
    }
    NSString *publicKey = self.secretKey.key;
    self.encryptedSymmetricKey = [self.encryptor encryptSymmetricKeyWithPublicKey:publicKey];
    return self.encryptedSymmetricKey != nil;
}

#pragma mark - handle remote config for secret key
- (void)handleEncryptWithConfig:(NSDictionary *)encryptConfig {
    if (!encryptConfig) {
        return;
    }

    // 加密插件化 2.0 新增字段，下发秘钥信息不可用时，继续走 1.0 逻辑
    ZASecretKey *secretKey = [ZASecretKeyFactory createSecretKeyByVersion2:encryptConfig[@"key_v2"]];
    if (![self encryptorWithSecretKey:secretKey]) {
        // 加密插件化 1.0 秘钥信息
        secretKey = [ZASecretKeyFactory createSecretKeyByVersion1:encryptConfig[@"key"]];
    }

    //当前秘钥没有对应的加密器
    if (![self encryptorWithSecretKey:secretKey]) {
        return;
    }
    // 存储请求的公钥
    [self saveRequestSecretKey:secretKey];
    // 更新加密构造器
    [self updateEncryptor];
}

- (void)updateEncryptor {
    @try {
        ZASecretKey *secretKey = [self loadCurrentSecretKey];
        if (za_check_empty_string(secretKey.key)) {
            return;
        }

        if (secretKey.version <= 0) {
            return;
        }

        // 返回的密钥与已有的密钥一样则不需要更新
        if ([self isSameSecretKey:self.secretKey newSecretKey:secretKey]) {
            return;
        }

        id<ZAEncryptProtocol> encryptor = [self filterEncrptor:secretKey];
        if (!encryptor) {
            return;
        }

        NSString *encryptedSymmetricKey = [encryptor encryptSymmetricKeyWithPublicKey:secretKey.key];
        
        if (!za_check_empty_string(encryptedSymmetricKey)) {
            // 更新密钥
            self.secretKey = secretKey;
            // 更新加密插件
            self.encryptor = encryptor;
            // 重新生成加密插件的对称密钥
            self.encryptedSymmetricKey = encryptedSymmetricKey;
        }
    } @catch (NSException *exception) {
        ZALogError(@"%@ error: %@", self, exception);
    }
}

- (BOOL)isSameSecretKey:(ZASecretKey *)currentSecretKey newSecretKey:(ZASecretKey *)newSecretKey {
    if (currentSecretKey.version != newSecretKey.version) {
        return NO;
    }
    if (![currentSecretKey.key isEqualToString:newSecretKey.key]) {
        return NO;
    }
    if (![currentSecretKey.symmetricEncryptType isEqualToString:newSecretKey.symmetricEncryptType]) {
        return NO;
    }
    if (![currentSecretKey.asymmetricEncryptType isEqualToString:newSecretKey.asymmetricEncryptType]) {
        return NO;
    }
    return YES;
}

- (id<ZAEncryptProtocol>)filterEncrptor:(ZASecretKey *)secretKey {
    id<ZAEncryptProtocol> encryptor = [self encryptorWithSecretKey:secretKey];
    if (!encryptor) {
        NSString *format = @"\n您使用了 [%@]  密钥，但是并没有注册对应加密插件。\n • 若您使用的是 EC+AES 或 SM2+SM4 加密方式，请检查是否正确集成 'ZallAnalyticsEncrypt' 模块，且已注册对应加密插件。\n";
        NSString *type = [NSString stringWithFormat:@"%@+%@", secretKey.asymmetricEncryptType, secretKey.symmetricEncryptType];
        NSString *message = [NSString stringWithFormat:format, type];
        NSAssert(NO, message);
        return nil;
    }
    return encryptor;
}

- (id<ZAEncryptProtocol>)encryptorWithSecretKey:(ZASecretKey *)secretKey {
    if (!secretKey) {
        return nil;
    }
    __block id<ZAEncryptProtocol> encryptor;
    [self.encryptors enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id<ZAEncryptProtocol> obj, NSUInteger idx, BOOL *stop) {
        BOOL isSameAsymmetricType = [[obj asymmetricEncryptType] isEqualToString:secretKey.asymmetricEncryptType];
        BOOL isSameSymmetricType = [[obj symmetricEncryptType] isEqualToString:secretKey.symmetricEncryptType];
        // 当非对称加密类型和对称加密类型都匹配一致时，返回对应加密器
        if (isSameAsymmetricType && isSameSymmetricType) {
            encryptor = obj;
            *stop = YES;
        }
    }];
    return encryptor;
}

#pragma mark - archive/unarchive secretKey
- (void)saveRequestSecretKey:(ZASecretKey *)secretKey {
    if (!secretKey) {
        return;
    }

    void (^saveSecretKey)(ZASecretKey *) = self.configOptions.saveSecretKey;
    if (saveSecretKey) {
        // 通过用户的回调保存公钥
        saveSecretKey(secretKey);

        [ZAFileStore archiveWithFileName:kZAEncryptSecretKey value:nil];

        ZALogDebug(@"Save secret key by saveSecretKey callback, pkv : %ld, public_key : %@", (long)secretKey.version, secretKey.key);
    } else {
        // 存储到本地
        NSData *secretKeyData = [NSKeyedArchiver archivedDataWithRootObject:secretKey];
        [ZAFileStore archiveWithFileName:kZAEncryptSecretKey value:secretKeyData];

        ZALogDebug(@"Save secret key by localSecretKey, pkv : %ld, public_key : %@", (long)secretKey.version, secretKey.key);
    }
}

- (ZASecretKey *)loadCurrentSecretKey {
    ZASecretKey *secretKey = nil;

    ZASecretKey *(^loadSecretKey)(void) = self.configOptions.loadSecretKey;
    if (loadSecretKey) {
        // 通过用户的回调获取公钥
        secretKey = loadSecretKey();

        if (secretKey) {
            ZALogDebug(@"Load secret key from loadSecretKey callback, pkv : %ld, public_key : %@", (long)secretKey.version, secretKey.key);
        } else {
            ZALogDebug(@"Load secret key from loadSecretKey callback failed!");
        }
    } else {
        // 通过本地获取公钥
        id secretKeyData = [ZAFileStore unarchiveWithFileName:kZAEncryptSecretKey];
        if (!za_check_empty_data(secretKeyData)) {
            secretKey = [NSKeyedUnarchiver unarchiveObjectWithData:secretKeyData];
        }

        if (secretKey) {
            ZALogDebug(@"Load secret key from localSecretKey, pkv : %ld, public_key : %@", (long)secretKey.version, secretKey.key);
        } else {
            ZALogDebug(@"Load secret key from localSecretKey failed!");
        }
    }
    return secretKey;
}

@end
