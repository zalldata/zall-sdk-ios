//
//  ZALogMessage.m
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

#import "ZALogMessage.h"

@implementation ZALogMessage

- (instancetype)initWithMessage:(NSString *)message level:(ZALogLevel)level file:(NSString *)file function:(NSString *)function line:(NSUInteger)line context:(NSInteger)context timestamp:(NSDate *)timestamp {
    if (self = [super init]) {
        _message = message;
        _level = level;
        _file = file;
        _function = function;
        _line = line;
        _context = context;
        _timestamp = timestamp;
        _fileName = file.lastPathComponent;
    }
    return self;
}

@end
