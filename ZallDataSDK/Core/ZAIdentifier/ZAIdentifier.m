//
// ZAIdentifier.m
// ZallDataSDK
//
// Created by guo on 2020/2/17.
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

#import "ZAIdentifier.h"
#import "ZAUtilCheck.h"

#import "ZAFileStore.h"
#import "ZALog.h"
#import "ZAConstantsDefin.h"
#import "ZAQuickUtil.h"
#import "ZAQueueManage.h"
#import "ZAKeyChainItemWrapper.h"

 
@interface ZAIdentifier ()

@property (nonatomic, copy, readwrite) NSString *loginId;
@property (nonatomic, copy, readwrite) NSString *anonymousId;
@property (nonatomic, copy, readwrite) NSString *loginIDKey;

@property (nonatomic, copy, readwrite) NSDictionary *identities;
@property (nonatomic, copy) NSDictionary *removedIdentity;

@end

@implementation ZAIdentifier

#pragma mark - Life Cycle
- (instancetype)initWithLoginIDKey:(NSString *)loginIDKey {
    self = [super init];
    if (self) {
        

        NSError *error = [ZAUtilCheck zaCheckKey:loginIDKey];
        if (error) {
            loginIDKey = kZAIdentitiesLoginId;
        }

        if (![loginIDKey isEqualToString:kZAIdentitiesLoginId] && [self isPresetKey:loginIDKey]) {
            ZALogError(@"LoginIDKey [ %@ ] is invalid", loginIDKey);
            loginIDKey = kZAIdentitiesLoginId;
        }
        _loginIDKey = loginIDKey;
        
        [ZAQueueManage readWriteQueueAsync:^{
            self.identities = [self unarchiveIdentities];
            self.anonymousId = [self unarchiveAnonymousId];
            self.loginId = [ZAFileStore unarchiveWithFileName:kZAEventLoginId];
        }];
        
        
    }
    return self;
}

#pragma mark - Public Methods

- (BOOL)identify:(NSString *)anonymousId {
    if (![anonymousId isKindOfClass:[NSString class]]) {
        ZALogError(@"AnonymousId must be string");
        return NO;
    }
    if (anonymousId.length == 0) {
        ZALogError(@"AnonymousId is empty");
        return NO;
    }

    if ([anonymousId length] > kZAPropertyValueMaxLength) {
        ZALogWarn(@"AnonymousId: %@'s length is longer than %ld", anonymousId, kZAPropertyValueMaxLength);
    }

    if ([anonymousId isEqualToString:self.anonymousId]) {
        return NO;
    }
    
    [self updateAnonymousId:anonymousId];
    [self bindIdentity:kZAIdentitiesAnonymousId value:anonymousId];
    return YES;
}

- (void)archiveAnonymousId:(NSString *)anonymousId {
    [ZAFileStore archiveWithFileName:kZAEventDistinctId value:anonymousId];
    [ZAKeyChainItemWrapper saveUdid:anonymousId];

}

- (void)resetAnonymousId {
    NSString *anonymousId = [ZAQuickUtil hardwareID];
    [self updateAnonymousId:anonymousId];
    // 只有 identities 包含 $identity_anonymous_id 时需要更新内容
    if (self.identities[kZAIdentitiesAnonymousId]) {
        [self bindIdentity:kZAIdentitiesAnonymousId value:anonymousId];
    }
}

- (void)updateAnonymousId:(NSString *)anonymousId {
    // 异步任务设置匿名 ID
    [ZAQueueManage readWriteQueueAsync:^{
        self.anonymousId = anonymousId;
        [self archiveAnonymousId:anonymousId];
    }];
}

- (BOOL)isValidLoginId:(NSString *)loginId {
    if (![loginId isKindOfClass:[NSString class]]) {
        ZALogError(@"LoginId must be string");
        return NO;
    }
    if (loginId.length == 0) {
        ZALogError(@"LoginId is empty");
        return NO;
    }

    if ([loginId length] > kZAPropertyValueMaxLength) {
        ZALogWarn(@"LoginId: %@'s length is longer than %ld", loginId, kZAPropertyValueMaxLength);
        return NO;
    }

    if ([loginId isEqualToString:self.loginId]) {
        return NO;
    }

    // 为了避免将匿名 ID 作为 LoginID 传入
    if ([loginId isEqualToString:self.anonymousId]) {
        return NO;
    }

    NSString *cachedKey = [ZAFileStore unarchiveWithFileName:kZALoginIDKey];
    // 当 loginIDKey 发生变化时，不需要检查 loginId 是否相同
    if ([cachedKey isEqualToString:self.loginIDKey] && [loginId isEqualToString:self.loginId]) {
        return NO;
    }

    return YES;
}

- (void)login:(NSString *)loginId {
    [self updateLoginId:loginId];
    [self bindIdentity:self.loginIDKey value:loginId];
}

- (void)updateLoginId:(NSString *)loginId {
    [ZAQueueManage readWriteQueueAsync:^{
        self.loginId = loginId;
        [ZAFileStore archiveWithFileName:kZAEventLoginId value:loginId];
        // 登录时本地保存当前的 loginIDKey 字段，字段存在时表示 v3.0 版本 SDK 已进行过登录
        [ZAFileStore archiveWithFileName:kZALoginIDKey value:self.loginIDKey];
    }];
}

- (void)logout {
    [self clearLoginId];
    [self resetIdentities];
}

- (void)clearLoginId {
    [ZAQueueManage readWriteQueueAsync:^{
        self.loginId = nil;
        [ZAFileStore archiveWithFileName:kZAEventLoginId value:nil];
        // 退出登录时清除本地保存的 loginIDKey 字段，字段不存在时表示 v3.0 版本 SDK 已退出登录
        [ZAFileStore archiveWithFileName:kZALoginIDKey value:nil];
    }];
}


#pragma mark – Private Methods

- (NSString *)unarchiveAnonymousId {
    NSString *anonymousId = [ZAFileStore unarchiveWithFileName:kZAEventDistinctId];

    NSString *distinctIdInKeychain = [ZAKeyChainItemWrapper saUdid];
    if (distinctIdInKeychain.length > 0) {
        if (![anonymousId isEqualToString:distinctIdInKeychain]) {
            // 保存 Archiver
            [ZAFileStore archiveWithFileName:kZAEventDistinctId value:distinctIdInKeychain];
        }
        anonymousId = distinctIdInKeychain;
    } else {
        if (anonymousId.length == 0) {
            anonymousId = [ZAQuickUtil hardwareID];
            [self archiveAnonymousId:anonymousId];
        } else {
            //保存 KeyChain
            [ZAKeyChainItemWrapper saveUdid:anonymousId];
        }
    }


    return anonymousId;
}

#pragma mark – Getters and Setters
- (NSString *)loginId {
 
    return _loginId;
}

- (NSString *)anonymousId {
  
    if (!_anonymousId) {
        [ZAQueueManage readWriteQueueSync:^{
            [self resetAnonymousId];
        }];
    }
   
    return _anonymousId;
}

- (NSString *)distinctId {
    __block NSString *distinctId = nil;
   
    [ZAQueueManage readWriteQueueSync:^{
        distinctId = self.loginId;
        if (distinctId.length == 0) {
            distinctId = self.anonymousId;
        }
    }];
    return distinctId;
}

- (NSDictionary *)identities {
    return _identities;
}

- (NSDictionary *)removedIdentity {
     
    return _removedIdentity;
}

#pragma mark - Identities
- (NSDictionary *)mergeH5Identities:(NSDictionary *)identities eventType:(NSString *)eventType {
    if ([eventType isEqualToString:kZAEventTypeUnbind]) {
        NSString *key = identities.allKeys.firstObject;
        if (![self isValidIdentity:key value:identities[key]]) {
            return @{};
        }
        [self unbindIdentity:key value:identities[key]];
        return identities;
    }

    NSMutableDictionary *newIdentities = [NSMutableDictionary dictionaryWithDictionary:identities];
    // 移除 H5 事件 identities 中的保留 ID，不允许 H5 绑定保留 ID
    [newIdentities removeObjectsForKeys:@[kZAIdentitiesUniqueID, kZAIdentitiesUUID, kZAIdentitiesAnonymousId]];
    [newIdentities addEntriesFromDictionary:self.identities];

    // 即表示有效登录，需要重置 identities 内容
    BOOL reset = (!identities || identities[self.loginIDKey]);
    if ([eventType isEqualToString:kZAEventTypeSignup] && reset) {
        // 当前逻辑需要在调用 login 后执行才是有效的，重置 identities 时需要使用 login_id
        // 触发登录事件切换用户时，清空后续事件中的已绑定参数
        [self resetIdentities];
    }

    // 当为绑定事件时，Native 需要把绑定的业务 ID 持久化
    if ([eventType isEqualToString:kZAEventTypeBind]) {
        [ZAQueueManage readWriteQueueSync:^{
            NSMutableDictionary *archive = [newIdentities mutableCopy];
            [archive removeObjectForKey:kZAIdentitiesCookieId];
            self.identities = archive;
            [self archiveIdentities:archive];
        }];
        
    }
    return newIdentities;
}

- (BOOL)isPresetKey:(NSString *)key {
    // IDFV 和 ios_uuid 为 SDK 生成的设备唯一标识，不允许客户绑定与解绑
    return ([key isEqualToString:kZAIdentitiesUniqueID] ||
            [key isEqualToString:kZAIdentitiesUUID] ||
            [key isEqualToString:kZAIdentitiesLoginId] ||
            [key isEqualToString:kZAIdentitiesAnonymousId]);
}

- (BOOL)isValidIdentity:(NSString *)key value:(NSString *)value {
    if (![key isKindOfClass:NSString.class]) {
        ZALogError(@"Key [%@] must be string", key);
        return NO;
    }
    if (key.length <= 0) {
        ZALogError(@"Key is empty");
        return NO;
    }
    NSError *error = [ZAUtilCheck zaCheckKey:key];
    
    if (error) {
        ZALogError(@"%@",error.localizedDescription);
    }
    if (error && error.code != ZACheckdatorErrorOverflow) {
        return NO;
    }
    if ([self isPresetKey:key]) {
        ZALogError(@"Key [ %@ ] is invalid", key);
        return NO;
    }
    if ([key isEqualToString:self.loginIDKey]) {
        ZALogError(@"Key [ %@ ] is invalid", key);
        return NO;
    }
    if (!value) {
        ZALogError(@"bind or unbind value should not be nil");
        return NO;
    }
    if (![value isKindOfClass:[NSString class]]) {
        ZALogError(@"bind or unbind value should be string");
        return NO;
    }
    if (value.length == 0) {
        ZALogError(@"bind or unbind value should not be empty");
        return NO;
    }

    return YES;
}

- (void)bindIdentity:(NSString *)key value:(NSString *)value {
    NSMutableDictionary *identities = [self.identities mutableCopy];
    identities[key] = value;
    [ZAQueueManage readWriteQueueAsync:^{
        self.identities = identities;
        [self archiveIdentities:identities];
    }];
     
}

- (void)unbindIdentity:(NSString *)key value:(NSString *)value {
    NSMutableDictionary *removed = [NSMutableDictionary dictionary];
    removed[key] = value;
    if (![value isEqualToString:self.identities[key]]) {
        // 当 identities 中不存在需要解绑的字段时，不需要进行删除操作
        [ZAQueueManage readWriteQueueAsync:^{
            self.removedIdentity = removed;
        }];
        
        return;
    }
    NSMutableDictionary *identities = [self.identities mutableCopy];
    [identities removeObjectForKey:key];
    [ZAQueueManage readWriteQueueAsync:^{
        self.removedIdentity = removed;
        self.identities = identities;
        [self archiveIdentities:identities];
    }];
}

- (void)resetIdentities {
    NSMutableDictionary *identities = [NSMutableDictionary dictionary];
    identities[kZAIdentitiesUniqueID] = self.identities[kZAIdentitiesUniqueID];
    identities[kZAIdentitiesUUID] = self.identities[kZAIdentitiesUUID];
    // 当 loginId 存在时需要添加 loginId
    identities[self.loginIDKey] = self.loginId;
    [ZAQueueManage readWriteQueueAsync:^{
        self.identities = identities;
        [self archiveIdentities:identities];
    }];
}

- (NSDictionary *)identitiesWithEventType:(NSString *)eventType {
    // 提前拷贝当前事件的 identities 内容，避免登录事件时被清空其他业务 ID
    NSDictionary *identities = [self.identities copy];

    if ([eventType isEqualToString:kZAEventTypeUnbind]) {
        identities = [self.removedIdentity copy];
        self.removedIdentity = nil;
    }
    // 客户业务场景下切换用户后，需要清除其他已绑定业务 ID
    if ([eventType isEqualToString:kZAEventTypeSignup]) {
        [self resetIdentities];
    }
    return identities;
}
/// 解档Identities
- (NSDictionary *)unarchiveIdentities {
    NSDictionary *cache = [self decodeIdentities];
    NSMutableDictionary *identities = [NSMutableDictionary dictionaryWithDictionary:cache];

    // 所以当 identities[kZAIdentitiesAnonymousId] 存在时，需要使用本地的 anonymous_id 更新其内容
    if (!cache || identities[kZAIdentitiesAnonymousId]) {

        NSString *anonymousId;

        // 读取 KeyChain 中保存的 anonymousId，
        // 当前逻辑时 self.anonymousId 还未设置，因此需要手动读取 keychain 数据
        anonymousId = [ZAKeyChainItemWrapper saUdid];

        if (!anonymousId) {
            // 读取本地文件中保存的 anonymouId
            anonymousId = [ZAFileStore unarchiveWithFileName:kZAEventDistinctId];
        }
        identities[kZAIdentitiesAnonymousId] = anonymousId;
    }

    // SDK 取 IDFV 或 uuid 为设备唯一标识，已知情况下未发现获取不到 IDFV 的情况
    if (!identities[kZAIdentitiesUniqueID] && !identities[kZAIdentitiesUUID] ) {
        NSString *key = kZAIdentitiesUUID;
        NSString *value = [NSUUID UUID].UUIDString;

        if ([ZAQuickUtil idfv]) {
            key = kZAIdentitiesUniqueID;
            value = [ZAQuickUtil idfv];
        }

        identities[key] = value;
    }

    NSString *loginId = [ZAFileStore unarchiveWithFileName:kZAEventLoginId];
    if (loginId) {
        NSString *cachedKey = [ZAFileStore unarchiveWithFileName:kZALoginIDKey];
      
        if (identities[cachedKey]) {
            if (![identities[cachedKey] isEqualToString:loginId]) {
            
                NSMutableDictionary *newIdentities = [NSMutableDictionary dictionary];
                newIdentities[kZAIdentitiesUniqueID] = identities[kZAIdentitiesUniqueID];
                newIdentities[kZAIdentitiesUUID] = identities[kZAIdentitiesUUID];
                // identities 中存在 cachedKey 内容时，只需要更新 cachedKey 对应的内容。
                newIdentities[cachedKey] = loginId;
                identities = newIdentities;
            }
        } else {
         
            NSMutableDictionary *newIdentities = [NSMutableDictionary dictionary];
            newIdentities[kZAIdentitiesUniqueID] = identities[kZAIdentitiesUniqueID];
            newIdentities[kZAIdentitiesUUID] = identities[kZAIdentitiesUUID];
            newIdentities[self.loginIDKey] = loginId;
            identities = newIdentities;

            // 此时相当于进行登录操作，需要保存登录时设置的 loginIDKey 内容至本地文件中
            [ZAFileStore archiveWithFileName:kZALoginIDKey value:self.loginIDKey];
        }
    } else {
        NSString *cachedKey = [ZAFileStore unarchiveWithFileName:kZALoginIDKey];
        // 当 identities 中存在 cachedKey 内容时，表示当前 identities 中是登录状态
        if (identities[cachedKey]) {
            // 此时 identities 中仍为登录状态，需要进行退出登录操作
            // 只需要保留 $identity_idfv/$identity_ios_uuid 和 $identity_anonymous_id
            NSMutableDictionary *newIdentities = [NSMutableDictionary dictionary];
            newIdentities[kZAIdentitiesUniqueID] = identities[kZAIdentitiesUniqueID];
            newIdentities[kZAIdentitiesUUID] = identities[kZAIdentitiesUUID];
            newIdentities[kZAIdentitiesAnonymousId] = identities[kZAIdentitiesAnonymousId];
            identities = newIdentities;
        }

        [ZAFileStore archiveWithFileName:kZALoginIDKey value:nil];
    }
    // 每次强制更新一次本地 identities，触发部分业务场景需要更新本地内容
    [self archiveIdentities:identities];
    return identities;
}

- (NSDictionary *)decodeIdentities {
    NSString *content = [ZAFileStore unarchiveWithFileName:kZAIdentities];
    NSData *data;
    if ([content hasPrefix:kZAIdentitiesCacheType]) {
        NSString *value = [content substringFromIndex:kZAIdentitiesCacheType.length];
        data = [[NSData alloc] initWithBase64EncodedString:value options:NSDataBase64DecodingIgnoreUnknownCharacters];
    }
    if (!data) {
        return nil;
    }
    return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
}

- (void)archiveIdentities:(NSDictionary *)identities {
    if (!identities) {
        return;
    }

    @try {
        NSData *data = [NSJSONSerialization dataWithJSONObject:identities options:NSJSONWritingPrettyPrinted error:nil];
        NSString *base64Str = [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
        NSString *result = [NSString stringWithFormat:@"%@%@",kZAIdentitiesCacheType, base64Str];
        [ZAFileStore archiveWithFileName:kZAIdentities value:result];
    } @catch (NSException *exception) {
        ZALogError(@"%@", exception);
    }
}

@end
