//
// ZAQueueMange.m
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

#import "ZAQueueManage.h"
#import "ZAQuickUtil.h"

@implementation ZAQueueManage

+(dispatch_queue_t)sdkOperationQueue{
    static dispatch_queue_t sdkOperationQueue = nil;
    if (!sdkOperationQueue) {
        sdkOperationQueue = za_quick_queue_serial_create_char(__func__);
    }
    return sdkOperationQueue;
}

+(dispatch_queue_t)readWriteQueue{
    static dispatch_queue_t readWriteQueue = nil;
    if (!readWriteQueue) {
        readWriteQueue = za_quick_queue_serial_create_char(__func__);
    }
    return readWriteQueue;
}

+(void)sdkOperationQueueAsync:(dispatch_block_t)dispatch_block{
    za_quick_dispatch_async_queue(self.sdkOperationQueue, dispatch_block);
}
+(void)sdkOperationQueueSync:(dispatch_block_t)dispatch_block{
    za_quick_dispatch_sync_safe_queue(self.sdkOperationQueue, dispatch_block);
}
+(void)readWriteQueueAsync:(dispatch_block_t)dispatch_block{
    za_quick_dispatch_async_queue(self.readWriteQueue, dispatch_block);
}

+(void)readWriteQueueSync:(dispatch_block_t)dispatch_block{
    za_quick_dispatch_sync_safe_queue(self.readWriteQueue, dispatch_block);
    
}

@end
