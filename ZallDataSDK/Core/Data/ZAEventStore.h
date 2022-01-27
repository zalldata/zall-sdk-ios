//
// ZAEventStore.h
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
#import "ZAEventRecord.h"

NS_ASSUME_NONNULL_BEGIN

/// 埋点记录存储操作类
@interface ZAEventStore : NSObject

//用于数据库读写的串行队列
@property (nonatomic, strong, readonly) dispatch_queue_t serialQueue;

/// 所有事件记录计数
@property (nonatomic, readonly) NSUInteger count;

/// 根据传入的文件路径初始化
/// @param filePath 传入的数据文件路径
/// @return 初始化的结果
- (instancetype)initWithFilePath:(NSString *)filePath;

/// 获取具有特定大小的记录
/// @param recordSize 指定记录个数
- (NSArray<ZAEventRecord *> *)selectRecords:(NSUInteger)recordSize;

/// 插入一个记录
/// @param record 数据
- (BOOL)insertRecord:(ZAEventRecord *)record;

/// 更新数据状态
/// @param recordIDs 数据ID
/// @param status 更新到指定状态
- (BOOL)updateRecords:(NSArray<NSString *> *)recordIDs status:(ZAEventRecordStatus)status;

/// 删除带有id的记录
/// @param recordIDs 删除id
- (BOOL)deleteRecords:(NSArray<NSString *> *)recordIDs;

/// 删除数据库中的所有记录
- (BOOL)deleteAllRecords;

@end

NS_ASSUME_NONNULL_END
