//
// ZAEventStoreTests.m
// ZallDataTests
//
// Created by guo on 2021/11/10.
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

#import <XCTest/XCTest.h>
#import "ZAObject+ZAConfigOptions.h"
#import "ZAEventStore.h"

@interface ZAEventStoreTests : XCTestCase
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, strong) ZAEventStore *eventStore;
@end

@implementation ZAEventStoreTests

- (void)setUp {
    NSString *fileName = [NSString stringWithFormat:@"test_%d.db", arc4random()];
    self.filePath = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:fileName];
    self.eventStore = [[ZAEventStore alloc] initWithFilePath:self.filePath];
}

- (void)tearDown {
    self.eventStore = nil;

    [NSFileManager.defaultManager removeItemAtPath:self.filePath error:nil];
    self.filePath = nil;
}

- (void)insertHundredRecords {
    for (int index = 0; index < 100; index++) {
        ZAEventRecord *record = [[ZAEventRecord alloc] initWithRecordID:@"1" content:[NSString stringWithFormat:@"{\"index\":%d}", index]];
        record.type = @"POST";
        [self.eventStore insertRecord:record];
    }
}

- (void)testInsertRecordsWithHundredRecords {
    [self insertHundredRecords];
    XCTAssertEqual(self.eventStore.count, 100);
}

- (void)testInsertRecordWithRecord {
    ZAEventRecord *record = [[ZAEventRecord alloc] initWithRecordID:@"1" content:@"{\"index\":\"1\"}"];
    BOOL success = [self.eventStore insertRecord:record];
    XCTAssertTrue(success);
    XCTAssertEqual(self.eventStore.count, 1);
}

- (void)testSelsctRecordsWith50Record {
    [self insertHundredRecords];

    NSArray<ZAEventRecord *> *records = [self.eventStore selectRecords:50];
    XCTAssertEqual(records.count, 50);
}

- (void)testDeleteRecords {
    [self insertHundredRecords];

    NSArray<ZAEventRecord *> *records = [self.eventStore selectRecords:50];
    NSMutableArray *recordIDs = [NSMutableArray arrayWithCapacity:50];
    for (ZAEventRecord *record in records) {
        [recordIDs addObject:record.recordID];
    }
    [self.eventStore deleteRecords:recordIDs];
    XCTAssertEqual(self.eventStore.count, 50);
}

- (void)testDeleteAllRecords {
    [self insertHundredRecords];
    BOOL success = [self.eventStore deleteAllRecords];
    XCTAssertTrue(success);
    XCTAssertEqual(self.eventStore.count, 0);
}

#pragma mark -

- (void)insertHundredRecordsWithEventStore:(ZAEventStore *)store {
    for (int index = 0; index < 100; index++) {
        ZAEventRecord *record = [[ZAEventRecord alloc] initWithRecordID:@"1" content:[NSString stringWithFormat:@"{\"index\":%d}", index]];
        record.type = @"POST";
        [store insertRecord:record];
    }
}

- (void)testInsertHundredRecordsWithoutDatabase {
    ZAEventStore *store = [[ZAEventStore alloc] initWithFilePath:@"/sss/sdfa99qwedjfjdnv(ajs;./"];
    [self insertHundredRecordsWithEventStore:store];
    XCTAssertEqual(store.count, 100);
}

- (void)testSelsctRecordsWithoutDatabase {
    ZAEventStore *store = [[ZAEventStore alloc] initWithFilePath:@"/sss/sdfa99qwedjfjdnv(ajs;./"];
    [self insertHundredRecordsWithEventStore:store];

    NSArray<ZAEventRecord *> *records = [store selectRecords:50];
    XCTAssertEqual(records.count, 50);
}

- (void)testDeleteRecordsWithoutDatabase {
    ZAEventStore *store = [[ZAEventStore alloc] initWithFilePath:@"/sss/sdfa99qwedjfjdnv(ajs;./"];
    [self insertHundredRecordsWithEventStore:store];

    NSArray<ZAEventRecord *> *records = [store selectRecords:50];
    NSMutableArray *recordIDs = [NSMutableArray arrayWithCapacity:50];
    for (ZAEventRecord *record in records) {
        [recordIDs addObject:record.recordID];
    }
    [store deleteRecords:recordIDs];
    XCTAssertEqual(store.count, 50);
}

- (void)testDeleteAllRecordsWithoutDatabase {
    ZAEventStore *store = [[ZAEventStore alloc] initWithFilePath:@"/sss/sdfa99qwedjfjdnv(ajs;./"];
    [self insertHundredRecordsWithEventStore:store];

    BOOL success = [store deleteAllRecords];
    XCTAssertTrue(success);
    XCTAssertEqual(store.count, 0);
}

@end
