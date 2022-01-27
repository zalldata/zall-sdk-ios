//
//  ZAVisualizedSnapshotMessage.m
//  ZallDataSDK
//
//  Created by guo on 2018/9/4.
//  Copyright © 2015-2020 Zall Data Co., Ltd. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag on this file.
#endif


#import <CommonCrypto/CommonDigest.h>
#import "ZAVisualizedSnapshotMessage.h"
#import "ZAApplicationStateSerializer.h"
#import "ZAObjectIdentityProvider.h"
#import "ZAObjectSerializerConfig.h"
#import "ZAVisualizedConnection.h"
#import "ZAVisualizedManager.h"
#import "ZAVisualizedObjectSerializerManager.h"
#import "ZAQuickUtil.h"

#pragma mark -- Snapshot Request

NSString * const ZAVisualizedSnapshotRequestMessageType = @"snapshot_request";

static NSString * const kSnapshotSerializerConfigKey = @"snapshot_class_descriptions";

@implementation ZAVisualizedSnapshotRequestMessage

+ (instancetype)message {
    return [(ZAVisualizedSnapshotRequestMessage *)[self alloc] initWithType:ZAVisualizedSnapshotRequestMessageType];
}

- (ZAObjectSerializerConfig *)configuration {
    NSDictionary *config = [self payloadObjectForKey:@"config"];
    return config ? [[ZAObjectSerializerConfig alloc] initWithDictionary:config] : nil;
}


// 构建页面信息，包括截图和元素数据
- (NSOperation *)responseCommandWithConnection:(ZAVisualizedConnection *)connection {
    ZAObjectSerializerConfig *serializerConfig = self.configuration;

    __weak ZAVisualizedConnection *weak_connection = connection;
    NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        __strong ZAVisualizedConnection *conn = weak_connection;

        // Get the object identity provider from the connection's session store or create one if there is none already.
        ZAObjectIdentityProvider *objectIdentityProvider = [[ZAObjectIdentityProvider alloc] init];

        ZAApplicationStateSerializer *serializer = [[ZAApplicationStateSerializer alloc] initWithConfiguration:serializerConfig objectIdentityProvider:objectIdentityProvider];

        ZAVisualizedSnapshotResponseMessage *snapshotMessage = [ZAVisualizedSnapshotResponseMessage message];

        dispatch_async(dispatch_get_main_queue(), ^{
            [serializer screenshotImageForAllWindowWithCompletionHandler:^(UIImage *image) {
                // 添加待校验事件
                snapshotMessage.debugEvents = ZAVisualizedManager.defaultManager.eventCheck.eventCheckResult;
                // 清除事件缓存
                [ZAVisualizedManager.defaultManager.eventCheck cleanEventCheckResult];

                // 添加诊断信息
                snapshotMessage.logInfos = ZAVisualizedManager.defaultManager.visualPropertiesTracker.logInfos;

                // 最后构建截图，并设置 imageHash
                snapshotMessage.screenshot = image;

                // payloadHash 不变即截图相同，页面不变，则不再解析页面元素信息
                if ([[ZAVisualizedObjectSerializerManager sharedInstance].lastPayloadHash isEqualToString:snapshotMessage.payloadHash]) {
                    [conn sendMessage:[ZAVisualizedSnapshotResponseMessage message]];

                    // 不包含页面元素等数据，只发送页面基本信息，重置 payloadHash 为截图 hash
                    [[ZAVisualizedObjectSerializerManager sharedInstance] resetLastPayloadHash:snapshotMessage.originImageHash];
                } else {
                    // 清空页面配置信息
                    [[ZAVisualizedObjectSerializerManager sharedInstance] resetObjectSerializer];

                    // 解析页面信息
                    NSDictionary *serializedObjects = [serializer objectHierarchyForRootObject];
                    snapshotMessage.serializedObjects = serializedObjects;
                    [conn sendMessage:snapshotMessage];

                    // 重置 payload hash 信息
                    [[ZAVisualizedObjectSerializerManager sharedInstance] resetLastPayloadHash:snapshotMessage.payloadHash];
                }
            }];
        });
    }];

    return operation;
}

@end

#pragma mark -- Snapshot Response
@interface ZAVisualizedSnapshotResponseMessage()
@property (nonatomic, copy, readwrite) NSString *originImageHash;
@end

@implementation ZAVisualizedSnapshotResponseMessage

+ (instancetype)message {
    return [(ZAVisualizedSnapshotResponseMessage *)[self alloc] initWithType:@"snapshot_response"];
}

- (void)setScreenshot:(UIImage *)screenshot {
    id payloadObject = nil;
    NSString *imageHash = nil;
    if (screenshot) {
        NSData *jpegSnapshotImageData = UIImageJPEGRepresentation(screenshot, 0.5);
        if (jpegSnapshotImageData) {
            payloadObject = [jpegSnapshotImageData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
            imageHash = [ZAQuickUtil hashStringWithData:jpegSnapshotImageData];

            // 保留原始图片 hash 值
            self.originImageHash = imageHash;
        }
    }

    // 如果包含其他数据，拼接到 imageHash，防止前端数据未刷新
    NSString *payloadHash = [[ZAVisualizedObjectSerializerManager sharedInstance] fetchPayloadHashWithImageHash:imageHash];

    self.payloadHash = payloadHash;
    [self setPayloadObject:payloadObject forKey:@"screenshot"];
    [self setPayloadObject:payloadHash forKey:@"image_hash"];
}

- (void)setDebugEvents:(NSArray<NSDictionary *> *)debugEvents {
    if (debugEvents.count == 0) {
        return;
    }
    
    // 更新 imageHash
    [[ZAVisualizedObjectSerializerManager sharedInstance] refreshPayloadHashWithData:debugEvents];
    
    [self setPayloadObject:debugEvents forKey:@"event_debug"];
}

- (void)setLogInfos:(NSArray<NSDictionary *> *)logInfos {
    if (logInfos.count == 0) {
        return;
    }
    // 更新 imageHash
    [[ZAVisualizedObjectSerializerManager sharedInstance] refreshPayloadHashWithData:logInfos];

    [self setPayloadObject:logInfos forKey:@"log_info"];
}

- (UIImage *)screenshot {
    NSString *base64Image = [self payloadObjectForKey:@"screenshot"];
    NSData *imageData =[[base64Image dataUsingEncoding:NSUTF8StringEncoding] base64EncodedDataWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
    return imageData ? [UIImage imageWithData:imageData] : nil;
}

- (void)setSerializedObjects:(NSDictionary *)serializedObjects {
    [self setPayloadObject:serializedObjects forKey:@"serialized_objects"];
}

- (NSDictionary *)serializedObjects {
    return [self payloadObjectForKey:@"serialized_objects"];
}

@end



