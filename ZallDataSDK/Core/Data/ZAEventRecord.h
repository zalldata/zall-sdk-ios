//
// ZAEventRecord.h
// ZallDataSDK
//
// Created by guo on 2020/6/18.
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 记录数据状态
typedef NS_ENUM(int, ZAEventRecordStatus) {
    /// 未发送数据
    ZAEventRecordStatusNone,
    /// 已发送数据
    ZAEventRecordStatusFlush,
};

@interface ZAEventRecord : NSObject
/// 记录数据ID
@property (nonatomic, copy) NSString *recordID;
/// 类型
@property (nonatomic, copy) NSString *type;
/// 原始数据
@property (nonatomic, copy, readonly) NSString *content;
/// 发送状态
@property (nonatomic) ZAEventRecordStatus status;
/// 是否加密
@property (nonatomic, getter=isEncrypted) BOOL encrypted;
/// 原始数据Dict
@property (nonatomic, copy, readonly) NSDictionary *event;

/// 通过 event 初始化方法
/// 主要是在 track 事件的时候使用
/// @param event 事件数据
/// @param type 上传数据类型
- (instancetype)initWithEvent:(NSDictionary *)event type:(NSString *)type;

/// 通过 recordID 和 content 进行初始化
/// 主要使用在从数据库中，获取数据时进行初始化
/// @param recordID 事件 id
/// @param content 事件 json 字符串数据
- (instancetype)initWithRecordID:(NSString *)recordID content:(NSString *)content;

- (instancetype)init NS_UNAVAILABLE;
/// 校验数据
- (BOOL)isValid;
/// flushContent
- (nullable NSString *)flushContent;
/// 密钥
@property (nonatomic, copy, readonly) NSString *ekey;
/// 设置加密数据
- (void)setSecretObject:(NSDictionary *)obj;
/// 移除payload
- (void)removePayload;
/// 数据加密方式是否一致
- (BOOL)mergeSameEKeyRecord:(ZAEventRecord *)record;

@end

NS_ASSUME_NONNULL_END
