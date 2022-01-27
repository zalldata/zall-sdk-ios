//
// ZABaseEventObjectTests.m
// ZallDataSDKTests
//
// Created by guo on 2021/10/4.
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
#import "ZABaseEventObject.h"
#import "ZallDataSDK.h"
#import "ZAConstants+Private.h"

@interface ZABaseEventObjectTests : XCTestCase

@end

@implementation ZABaseEventObjectTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    ZAConfigOptions *options = [[ZAConfigOptions alloc] initWithServerURL:@"" launchOptions:nil];
    [ZallDataSDK startWithConfigOptions:options];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testEvent {
    // eventId 结构为 {eventName}_D3AC265B_3CC2_4C45_B8F0_3E05A83A9DAE_ZATimer，新增后缀长度为 44
    ZABaseEventObject *object = [[ZABaseEventObject alloc] init];
    NSString *eventName = @"testEventName";
    NSString *uuidString = [NSUUID.UUID.UUIDString stringByReplacingOccurrencesOfString:@"-" withString:@"_"];
    object.eventId = [NSString stringWithFormat:@"%@_%@%@", eventName, uuidString, kZAEventIdSuffix];
    XCTAssertTrue([eventName isEqualToString:object.event]);
}

- (void)testEventId {
    // eventId 结构为 {eventName}_D3AC265B_3CC2_4C45_B8F0_3E05A83A9DAE_ZATimer，新增后缀长度为 44
    ZABaseEventObject *object = [[ZABaseEventObject alloc] init];
    NSString *eventName = @"";
    NSString *uuidString = [NSUUID.UUID.UUIDString stringByReplacingOccurrencesOfString:@"-" withString:@"_"];
    object.eventId = [NSString stringWithFormat:@"%@_%@%@", eventName, uuidString, kZAEventIdSuffix];
    XCTAssertTrue([eventName isEqualToString:object.event]);
}

- (void)testEventNil {
    ZABaseEventObject *object = [[ZABaseEventObject alloc] init];
    XCTAssertNil(object.event);
}

- (void)testEventEmpty {
    ZABaseEventObject *object = [[ZABaseEventObject alloc] init];
    object.eventId = @"";
    XCTAssertTrue([@"" isEqualToString:object.event]);
}

- (void)testIsSignUp {
    ZABaseEventObject *object = [[ZABaseEventObject alloc] init];
    XCTAssertFalse(object.isSignUp);
}

- (void)testValidateEventWithError {
    ZABaseEventObject *object = [[ZABaseEventObject alloc] init];
    NSError *error = nil;
    [object validateEventWithError:&error];
    XCTAssertNil(error);
}

- (void)testJSONObject {
    ZABaseEventObject *object = [[ZABaseEventObject alloc] init];
    NSMutableDictionary *jsonObject = [object jsonObject];
    XCTAssertTrue(jsonObject.count > 0);
}

- (void)testJSONObjectWithLib {
    ZABaseEventObject *object = [[ZABaseEventObject alloc] init];
    NSMutableDictionary *jsonObject = [object jsonObject];
    NSDictionary *lib = jsonObject[kZAEventLib];
    XCTAssertTrue(lib.count > 0);
}

- (void)testAddEventPropertiesWithEmpty {
    ZABaseEventObject *object = [[ZABaseEventObject alloc] init];
    [object addEventProperties:@{}];
    XCTAssertTrue([@{} isEqualToDictionary:object.properties]);
}

- (void)testAddEventProperties {
    ZABaseEventObject *object = [[ZABaseEventObject alloc] init];
    NSDictionary *properties = @{@"abc": @"abcValue", @"ddd": @[@"123"], @"fff": @(999)};
    [object addEventProperties:properties];
    XCTAssertTrue(object.properties.count == 0);
}

- (void)testAddChannelPropertiesWithEmpty {
    ZABaseEventObject *object = [[ZABaseEventObject alloc] init];
    [object addChannelProperties:@{}];
    XCTAssertTrue([@{} isEqualToDictionary:object.properties]);
}

- (void)testAddChannelProperties {
    ZABaseEventObject *object = [[ZABaseEventObject alloc] init];
    NSDictionary *properties = @{@"abc": @"abcValue", @"ddd": @[@"123"], @"fff": @(999)};
    [object addChannelProperties:properties];
    XCTAssertTrue(object.properties.count == 0);
}

- (void)testAddModulePropertiesWithEmpty {
    ZABaseEventObject *object = [[ZABaseEventObject alloc] init];
    [object addModuleProperties:@{}];
    XCTAssertTrue([@{} isEqualToDictionary:object.properties]);
}

- (void)testAddModuleProperties {
    ZABaseEventObject *object = [[ZABaseEventObject alloc] init];
    NSDictionary *properties = @{@"abc": @"abcValue", @"ddd": @[@"123"], @"fff": @(999)};
    [object addModuleProperties:properties];
    XCTAssertTrue(object.properties.count == 0);
}

- (void)testAddSuperPropertiesWithEmpty {
    ZABaseEventObject *object = [[ZABaseEventObject alloc] init];
    [object addSuperProperties:@{}];
    XCTAssertTrue([@{} isEqualToDictionary:object.properties]);
}

- (void)testAddSuperProperties {
    ZABaseEventObject *object = [[ZABaseEventObject alloc] init];
    NSDictionary *properties = @{@"abc": @"abcValue", @"ddd": @[@"123"], @"fff": @(999)};
    [object addSuperProperties:properties];
    XCTAssertTrue(object.properties.count == 0);
}

- (void)testAddCustomPropertiesWithEmpty {
    ZABaseEventObject *object = [[ZABaseEventObject alloc] init];
    NSDictionary *properties = @{};
    NSError *error = nil;
    [object addCustomProperties:properties error:&error];
    XCTAssertNil(error);
}

- (void)testAddCustomProperties {
    ZABaseEventObject *object = [[ZABaseEventObject alloc] init];
    NSDictionary *properties = @{@"abc": @"abcValue", @"ddd": @[@"123"], @"fff": @(999)};
    NSError *error = nil;
    [object addCustomProperties:properties error:&error];
    XCTAssertNil(error);
    XCTAssertTrue([properties isEqualToDictionary:object.properties]);
}

- (void)testAddCustomPropertiesWithNumberKey {
    ZABaseEventObject *object = [[ZABaseEventObject alloc] init];
    NSDictionary *properties = @{@"123abc": @"abcValue", @"ddd": @[@"123"], @"fff": @(999)};
    NSError *error = nil;
    [object addCustomProperties:properties error:&error];
    XCTAssertNotNil(error);
    XCTAssertTrue(object.properties.count == 0);
}

- (void)testAddCustomPropertiesWithIdKey {
    ZABaseEventObject *object = [[ZABaseEventObject alloc] init];
    NSDictionary *properties = @{@"id": @"abcValue", @"ddd": @[@"123"], @"fff": @(999)};
    NSError *error = nil;
    [object addCustomProperties:properties error:&error];
    XCTAssertNotNil(error);
    XCTAssertTrue(object.properties.count == 0);
}

- (void)testAddCustomPropertiesWithTimeKey {
    ZABaseEventObject *object = [[ZABaseEventObject alloc] init];
    NSDictionary *properties = @{@"time": @"abcValue", @"ddd": @[@"123"], @"fff": @(999)};
    NSError *error = nil;
    [object addCustomProperties:properties error:&error];
    XCTAssertNotNil(error);
    XCTAssertTrue(object.properties.count == 0);
}

- (void)testAddCustomPropertiesWithProject {
    ZABaseEventObject *object = [[ZABaseEventObject alloc] init];
    NSDictionary *properties = @{@"$project": @"projectName"};
    NSError *error = nil;
    [object addCustomProperties:properties error:&error];
    XCTAssertNil(error);
    XCTAssertTrue(object.properties.count == 0);
}

- (void)testAddCustomPropertiesWithToken {
    ZABaseEventObject *object = [[ZABaseEventObject alloc] init];
    NSDictionary *properties = @{@"$token": @"token value"};
    NSError *error = nil;
    [object addCustomProperties:properties error:&error];
    XCTAssertNil(error);
    XCTAssertTrue(object.properties.count == 0);
}

- (void)testAddCustomPropertiesTime1 {
    ZABaseEventObject *object = [[ZABaseEventObject alloc] init];
    NSDictionary *properties = @{@"$time": NSDate.date};
    NSError *error = nil;
    [object addCustomProperties:properties error:&error];
    XCTAssertNil(error);
    XCTAssertTrue(object.properties.count == 0);
}

- (void)testAddCustomPropertiesWithInvalidTime {
    ZABaseEventObject *object = [[ZABaseEventObject alloc] init];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:(kZAEventCommonOptionalPropertyTimeInt - 2000) / 1000];
    NSDictionary *properties = @{@"$time": date};
    NSError *error = nil;
    [object addCustomProperties:properties error:&error];
    XCTAssertNil(error);
    XCTAssertTrue(object.properties.count == 0);
    XCTAssertTrue(![date isEqualToDate:[NSDate dateWithTimeIntervalSince1970:(object.timeStamp / 1000)]]);
}

- (void)testAddCustomPropertiesWithValidTime {
    ZABaseEventObject *object = [[ZABaseEventObject alloc] init];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:(kZAEventCommonOptionalPropertyTimeInt + 2000) / 1000];
    NSDictionary *properties = @{@"$time": date};
    NSError *error = nil;
    [object addCustomProperties:properties error:&error];
    XCTAssertNil(error);
    XCTAssertTrue(object.properties.count == 0);
    XCTAssertTrue([date isEqualToDate:[NSDate dateWithTimeIntervalSince1970:(object.timeStamp / 1000)]]);
}

- (void)testAddCustomPropertiesWithNumberTimeValue {
    ZABaseEventObject *object = [[ZABaseEventObject alloc] init];
    NSDictionary *properties = @{@"$time": @(11111111)};
    NSError *error = nil;
    [object addCustomProperties:properties error:&error];
    XCTAssertNil(error);
    XCTAssertTrue(object.properties.count == 0);
}

- (void)testAddCustomPropertiesDeviceId {
    ZABaseEventObject *object = [[ZABaseEventObject alloc] init];
    NSDictionary *properties = @{@"$device_id": @"deviceId"};
    NSError *error = nil;
    [object addCustomProperties:properties error:&error];
    XCTAssertNil(error);
    XCTAssertTrue(object.properties.count == 0);
}

- (void)testAddReferrerTitleWithEmpty {
    ZABaseEventObject *object = [[ZABaseEventObject alloc] init];
    [object addReferrerTitleProperty:@""];
    XCTAssertTrue(object.properties.count == 0);
}

- (void)testAddReferrerTitle {
    ZABaseEventObject *object = [[ZABaseEventObject alloc] init];
    [object addReferrerTitleProperty:@"testTitle"];
    XCTAssertTrue(object.properties.count == 0);
}

- (void)testAddDurationPropertyWithNil {
    ZABaseEventObject *object = [[ZABaseEventObject alloc] init];
    NSNumber *number = nil;
    [object addDurationProperty:number];
    XCTAssertTrue(object.properties.count == 0);
}

- (void)testAddDurationProperty {
    ZABaseEventObject *object = [[ZABaseEventObject alloc] init];
    [object addDurationProperty:@(23)];
    XCTAssertTrue(object.properties.count == 0);
}

- (void)testZalldata_validKeyWithNumberKey {
    ZABaseEventObject *object = [[ZABaseEventObject alloc] init];
    NSError *error = nil;
    [object zalldata_validKey:@(123) value:@"abc" error:&error];
    XCTAssertNotNil(error);
}

- (void)testZalldata_validKeyWithDigitalKey {
    ZABaseEventObject *object = [[ZABaseEventObject alloc] init];
    NSError *error = nil;
    [object zalldata_validKey:@"123" value:@"abc" error:&error];
    XCTAssertNotNil(error);
}

- (void)testZalldata_validKeyWithStringKey {
    ZABaseEventObject *object = [[ZABaseEventObject alloc] init];
    NSError *error = nil;
    [object zalldata_validKey:@"abc" value:NSDate.date error:&error];
    XCTAssertNil(error);
}

- (void)testZalldata_validKeyWithArrayStringValue {
    ZABaseEventObject *object = [[ZABaseEventObject alloc] init];
    NSError *error = nil;
    [object zalldata_validKey:@"abc" value:@[@"123"] error:&error];
    XCTAssertNil(error);
}

- (void)testZalldata_validKeyWithArrayNumberValue {
    ZABaseEventObject *object = [[ZABaseEventObject alloc] init];
    NSError *error = nil;
    [object zalldata_validKey:@"abc" value:@[@(123)] error:&error];
    XCTAssertNotNil(error);
}

@end
