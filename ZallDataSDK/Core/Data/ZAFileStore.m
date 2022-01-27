//
// ZAFileStore.m
// ZallDataSDK
//
// Created by guo on 2020/1/6.
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

#import "ZAFileStore.h"
#import "ZALog.h"

@implementation ZAFileStore

#pragma mark - archive file
+ (BOOL)archiveWithFileName:(NSString *)fileName value:(nullable id)value {
    if (!fileName) {
        ZALogError(@"key should not be nil for file store");
        return NO;
    }
    NSString *filePath = [ZAFileStore filePath:fileName];
   
    /* 为filePath文件设置保护等级 */
    NSDictionary *protection = [NSDictionary dictionaryWithObject:NSFileProtectionComplete
                                                           forKey:NSFileProtectionKey];

    
    [[NSFileManager defaultManager] setAttributes:protection
                                     ofItemAtPath:filePath
                                            error:nil];
    
    if (![NSKeyedArchiver archiveRootObject:value toFile:filePath]) {
        ZALogError(@"%@ unable to archive %@", self, fileName);
        return NO;
    }
    ZALogDebug(@"%@ archived %@", self, fileName);
    return YES;
}

#pragma mark - unarchive file
+ (id)unarchiveWithFileName:(NSString *)fileName {
    if (!fileName) {
        ZALogError(@"key should not be nil for file store");
        return nil;
    }
    NSString *filePath = [ZAFileStore filePath:fileName];
    return [ZAFileStore unarchiveFromFile:filePath];
}

+ (id)unarchiveFromFile:(NSString *)filePath {
    id unarchivedData = nil;
    @try {
        unarchivedData = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    } @catch (NSException *exception) {
        ZALogError(@"%@ unable to unarchive data in %@, starting fresh", self, filePath);
        unarchivedData = nil;
    }
    return unarchivedData;
}

#pragma mark - file path
+ (NSString *)filePath:(NSString *)fileName{
    return [self filePath:fileName withType:@"plist"];
}

+ (NSString *)filePath:(NSString *)fileName withType:(NSString *)aType{
    
    NSString *filename = [NSString stringWithFormat:@"%@.%@", fileName,aType];
    return [[self customWithFilePath:@"ZallDataSDK"] stringByAppendingPathComponent:filename];;
}

+(NSString *)customWithFilePath:(NSString *)filePaht{
    static BOOL isDirectory;
    NSString * dirRootPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
    NSString * dirPath = [dirRootPath stringByAppendingPathComponent:filePaht];
    if (!isDirectory) {
        if (![[NSFileManager defaultManager] fileExistsAtPath:dirPath isDirectory:&isDirectory]) {
            NSError * error;
            [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:&error];
            if (error) {
               ZALogError(@"filepath for error %@", error.userInfo);
               return dirRootPath;
            }
        }
    }
    return dirPath;
}


@end
