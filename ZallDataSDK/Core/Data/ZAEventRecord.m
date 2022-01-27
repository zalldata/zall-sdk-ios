//
// ZAEventRecord.m
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

#import "ZAEventRecord.h"
#import "ZAJSONUtil.h"
#import "ZAUtilCheck.h"
static NSString * const ZAEncryptRecordKeyEKey = @"ekey";
static NSString * const ZAEncryptRecordKeyPayloads = @"payloads";
static NSString * const ZAEncryptRecordKeyPayload = @"payload";

@implementation ZAEventRecord {
    NSMutableDictionary *_event;
}

static long recordIndex = 0;

- (instancetype)initWithEvent:(NSDictionary *)event type:(NSString *)type {
    if (self = [super init]) {
        _recordID = [NSString stringWithFormat:@"ZA_%ld", recordIndex];
        _event = [event mutableCopy];
        _type = type;

        _encrypted = _event[ZAEncryptRecordKeyEKey] != nil;

        // 事件数据插入自定义的 ID 自增，这个 ID 在入库之前有效，入库之后数据库会生成新的 ID
        recordIndex++;
    }
    return self;
}

- (instancetype)initWithRecordID:(NSString *)recordID content:(NSString *)content {
    if (self = [super init]) {
        _recordID = recordID;

        NSMutableDictionary *eventDic = [ZAJSONUtil JSONObjectWithString:content options:NSJSONReadingMutableContainers];
        if (eventDic) {
            _event = eventDic;
            _encrypted = _event[ZAEncryptRecordKeyEKey] != nil;
        }
    }
    return self;
}

- (NSString *)content {
    return [ZAJSONUtil stringWithJSONObject:self.event];
}

- (BOOL)isValid {
    return self.event.count > 0;
}

- (NSString *)flushContent {
    if (![self isValid]) {
        return nil;
    }

    // 需要先添加 flush time，再进行 json 拼接
    UInt64 time = [[NSDate date] timeIntervalSince1970] * 1000;
    _event[self.encrypted ? @"flush_time" : @"_flush_time"] = @(time);
    
    return self.content;
}

- (NSString *)ekey {
    return _event[ZAEncryptRecordKeyEKey];
}

- (void)setSecretObject:(NSDictionary *)obj {
    if (za_check_empty_dict(obj)) {
        return;
    }
    [_event removeAllObjects];
    [_event addEntriesFromDictionary:obj];

    _encrypted = YES;
}

- (void)removePayload {
    _event[ZAEncryptRecordKeyPayloads] = [NSMutableArray arrayWithObject:_event[ZAEncryptRecordKeyPayload]];
    [_event removeObjectForKey:ZAEncryptRecordKeyPayload];
}

- (BOOL)mergeSameEKeyRecord:(ZAEventRecord *)record {
    if (![self.ekey isEqualToString:record.ekey]) {
        return NO;
    }
    [(NSMutableArray *)_event[ZAEncryptRecordKeyPayloads] addObject:record.event[ZAEncryptRecordKeyPayload]];
    [_event removeObjectForKey:ZAEncryptRecordKeyPayload];
    return YES;
}

@end
