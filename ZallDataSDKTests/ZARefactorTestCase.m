//
// ZARefactorTestCase.m
// ZallDataSDKTests
//
// Created by guo on 2021/12/28.
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
#import "ZallDataSDK.h"





static NSString* Za_Default_ServerURL = @"http://172.16.90.61:58080/a?service=zall&project=dddssss";

@interface ZARefactorTestCase : XCTestCase

@end

@implementation ZARefactorTestCase

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
      
    ZAConfigOptions *options = [ZAConfigOptions configWithServerURL:Za_Default_ServerURL launchOptions:nil];
    options.autoTrackEventType = ZAAutoTrackEventTypeALL;
    options.sendNetworkPolicy = ZANetworkTypeALL;
    options.enableTrackAppCrash = YES;
    options.sendInterval = 1 * 1000;
    options.sendMaxSize = 100;
    options.enableHeatMap = YES;
    options.enableVisualizedAutoTrack = YES;
    options.enableJavaScriptBridge = YES;
    options.enableLog = YES;
    options.cacheMaxSize = 20000;
    options.enableAutoAddChannelCallbackEvent = YES;
    [ZallDataSDK completeConfigOption:options];
    
    
    [[ZallDataSDK sharedInstance] registerSuperProperties:@{@"AAA":UIDevice.currentDevice.identifierForVendor.UUIDString}];
    
    [[ZallDataSDK sharedInstance] registerDynamicSuperProperties:^NSDictionary * _Nonnull{
        __block UIApplicationState appState;
        if (NSThread.isMainThread) {
            appState = UIApplication.sharedApplication.applicationState;
        }else {
            dispatch_sync(dispatch_get_main_queue(), ^{
                appState = UIApplication.sharedApplication.applicationState;
            });
        }
        return @{@"__APPState__":@(appState)};
    }];
    
    [[ZallDataSDK sharedInstance] trackAppInstallWithProperties:@{@"testValue" : @"testKey"}];
    [[ZallDataSDK sharedInstance] addHeatMapViewControllers:[NSArray arrayWithObject:@"DemoController"]];

    [[ZallDataSDK sharedInstance] enableTrackScreenOrientation:YES];
    [[ZallDataSDK sharedInstance] enableTrackGPSLocation:YES];
    [[ZallDataSDK sharedInstance] addWebViewUserAgentZallDataFlag];

    [[ZallDataSDK sharedInstance] trackEventCallback:^BOOL(NSString * _Nonnull eventName, NSMutableDictionary<NSString *,id> * _Nonnull properties) {
        return YES;
    }];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
