//
// ZAProfileEventObjectTests.m
// ZallDataSDKTests
//
// Created by guo on 2021/7/17.
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

#import <XCTest/XCTest.h>
#import "ZAProfileEventObject.h"
#import "ZAConstants+Private.h"
#import "ZallDataSDK.h"

@interface ZAProfileEventObjectTests : XCTestCase

@end

@implementation ZAProfileEventObjectTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    ZAConfigOptions *options = [[ZAConfigOptions alloc] initWithServerURL:@"" launchOptions:nil];
    [ZallDataSDK startWithConfigOptions:options];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testProfileEventObject {
    ZAProfileEventObject *object = [[ZAProfileEventObject alloc] initWithType:ZA_PROFILE_SET];
    XCTAssertTrue([ZA_PROFILE_SET isEqualToString:object.type]);
    XCTAssertTrue([kZALibMethodCode isEqualToString:object.lib.method]);
}

- (void)testProfileIncrementEventObjectValidKeyForChineseCharacters {
    ZAProfileIncrementEventObject *object = [[ZAProfileIncrementEventObject alloc] initWithType:ZA_PROFILE_INCREMENT];
    NSError *error = nil;
    [object zalldata_validKey:@"测试_key" value:@"测试_value" error:&error];
    XCTAssertNotNil(error);
}

- (void)testProfileIncrementEventObjectValidKeyForArrayValue {
    ZAProfileIncrementEventObject *object = [[ZAProfileIncrementEventObject alloc] initWithType:ZA_PROFILE_INCREMENT];
    NSError *error = nil;
    [object zalldata_validKey:@"test_key" value:@[@"test_value"] error:&error];
    XCTAssertNotNil(error);
}

- (void)testProfileIncrementEventObjectValidKeyForStringValue {
    ZAProfileIncrementEventObject *object = [[ZAProfileIncrementEventObject alloc] initWithType:ZA_PROFILE_INCREMENT];
    NSError *error = nil;
    [object zalldata_validKey:@"test_key" value:@"test_value" error:&error];
    XCTAssertNotNil(error);
}

- (void)testProfileIncrementEventObjectValidKeyForNumberValue {
    ZAProfileIncrementEventObject *object = [[ZAProfileIncrementEventObject alloc] initWithType:ZA_PROFILE_INCREMENT];
    NSError *error = nil;
    [object zalldata_validKey:@"test_key" value:@(123) error:&error];
    XCTAssertNil(error);
}

- (void)testProfileAppendEventObjectValidKeyForChineseCharacters {
    ZAProfileAppendEventObject *object = [[ZAProfileAppendEventObject alloc] initWithType:ZA_PROFILE_APPEND];
    NSError *error = nil;
    [object zalldata_validKey:@"测试_key" value:@"测试_value" error:&error];
    XCTAssertNotNil(error);
}

- (void)testProfileAppendEventObjectValidKeyForArrayStringValue {
    ZAProfileAppendEventObject *object = [[ZAProfileAppendEventObject alloc] initWithType:ZA_PROFILE_APPEND];
    NSError *error = nil;
    [object zalldata_validKey:@"test_key" value:@[@"test_value"] error:&error];
    XCTAssertNil(error);
}

- (void)testProfileAppendEventObjectValidKeyForArrayNumberValue {
    ZAProfileAppendEventObject *object = [[ZAProfileAppendEventObject alloc] initWithType:ZA_PROFILE_APPEND];
    NSError *error = nil;
    [object zalldata_validKey:@"test_key" value:@[@(111)] error:&error];
    XCTAssertNotNil(error);
}

- (void)testProfileAppendEventObjectValidKeyForStringValue {
    ZAProfileAppendEventObject *object = [[ZAProfileAppendEventObject alloc] initWithType:ZA_PROFILE_APPEND];
    NSError *error = nil;
    [object zalldata_validKey:@"test_key" value:@"test_value" error:&error];
    XCTAssertNotNil(error);
}

- (void)testProfileAppendEventObjectValidKeyForNumberValue {
    ZAProfileAppendEventObject *object = [[ZAProfileAppendEventObject alloc] initWithType:ZA_PROFILE_APPEND];
    NSError *error = nil;
    [object zalldata_validKey:@"test_key" value:@(123) error:&error];
    XCTAssertNotNil(error);
}

@end
