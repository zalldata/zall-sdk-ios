//
// ZATrackEventObjectTests.m
// ZallDataSDKTests
//
// Created by guo on 2020/9/27.
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
#import "ZATrackEventObject.h"
#import "ZallDataSDK.h"
#import "ZAConstants+Private.h"
#import "ZAPresetProperty.h"

@interface ZATrackEventObjectTests : XCTestCase

@end

@implementation ZATrackEventObjectTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    ZAConfigOptions *options = [[ZAConfigOptions alloc] initWithServerURL:@"" launchOptions:nil];
    [ZallDataSDK startWithConfigOptions:options];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testEventId {
    ZATrackEventObject *object = [[ZATrackEventObject alloc] initWithEventId:@"eventId"];
    XCTAssertTrue([@"eventId" isEqualToString:object.event]);
}

- (void)testValidateEventWithString {
    ZATrackEventObject *object = [[ZATrackEventObject alloc] initWithEventId:@"eventId"];
    NSError *error = nil;
    [object validateEventWithError:&error];
    XCTAssertNil(error);
}

- (void)testValidateEventWithNumber {
    ZATrackEventObject *object = [[ZATrackEventObject alloc] initWithEventId:@(123)];
    NSError *error = nil;
    [object validateEventWithError:&error];
    XCTAssertNotNil(error);
}

- (void)testValidateEventWithEmpty {
    ZATrackEventObject *object = [[ZATrackEventObject alloc] initWithEventId:@""];
    NSError *error = nil;
    [object validateEventWithError:&error];
    XCTAssertNotNil(error);
}

- (void)testValidateEventWithNil {
    ZATrackEventObject *object = [[ZATrackEventObject alloc] initWithEventId:nil];
    NSError *error = nil;
    [object validateEventWithError:&error];
    XCTAssertNotNil(error);
}

- (void)testValidateEventWithDigital {
    ZATrackEventObject *object = [[ZATrackEventObject alloc] initWithEventId:@"123abc"];
    NSError *error = nil;
    [object validateEventWithError:&error];
    XCTAssertNotNil(error);
}

- (void)testAddEventPropertiesWithEmpty {
    ZATrackEventObject *object = [[ZATrackEventObject alloc] initWithEventId:@""];
    [object addEventProperties:@{}];
    XCTAssertTrue([@{} isEqualToDictionary:object.properties]);
}

- (void)testAddEventProperties {
    ZATrackEventObject *object = [[ZATrackEventObject alloc] initWithEventId:@""];
    NSDictionary *properties = @{@"abc": @"abcValue", @"ccc": @[@"123"]};
    [object addEventProperties:properties];
    XCTAssertTrue([properties isEqualToDictionary:object.properties]);
}

- (void)testAddModulePropertiesWithEmpty {
    ZATrackEventObject *object = [[ZATrackEventObject alloc] initWithEventId:@""];
    [object addModuleProperties:@{}];
    XCTAssertTrue([@{} isEqualToDictionary:object.properties]);
}

- (void)testAddModuleProperties {
    ZATrackEventObject *object = [[ZATrackEventObject alloc] initWithEventId:@""];
    NSDictionary *properties = @{@"abc": @"abcValue", @"ccc": @[@"123"]};
    [object addModuleProperties:properties];
    XCTAssertTrue([properties isEqualToDictionary:object.properties]);
}

- (void)testAddSuperProperties {
    ZATrackEventObject *object = [[ZATrackEventObject alloc] initWithEventId:@""];
    NSDictionary *properties = @{@"abc": @"abcValue", @"ccc": @[@"123"]};
    [object addSuperProperties:properties];
    XCTAssertTrue([properties isEqualToDictionary:object.properties]);
}

- (void)testAddSuperPropertiesWithLibAppVersion {
    ZATrackEventObject *object = [[ZATrackEventObject alloc] initWithEventId:@""];
    NSDictionary *properties = @{@"abc": @"abcValue", kZAEventPresetPropertyAppVersion: @"v2.3.0"};
    [object addSuperProperties:properties];
    XCTAssertTrue([properties isEqualToDictionary:object.properties]);
    XCTAssertTrue([@"v2.3.0" isEqualToString:object.lib.appVersion]);
}

- (void)testAddCustomPropertiesWithLibMethodCode {
    ZATrackEventObject *object = [[ZATrackEventObject alloc] initWithEventId:@""];
    NSDictionary *properties = @{@"abc": @"abcValue"};
    NSError *error = nil;
    [object addCustomProperties:properties error:&error];
    XCTAssertNil(error);
    XCTAssertTrue([kZALibMethodCode isEqualToString:object.properties[kZAEventPresetPropertyLibMethod]]);
    XCTAssertTrue([kZALibMethodCode isEqualToString:object.lib.method]);
}

- (void)testAddCustomPropertiesWithNumberLibMethod {
    ZATrackEventObject *object = [[ZATrackEventObject alloc] initWithEventId:@""];
    NSDictionary *properties = @{@"abc": @"abcValue", kZAEventPresetPropertyLibMethod: @(123)};
    NSError *error = nil;
    [object addCustomProperties:properties error:&error];
    XCTAssertNil(error);
    XCTAssertTrue([@(123) isEqualToNumber:object.properties[kZAEventPresetPropertyLibMethod]]);
    XCTAssertTrue([kZALibMethodCode isEqualToString:object.lib.method]);
}

- (void)testAddCustomPropertiesWithStringLibMethod {
    ZATrackEventObject *object = [[ZATrackEventObject alloc] initWithEventId:@""];
    NSDictionary *properties = @{@"abc": @"abcValue", kZAEventPresetPropertyLibMethod: @"test_lib"};
    NSError *error = nil;
    [object addCustomProperties:properties error:&error];
    XCTAssertNil(error);
    XCTAssertTrue([kZALibMethodCode isEqualToString:object.properties[kZAEventPresetPropertyLibMethod]]);
    XCTAssertTrue([kZALibMethodCode isEqualToString:object.lib.method]);
}

- (void)testAddCustomPropertiesWithAutoLibMethod {
    ZATrackEventObject *object = [[ZATrackEventObject alloc] initWithEventId:@""];
    NSDictionary *properties = @{@"abc": @"abcValue", kZAEventPresetPropertyLibMethod: kZALibMethodAuto};
    NSError *error = nil;
    [object addCustomProperties:properties error:&error];
    XCTAssertNil(error);
    XCTAssertTrue([kZALibMethodAuto isEqualToString:object.properties[kZAEventPresetPropertyLibMethod]]);
    XCTAssertTrue([kZALibMethodAuto isEqualToString:object.lib.method]);
}

- (void)testAddCustomPropertiesWithCodeLibMethod {
    ZATrackEventObject *object = [[ZATrackEventObject alloc] initWithEventId:@""];
    NSDictionary *properties = @{@"abc": @"abcValue", kZAEventPresetPropertyLibMethod: kZALibMethodCode};
    NSError *error = nil;
    [object addCustomProperties:properties error:&error];
    XCTAssertNil(error);
    XCTAssertTrue([kZALibMethodCode isEqualToString:object.properties[kZAEventPresetPropertyLibMethod]]);
    XCTAssertTrue([kZALibMethodCode isEqualToString:object.lib.method]);
}

- (void)testAddCustomPropertiesWithTime {
    ZATrackEventObject *object = [[ZATrackEventObject alloc] initWithEventId:@""];
    NSDictionary *properties = @{@"time": @"abcValue"};
    NSError *error = nil;
    [object addCustomProperties:properties error:&error];
    XCTAssertNotNil(error);
}

- (void)testAddReferrerTitleProperty {
    ZATrackEventObject *object = [[ZATrackEventObject alloc] initWithEventId:@""];
    [object addReferrerTitleProperty:@"test_referrer_title"];
    XCTAssertTrue([@"test_referrer_title" isEqualToString:object.properties[kZAEeventPropertyReferrerTitle]]);
}

- (void)testAddDurationProperty {
    ZATrackEventObject *object = [[ZATrackEventObject alloc] initWithEventId:@""];
    [object addDurationProperty:@(123)];
    XCTAssertTrue([@(123) isEqualToNumber:object.properties[@"event_duration"]]);
}

- (void)testAddDurationPropertyWithNil {
    ZATrackEventObject *object = [[ZATrackEventObject alloc] initWithEventId:@""];
    [object addDurationProperty:nil];
    XCTAssertNil(object.properties[@"event_duration"]);
}

- (void)testCustomEventObject {
    ZACustomEventObject *object = [[ZACustomEventObject alloc] initWithEventId:@"event"];
    XCTAssertTrue([object.type isEqualToString:kZAEventTypeTrack]);
}

- (void)testCustomEventObjectAddChannelPropertiesWithEmpty {
    ZACustomEventObject *object = [[ZACustomEventObject alloc] initWithEventId:@"event"];
    [object addChannelProperties:@{}];
    XCTAssertTrue([@{} isEqualToDictionary:object.properties]);
}

- (void)testCustomEventObjectAddChannelProperties {
    ZACustomEventObject *object = [[ZACustomEventObject alloc] initWithEventId:@"event"];
    [object addChannelProperties:@{@"jjj": @[@"123"]}];
    XCTAssertTrue([@{@"jjj": @[@"123"]} isEqualToDictionary:object.properties]);
}

- (void)testCustomEventObjectValidateEventWithErrorForReserveEvent {
    ZACustomEventObject *object = [[ZACustomEventObject alloc] initWithEventId:@"event"];
    NSError *error = nil;
    [object validateEventWithError:&error];
    XCTAssertNotNil(error);
}

- (void)testCustomEventObjectValidateEventWithError {
    ZACustomEventObject *object = [[ZACustomEventObject alloc] initWithEventId:@"eventName"];
    NSError *error = nil;
    [object validateEventWithError:&error];
    XCTAssertNil(error);
}

- (void)testCustomEventObjectValidateEventWithErrorForAppStart {
    ZACustomEventObject *object = [[ZACustomEventObject alloc] initWithEventId:kZAEventNameAppStart];
    NSError *error = nil;
    [object validateEventWithError:&error];
    XCTAssertNil(error);
}

- (void)testCustomEventObjectValidateEventWithErrorForAppStartPassively {
    ZACustomEventObject *object = [[ZACustomEventObject alloc] initWithEventId:kZAEventNameAppStartPassively];
    NSError *error = nil;
    [object validateEventWithError:&error];
    XCTAssertNil(error);
}

- (void)testCustomEventObjectValidateEventWithErrorForAppEnd {
    ZACustomEventObject *object = [[ZACustomEventObject alloc] initWithEventId:kZAEventNameAppEnd];
    NSError *error = nil;
    [object validateEventWithError:&error];
    XCTAssertNil(error);
}

- (void)testCustomEventObjectValidateEventWithErrorForAppViewScreen {
    ZACustomEventObject *object = [[ZACustomEventObject alloc] initWithEventId:kZAEventNameAppViewScreen];
    NSError *error = nil;
    [object validateEventWithError:&error];
    XCTAssertNil(error);
}

- (void)testCustomEventObjectValidateEventWithErrorForAppClick {
    ZACustomEventObject *object = [[ZACustomEventObject alloc] initWithEventId:kZAEventNameAppClick];
    NSError *error = nil;
    [object validateEventWithError:&error];
    XCTAssertNil(error);
}

- (void)testCustomEventObjectValidateEventWithErrorForSignUp {
    ZACustomEventObject *object = [[ZACustomEventObject alloc] initWithEventId:kZAEventNameSignUp];
    NSError *error = nil;
    [object validateEventWithError:&error];
    XCTAssertNil(error);
}

- (void)testCustomEventObjectValidateEventWithErrorForAppCrashed {
    ZACustomEventObject *object = [[ZACustomEventObject alloc] initWithEventId:kZAEventNameAppCrashed];
    NSError *error = nil;
    [object validateEventWithError:&error];
    XCTAssertNil(error);
}

- (void)testSignUpEventObjectForIsSignUp {
    ZASignUpEventObject *object = [[ZASignUpEventObject alloc] initWithEventId:kZAEventNameSignUp];
    XCTAssertTrue(object.isSignUp);
}

- (void)testSignUpEventObjectForEventType {
    ZASignUpEventObject *object = [[ZASignUpEventObject alloc] initWithEventId:kZAEventNameSignUp];
    XCTAssertTrue([kZAEventTypeSignup isEqualToString:object.type]);
}

- (void)testSignUpEventObjectAddModulePropertiesWithEmpty {
    ZASignUpEventObject *object = [[ZASignUpEventObject alloc] initWithEventId:kZAEventNameSignUp];
    [object addModuleProperties:@{}];
    XCTAssertTrue([@{} isEqualToDictionary:object.properties]);
}

- (void)testSignUpEventObjectAddModuleProperties {
    ZASignUpEventObject *object = [[ZASignUpEventObject alloc] initWithEventId:kZAEventNameSignUp];
    NSDictionary *properties = @{@"abc": @"abcValue", @"ccc": @[@"123"]};
    [object addModuleProperties:properties];
    XCTAssertTrue([@{} isEqualToDictionary:object.properties]);
}

- (void)testSignUpEventObjectJsonObjectWithOriginalId {
    ZASignUpEventObject *object = [[ZASignUpEventObject alloc] initWithEventId:kZAEventNameSignUp];
    object.originalId = @"test_signup_originalId";
    NSDictionary *properties = [object jsonObject];
    XCTAssertTrue([properties[@"original_id"] isEqualToString:@"test_signup_originalId"]);
}

- (void)testAutoTrackEventObject {
    ZAAutoTrackEventObject *object = [[ZAAutoTrackEventObject alloc] initWithEventId:kZAEventNameAppStart];
    XCTAssertTrue([kZAEventTypeTrack isEqualToString:object.type]);
}

- (void)testAutoTrackEventObjectAddCustomPropertiesWithNil {
    ZAAutoTrackEventObject *object = [[ZAAutoTrackEventObject alloc] initWithEventId:kZAEventNameAppStart];
    NSDictionary *properties = nil;
    NSError *error = nil;
    [object addCustomProperties:properties error:&error];
    XCTAssertNil(error);
    XCTAssertTrue([kZALibMethodAuto isEqualToString:object.properties[kZAEventPresetPropertyLibMethod]]);
    XCTAssertTrue([kZALibMethodAuto isEqualToString:object.lib.method]);
}

- (void)testAutoTrackEventObjectAddCustomProperties {
    ZAAutoTrackEventObject *object = [[ZAAutoTrackEventObject alloc] initWithEventId:kZAEventNameAppStart];
    NSDictionary *properties = @{@"abc": @"abcValue"};
    NSError *error = nil;
    [object addCustomProperties:properties error:&error];
    XCTAssertNil(error);
    XCTAssertTrue([kZALibMethodAuto isEqualToString:object.properties[kZAEventPresetPropertyLibMethod]]);
    XCTAssertTrue([kZALibMethodAuto isEqualToString:object.lib.method]);
}

- (void)testAutoTrackEventObjectAddCustomPropertiesWithAppStartLibDetail {
    ZAAutoTrackEventObject *object = [[ZAAutoTrackEventObject alloc] initWithEventId:kZAEventNameAppStart];
    NSDictionary *properties = @{@"abc": @"abcValue", @"$screen_name": @"HomePageViewController"};
    NSError *error = nil;
    [object addCustomProperties:properties error:&error];
    XCTAssertNil(error);
    XCTAssertTrue([kZALibMethodAuto isEqualToString:object.properties[kZAEventPresetPropertyLibMethod]]);
    XCTAssertTrue([kZALibMethodAuto isEqualToString:object.lib.method]);
    XCTAssertNil(object.lib.detail);
}

- (void)testAutoTrackEventObjectAddCustomPropertiesWithAppEndLibDetail {
    ZAAutoTrackEventObject *object = [[ZAAutoTrackEventObject alloc] initWithEventId:kZAEventNameAppEnd];
    NSDictionary *properties = @{@"abc": @"abcValue", @"$screen_name": @"HomePageViewController"};
    NSError *error = nil;
    [object addCustomProperties:properties error:&error];
    XCTAssertNil(error);
    XCTAssertTrue([kZALibMethodAuto isEqualToString:object.properties[kZAEventPresetPropertyLibMethod]]);
    XCTAssertTrue([kZALibMethodAuto isEqualToString:object.lib.method]);
    XCTAssertNil(object.lib.detail);
}

- (void)testAutoTrackEventObjectAddCustomPropertiesWithAppViewScreenLibDetail {
    ZAAutoTrackEventObject *object = [[ZAAutoTrackEventObject alloc] initWithEventId:kZAEventNameAppViewScreen];
    NSDictionary *properties = @{@"abc": @"abcValue", @"$screen_name": @"HomePageViewController"};
    NSError *error = nil;
    [object addCustomProperties:properties error:&error];
    XCTAssertNil(error);
    XCTAssertTrue([kZALibMethodAuto isEqualToString:object.properties[kZAEventPresetPropertyLibMethod]]);
    XCTAssertTrue([kZALibMethodAuto isEqualToString:object.lib.method]);
    XCTAssertNotNil(object.lib.detail);
}

- (void)testAutoTrackEventObjectAddCustomPropertiesWithAppClickLibDetail {
    ZAAutoTrackEventObject *object = [[ZAAutoTrackEventObject alloc] initWithEventId:kZAEventNameAppClick];
    NSDictionary *properties = @{@"abc": @"abcValue", @"$screen_name": @"HomePageViewController"};
    NSError *error = nil;
    [object addCustomProperties:properties error:&error];
    XCTAssertNil(error);
    XCTAssertTrue([kZALibMethodAuto isEqualToString:object.properties[kZAEventPresetPropertyLibMethod]]);
    XCTAssertTrue([kZALibMethodAuto isEqualToString:object.lib.method]);
    XCTAssertNotNil(object.lib.detail);
}

- (void)testPresetEventObject {
    ZAPresetEventObject *object = [[ZAPresetEventObject alloc] initWithEventId:@"eventName"];
    XCTAssertTrue([kZAEventTypeTrack isEqualToString:object.type]);
}

@end
