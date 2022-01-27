//
// ZAEventTracker.h
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
#import "ZAHTTPSession.h"
#import "ZAEventStore.h"
#import "ZAEventBaseObject.h"

NS_ASSUME_NONNULL_BEGIN

extern NSUInteger const ZAEventFlushRecordSize;

@interface ZAEventTracker : NSObject

@property (nonatomic, strong, readonly) ZAEventStore *eventStore;

/// 发送数据
/// @param event 数据包
- (void)trackEvent:(NSDictionary *)event;
- (void)trackEvent:(NSDictionary *)event isSignUp:(BOOL)isSignUp;

/// 立即上传所有缓存数据
- (void)trackForceSendAllEventRecords;
- (void)trackForceSendAllEventRecordsWithCompletion:(void(^ _Nullable)(void))completion;


/// 打包发送数据
/// @param object 数据包
/// @param properties 属性
- (void)trackEventObject:(ZAEventBaseObject *)object properties:(NSDictionary *)properties;


/// 发送H5数据
/// @param eventInfo 事件信息
/// @param enableVerify 是否开启验证
- (void)trackFromH5WithEvent:(NSString *)eventInfo enableVerify:(BOOL)enableVerify;


@end

NS_ASSUME_NONNULL_END
