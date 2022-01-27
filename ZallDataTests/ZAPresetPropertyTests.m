//
// ZAPresetPropertyTests.m
// ZallDataTests
//
// Created by guo on 2020/2/18.
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
#import "ZAPresetProperty.h"
#import "ZAConstants+Private.h"
#import "ZallDataSDK.h"

@interface ZAPresetPropertyTests : XCTestCase

@property (nonatomic, strong) ZAPresetProperty *presetProperty;
@property (nonatomic, strong) dispatch_queue_t readWriteQueue;

@end

@implementation ZAPresetPropertyTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    NSString *label = [NSString stringWithFormat:@"zalldata.readWriteQueue.%p", self];
    _readWriteQueue = dispatch_queue_create([label UTF8String], DISPATCH_QUEUE_SERIAL);
    _presetProperty = [[ZAPresetProperty alloc] initWithQueue:_readWriteQueue libVersion:[[ZallDataSDK sharedInstance] libVersion]];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    
    _presetProperty = nil;
}

- (void)testAutomaticProperties {
    NSDictionary *automaticProperties = _presetProperty.automaticProperties;
    
    XCTAssertTrue(automaticProperties.count > 0);
}

- (void)testAppVersion {
    NSString *appVersion = _presetProperty.appVersion;
    XCTAssertTrue(!appVersion || [appVersion isEqualToString:_presetProperty.automaticProperties[kZAEventPresetPropertyAppVersion]]);
}

@end
