//
// ZAQueueMange.h
// ZallDataSDK
//
// Created by guo on 2021/12/29.
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

#import <Foundation/Foundation.h>
#import "ZAQuickUtil.h"

NS_ASSUME_NONNULL_BEGIN



@interface ZAQueueManage : NSObject

/**
 *@abstract sdk操作相关队列
 *
 *@discussion 串行队列
 *
 *@return 指定队列
 */
+(dispatch_queue_t)sdkOperationQueue;
/**
 *@abstract sdk数据读取相关队列
 *
 *@discussion 串行队列
 *
 *@return 指定队列
 */
+(dispatch_queue_t)readWriteQueue;

/**
 *@abstract 异步操作sdkOperationQueue
 *
 *@discussion 异步操作sdkOperationQueue
 *
 *@param dispatch_block 异步实现
 */
+(void)sdkOperationQueueAsync:(dispatch_block_t)dispatch_block;

+(void)sdkOperationQueueSync:(dispatch_block_t)dispatch_block;

 
/**
 *@abstract 异步操作sdkOperationQueue
 *
 *@discussion 异步操作sdkOperationQueue
 *
 *@param dispatch_block 异步实现
 */
+(void)readWriteQueueAsync:(dispatch_block_t)dispatch_block;

+(void)readWriteQueueSync:(dispatch_block_t)dispatch_block;

@end

NS_ASSUME_NONNULL_END
