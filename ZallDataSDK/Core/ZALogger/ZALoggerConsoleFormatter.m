//
//  ZALoggerConsoleColorFormatter.m
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

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag on this file.
#endif

#import "ZALoggerConsoleFormatter.h"
#import "ZALogMessage.h"
#import "ZALog+Private.h"

@implementation ZALoggerConsoleFormatter

- (instancetype)init {
    self = [super init];
    if (self) {
        _prefix = @"";
    }
    return self;
}

- (NSString *)formattedLogMessage:(nonnull ZALogMessage *)logMessage {
    NSString *prefixEmoji = @"";
    NSString *levelString = @"";
    switch (logMessage.level) {
        case ZALogLevelError:
            prefixEmoji = @"❌";
            levelString = @"Error";
            break;
        case ZALogLevelWarn:
            prefixEmoji = @"⚠️";
            levelString = @"Warn";
            break;
        case ZALogLevelInfo:
            prefixEmoji = @"ℹ️";
            levelString = @"Info";
            break;
        case ZALogLevelDebug:
            prefixEmoji = @"🛠";
            levelString = @"Debug";
            break;
        case ZALogLevelVerbose:
            prefixEmoji = @"📝";
            levelString = @"Verbose";
            break;
        default:
            break;
    }
    
    NSString *dateString = [[ZALog sharedLog].dateFormatter stringFromDate:logMessage.timestamp];
    NSString *line = [NSString stringWithFormat:@"%lu", logMessage.line];
    return [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@ line:%@ %@\n", dateString, prefixEmoji, levelString, self.prefix, logMessage.fileName, logMessage.function, line, logMessage.message];
}

@end
