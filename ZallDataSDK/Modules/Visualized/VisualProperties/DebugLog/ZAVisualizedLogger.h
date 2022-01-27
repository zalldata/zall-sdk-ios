//
// ZAVisualizedLogger.h
// ZallDataSDK
//
// Created by guo on 2021/4/2.
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

#import "ZAAbstractLogger.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ZAVisualizedLoggerDelegate <NSObject>

- (void)loggerMessage:(NSDictionary *)messageDic;

@end

@interface ZALoggerVisualizedFormatter : NSObject <ZALogMessageFormatter>

@end


/// 自定义属性日志打印
@interface ZAVisualizedLogger : ZAAbstractLogger

@property (weak, nonatomic, nullable) id<ZAVisualizedLoggerDelegate> delegate;

@end

#pragma mark -
@interface ZAVisualizedLogger(Build)

/// 构建 log 日志
/// @param title 日志标题
/// @param format 日志详情拼接
+ (NSString *)buildLoggerMessageWithTitle:(NSString *)title message:(NSString *)format, ...;

@end

NS_ASSUME_NONNULL_END
