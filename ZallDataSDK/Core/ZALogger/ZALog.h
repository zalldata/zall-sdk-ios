//
//  ZALog.h
//  Logger
//
//  Created by guo on 2019/12/26.
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define ZALL_ANALYTICS_LOG_MACRO(isAsynchronous, lvl, fnct, ctx, frmt, ...) \
[ZALog log : isAsynchronous                                     \
     level : lvl                                                \
      file : __FILE__                                           \
  function : fnct                                               \
      line : __LINE__                                           \
   context : ctx                                                \
    format : (frmt), ## __VA_ARGS__]


#define ZALogError(frmt, ...)   ZALL_ANALYTICS_LOG_MACRO(YES, ZALogLevelError, __PRETTY_FUNCTION__, 0, frmt, ##__VA_ARGS__)
#define ZALogWarn(frmt, ...)   ZALL_ANALYTICS_LOG_MACRO(YES, ZALogLevelWarn, __PRETTY_FUNCTION__, 0, frmt, ##__VA_ARGS__)
#define ZALogInfo(frmt, ...)   ZALL_ANALYTICS_LOG_MACRO(YES, ZALogLevelInfo, __PRETTY_FUNCTION__, 0, frmt, ##__VA_ARGS__)
#define ZALogDebug(frmt, ...)   ZALL_ANALYTICS_LOG_MACRO(YES, ZALogLevelDebug, __PRETTY_FUNCTION__, 0, frmt, ##__VA_ARGS__)
#define ZALogVerbose(frmt, ...)   ZALL_ANALYTICS_LOG_MACRO(YES, ZALogLevelVerbose, __PRETTY_FUNCTION__, 0, frmt, ##__VA_ARGS__)


typedef NS_OPTIONS(NSUInteger, ZALogLevel) {
    ZALogLevelError = (1 << 0),
    ZALogLevelWarn = (1 << 1),
    ZALogLevelInfo = (1 << 2),
    ZALogLevelDebug = (1 << 3),
    ZALogLevelVerbose = (1 << 4)
};


@interface ZALog : NSObject

+ (instancetype)sharedLog;

@property (atomic, assign) BOOL enableLog;

+ (void)log:(BOOL)asynchronous
      level:(ZALogLevel)level
       file:(const char *)file
   function:(const char *)function
       line:(NSUInteger)line
    context:(NSInteger)context
     format:(NSString *)format, ... NS_FORMAT_FUNCTION(7, 8);

- (void)log:(BOOL)asynchronous
   level:(ZALogLevel)level
    file:(const char *)file
function:(const char *)function
    line:(NSUInteger)line
 context:(NSInteger)context
  format:(NSString *)format, ... NS_FORMAT_FUNCTION(7, 8);

@end

NS_ASSUME_NONNULL_END
