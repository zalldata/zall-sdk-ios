//
// ZAEventStore.m
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

#import "ZAEventStore.h"
#import "ZADatabase.h"
#import "ZAQuickUtil.h"


static void * const ZAEventStoreContext = (void*)&ZAEventStoreContext;
static NSString * const ZAEventStoreObserverKeyPath = @"isCreatedTable";

@interface ZAEventStore ()

@property (nonatomic, strong) ZADatabase *database;

/// store data in memory
@property (nonatomic, strong) NSMutableArray<ZAEventRecord *> *recordCaches;

@end

@implementation ZAEventStore

- (instancetype)initWithFilePath:(NSString *)filePath {
    self = [super init];
    if (self) {
        _serialQueue = za_quick_queue_serial_create(NSStringFromClass(self.class));
        // 直接初始化，防止数据库文件，意外删除等问题
        _recordCaches = [NSMutableArray array];

        [self setupDatabase:filePath];
    }
    return self;
}

- (void)dealloc {
    [self.database removeObserver:self forKeyPath:ZAEventStoreObserverKeyPath];
    self.database = nil;
}

- (void)setupDatabase:(NSString *)filePath {
    self.database = [[ZADatabase alloc] initWithFilePath:filePath];
    [self.database addObserver:self forKeyPath:ZAEventStoreObserverKeyPath options:NSKeyValueObservingOptionNew context:ZAEventStoreContext];
}

#pragma mark - property

- (NSUInteger)count {
    return self.database.count + self.recordCaches.count;
}

#pragma mark - observe

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context != ZAEventStoreContext) {
        return [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    if (![keyPath isEqualToString:ZAEventStoreObserverKeyPath]) {
        return;
    }
    if (![change[NSKeyValueChangeNewKey] boolValue] || self.recordCaches.count == 0) {
        return;
    }
    // 对于内存中的数据，重试 3 次插入数据库中。
    for (NSInteger i = 0; i < 3; i++) {
        if ([self.database insertRecords:self.recordCaches]) {
            [self.recordCaches removeAllObjects];
            return;
        }
    }
}

#pragma mark - record

- (NSArray<ZAEventRecord *> *)selectRecordsInCache:(NSUInteger)recordSize {
    __block NSInteger location = NSNotFound;
    [self.recordCaches enumerateObjectsUsingBlock:^(ZAEventRecord * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.status != ZAEventRecordStatusFlush) {
            location = idx;
            *stop = YES;
        }
    }];
    if (location == NSNotFound) {
        return nil;
    }
    NSInteger length = self.recordCaches.count - location <= recordSize ? self.recordCaches.count - location : recordSize;
    return [self.recordCaches subarrayWithRange:NSMakeRange(location, length)];
}

- (NSArray<ZAEventRecord *> *)selectRecords:(NSUInteger)recordSize {
    // 如果内存中存在数据，那么先上传，保证内存数据不丢失
    if (self.recordCaches.count) {
        return [self selectRecordsInCache:recordSize];
    }
    // 上传数据库中的数据
    return [self.database selectRecords:recordSize];
}

- (BOOL)insertRecords:(NSArray<ZAEventRecord *> *)records {
    return [self.database insertRecords:records];
}

- (BOOL)insertRecord:(ZAEventRecord *)record {
    BOOL success = [self.database insertRecord:record];
    if (!success) {
        [self.recordCaches addObject:record];
    }
    return success;
}

- (BOOL)updateRecords:(NSArray<NSString *> *)recordIDs status:(ZAEventRecordStatus)status {
    if (self.recordCaches.count == 0) {
        return [self.database updateRecords:recordIDs status:status];
    }
    // 如果加密失败，会导致 recordIDs 可能不是前 recordIDs.count 条数据，所以此处必须使用两个循环
    for (NSString *recordID in recordIDs) {
        for (ZAEventRecord *record in self.recordCaches) {
            if ([recordID isEqualToString:record.recordID]) {
                record.status = status;
                break;
            }
        }
    }
    return YES;
}

- (BOOL)deleteRecords:(NSArray<NSString *> *)recordIDs {
    // 当缓存中的不存在数据时，说明数据库是正确打开，其他情况不会删除数据
    if (self.recordCaches.count == 0) {
        return [self.database deleteRecords:recordIDs];
    }
    // 删除缓存数据
    // 如果加密失败，会导致 recordIDs 可能不是前 recordIDs.count 条数据，所以此处必须使用两个循环
    // 由于加密失败的可能性较小，所以第二个循环次数不会很多
    for (NSString *recordID in recordIDs) {
        for (NSInteger index = 0; index < self.recordCaches.count; index++) {
            if ([recordID isEqualToString:self.recordCaches[index].recordID]) {
                [self.recordCaches removeObjectAtIndex:index];
                break;
            }
        }
    }
    return YES;
}

- (BOOL)deleteAllRecords {
    if (self.recordCaches.count > 0) {
        [self.recordCaches removeAllObjects];
        return YES;
    }
    return [self.database deleteAllRecords];
}

- (void)fetchRecords:(NSUInteger)recordSize completion:(void (^)(NSArray<ZAEventRecord *> *records))completion {
    dispatch_async(self.serialQueue, ^{
        completion([self.database selectRecords:recordSize]);
    });
}

- (void)insertRecords:(NSArray<ZAEventRecord *> *)records completion:(void (^)(BOOL))completion {
    dispatch_async(self.serialQueue, ^{
        completion([self insertRecords:records]);
    });
}

- (void)insertRecord:(ZAEventRecord *)record completion:(void (^)(BOOL))completion {
    dispatch_async(self.serialQueue, ^{
        completion([self insertRecord:record]);
    });
}

- (void)deleteRecords:(NSArray<NSString *> *)recordIDs completion:(void (^)(BOOL))completion {
    dispatch_async(self.serialQueue, ^{
        completion([self deleteRecords:recordIDs]);
    });
}

- (void)deleteAllRecordsWithCompletion:(void (^)(BOOL))completion {
    dispatch_async(self.serialQueue, ^{
        completion([self deleteAllRecords]);
    });
}

@end
