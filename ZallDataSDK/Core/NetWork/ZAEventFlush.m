//
// ZAEventFlush.m
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

#import "ZAEventFlush.h"
#import "ZAModuleManager.h"
#import "ZAJSONUtil.h"
#import "ZAConfigOptions+ZAPrivately.h"
#import "ZallDataSDK+ZAPrivate.h"
@interface ZAEventFlush ()

@property (nonatomic, strong) dispatch_semaphore_t flushSemaphore;

@end

@implementation ZAEventFlush

- (dispatch_semaphore_t)flushSemaphore {
    if (!_flushSemaphore) {
        _flushSemaphore = dispatch_semaphore_create(0);
    }
    return _flushSemaphore;
}

#pragma mark - build

// 1. 先完成这一系列 Json 字符串的拼接
- (NSString *)buildFlushJSONStringWithEventRecords:(NSArray<ZAEventRecord *> *)records {
    NSMutableArray *contents = [NSMutableArray arrayWithCapacity:records.count];
    for (ZAEventRecord *record in records) {
        NSString *flushContent = [record flushContent];
        if (flushContent) {
            [contents addObject:flushContent];
        }
    }
    return [NSString stringWithFormat:@"[%@]", [contents componentsJoinedByString:@","]];
}

- (NSString *)buildFlushEncryptJSONStringWithEventRecords:(NSArray<ZAEventRecord *> *)records {
    // 初始化用于保存合并后的事件数据
    NSMutableArray *encryptRecords = [NSMutableArray arrayWithCapacity:records.count];
    // 用于保存当前存在的所有 ekey
    NSMutableArray *ekeys = [NSMutableArray arrayWithCapacity:records.count];
    for (ZAEventRecord *record in records) {
        NSInteger index = [ekeys indexOfObject:record.ekey];
        if (index == NSNotFound) {
            [record removePayload];
            [encryptRecords addObject:record];

            [ekeys addObject:record.ekey];
        } else {
            [encryptRecords[index] mergeSameEKeyRecord:record];
        }
    }
    return [self buildFlushJSONStringWithEventRecords:encryptRecords];
}

// 2. 完成 HTTP 请求拼接
- (NSData *)buildBodyWithJSONString:(NSString *)jsonString isEncrypted:(BOOL)isEncrypted {
    int gzip = 1; // gzip = 9 表示加密编码
    if (isEncrypted) {
        // 加密数据已{经做过 gzip 压缩和 base64 处理了，就不需要再处理。
        gzip = 9;
    } else {
        // 使用gzip进行压缩
        NSData *zippedData = [ZAQuickUtil gzipDeflateWith:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
        // base64
        jsonString = [zippedData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
    }
    int hashCode = za_string_generate_hashcode(jsonString);
    jsonString = [jsonString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet alphanumericCharacterSet]];
    NSString *bodyString = [NSString stringWithFormat:@"crc=%d&gzip=%d&data_list=%@", hashCode, gzip, jsonString];
    return [bodyString dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSURLRequest *)buildFlushRequestWithServerURL:(NSURL *)serverURL HTTPBody:(NSData *)HTTPBody {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:serverURL];
    request.timeoutInterval = 30;
    request.HTTPMethod = @"POST";
    request.HTTPBody = HTTPBody;
    // 普通事件请求，使用标准 UserAgent
    [request setValue:@"ZallAnalytics iOS SDK" forHTTPHeaderField:@"User-Agent"];
    if (ZAModuleManager.sharedInstance.debugMode == ZADebugModeTypeOnly) {
        [request setValue:@"true" forHTTPHeaderField:@"Dry-Run"];
    }

    //Cookie
    [request setValue:[ZallDataSDK.sharedInstance.network cookieWithDecoded:NO] forHTTPHeaderField:@"Cookie"];

    return request;
}

- (void)requestWithRecords:(NSArray<ZAEventRecord *> *)records completion:(void (^)(BOOL success))completion {
    [ZAHTTPSession.sharedInstance.delegateQueue addOperationWithBlock:^{
        // 判断是否加密数据
        
        BOOL isEncrypted = za_quick_enableEncrypt() && records.firstObject.isEncrypted;
        // 拼接 json 数据
        NSString *jsonString = isEncrypted ? [self buildFlushEncryptJSONStringWithEventRecords:records] : [self buildFlushJSONStringWithEventRecords:records];

        // 网络请求回调处理
        ZAURLSessionTaskCompletionHandler handler = ^(NSData * _Nullable data, NSHTTPURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error || ![response isKindOfClass:[NSHTTPURLResponse class]]) {
                ZALogError(@"%@ network failure: %@", self, error ? error : @"Unknown error");
                return completion(NO);
            }

            NSInteger statusCode = response.statusCode;

            NSString *urlResponseContent = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSString *messageDesc = nil;
            if (statusCode >= 200 && statusCode < 300) {
                messageDesc = @"\n【valid message】\n";
            } else {
                messageDesc = @"\n【invalid message】\n";
                if (statusCode >= 300 && ZAModuleManager.sharedInstance.debugMode) {
                    NSString *errMsg = [NSString stringWithFormat:@"%@ flush failure with response '%@'.", self, urlResponseContent];
                    [ZAModuleManager.sharedInstance showDebugModeWarning:errMsg];
                }
            }

            NSDictionary *dict = [ZAJSONUtil JSONObjectWithString:jsonString];
            ZALogDebug(@"%@ %@: %@", self, messageDesc, dict);

            if (statusCode != 200) {
                ZALogError(@"%@ ret_code: %ld, ret_content: %@", self, statusCode, urlResponseContent);
            }

            // 1、开启 debug 模式，都删除；
            // 2、debugOff 模式下，只有 5xx & 404 & 403 不删，其余均删；
            BOOL successCode = (statusCode < 500 || statusCode >= 600) && statusCode != 404 && statusCode != 403;
            BOOL flushSuccess = ZAModuleManager.sharedInstance.debugMode || successCode;
            completion(flushSuccess);
        };

        // 转换成发送的 http 的 body
        NSData *HTTPBody = [self buildBodyWithJSONString:jsonString isEncrypted:isEncrypted];
        NSURLRequest *request = [self buildFlushRequestWithServerURL:ZallDataSDK.sdkInstance.network.serverURL HTTPBody:HTTPBody];
        NSURLSessionDataTask *task = [ZAHTTPSession.sharedInstance dataTaskWithRequest:request completionHandler:handler];
        [task resume];
    }];
}

- (void)flushEventRecords:(NSArray<ZAEventRecord *> *)records completion:(void (^)(BOOL success))completion {
    __block BOOL flushSuccess = NO;
    // 当在程序终止或 debug 模式下，使用线程锁
    BOOL isWait = ZAConfigOptions.sharedInstance.flushBeforeEnterBackground || ZAModuleManager.sharedInstance.debugMode;
    [self requestWithRecords:records completion:^(BOOL success) {
        if (isWait) {
            flushSuccess = success;
            dispatch_semaphore_signal(self.flushSemaphore);
        } else {
            completion(success);
        }
    }];
    if (isWait) {
        dispatch_semaphore_wait(self.flushSemaphore, DISPATCH_TIME_FOREVER);
        completion(flushSuccess);
    }
}

@end
