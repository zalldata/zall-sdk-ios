//
// ZAIdentifierManagerTests.m
// ZallDataSDKTests
//
// Created by guo on 2020/3/26.
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

#import <XCTest/XCTest.h>
#import "ZAIdentifier.h"
#import <ZallDataSDK/ZASecretKey.h>
#import "ZAQuickUtil.h"

@interface ZAIdentifierTests : XCTestCase

@property (nonatomic, strong) ZAIdentifier *identifier;
@property (nonatomic, strong) dispatch_queue_t readWriteQueue;
@property (nonatomic, copy) NSString *deviceId;
@end

@implementation ZAIdentifierTests

- (void)setUp {

    NSString *label = [NSString stringWithFormat:@"zalldata.readWriteQueue.%p", self];
    _readWriteQueue = dispatch_queue_create([label UTF8String], DISPATCH_QUEUE_SERIAL);
    Class class = NSClassFromString(@"ZAIdentifier");
    SEL initWithQueue = NSSelectorFromString(@"initWithLoginIDKey:");
    id classObject = class ? [class alloc]:class;
    if (classObject && [classObject respondsToSelector:initWithQueue]) {
        _identifier = [classObject performSelector:initWithQueue withObject:@""];
        [_identifier logout];
        _deviceId = _identifier.anonymousId;
    }
}

- (void)tearDown {
    _identifier = nil;
    _deviceId = nil;
}

- (void)testAnonymousIdAfterIdentify {
    [_identifier identify:@"new_identifier"];
    
    XCTAssertTrue([_identifier.anonymousId isEqualToString:@"new_identifier"]);
}

- (void)testDistinctIdAfterIdentify {
    [_identifier identify:@"new_identifier"];
    XCTAssertTrue([_identifier.distinctId isEqualToString:@"new_identifier"]);
}

- (void)testAnonymousIdAfterIdentifyEmtpyString {
    [_identifier identify:@""];
    XCTAssertTrue([_identifier.anonymousId isEqualToString:_deviceId]);
}

- (void)testDistinctIdAfterIdentifyEmtpyString {
    [_identifier identify:@""];
    XCTAssertTrue([_identifier.distinctId isEqualToString:_deviceId]);
}

- (void)testAnonymousIdMaxLength {
    // 长度超过 255 会有报错信息，但是可以设置成功
    NSMutableString *str = [[NSMutableString alloc] initWithString:@""];
    for (int i = 0; i < 300; i++) {
        [str appendString:@"a"];
    }
    [_identifier identify:str];
    XCTAssertTrue(_identifier.anonymousId.length == 300);
}

- (void)testLoginIdMaxLength {
    NSMutableString *str = [[NSMutableString alloc] initWithString:@""];
    for (int i = 0; i < 1300; i++) {
        [str appendString:@"a"];
    }
    XCTAssertFalse([_identifier isValidLoginId:str]);
}

- (void)testLoginWithLoginId {
    [_identifier login:@"new_login_id"];
    XCTAssertFalse([_identifier isValidLoginId:_identifier.loginId]);
}

- (void)testLoginWithAnonymousId {
    XCTAssertFalse([_identifier isValidLoginId:_identifier.anonymousId]);
}

- (void)testLoginIdAfterLogin {
    [_identifier login:@"new_login_id"];
    XCTAssertTrue([_identifier.loginId isEqualToString:@"new_login_id"]);
}

- (void)testDistinctIdAfterLogin {
    [_identifier login:@"new_login_id"];
    XCTAssertTrue([_identifier.distinctId isEqualToString:@"new_login_id"]);
}

- (void)testLoginIdAfterLoginEmptyString {
    BOOL result = [_identifier isValidLoginId:@""];
    XCTAssertFalse(result);
}

- (void)testDistinctIdAfterLoginEmptyString {
    [_identifier login:@""];
    XCTAssertTrue([_identifier.distinctId isEqualToString:_identifier.anonymousId]);
}

- (void)testResetAnonymousId {
    [_identifier resetAnonymousId];
    XCTAssertTrue([_identifier.anonymousId isEqualToString:[ZAQuickUtil hardwareID]]);
}

- (void)testLogout {
    [_identifier login:@"new_login_id"];
    [_identifier logout];
    XCTAssertNil(_identifier.loginId);
}

@end
