//
//  AppDelegate.m
//  ZallData
//
//  Created by guo on 15/7/4.
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

#import "AppDelegate.h"
#import <ZallDataSDK/ZallDataSDK.h>
//#import <ZallDataSDKExtension/ZallDataSDKExtension.h>

static NSString* Za_Default_ServerURL = @"http://172.16.90.61:58080/a?service=zall&project=dddssss";

@interface AppDelegate ()

@end
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
 
    ZAConfigOptions *options = [ZAConfigOptions configWithServerURL:Za_Default_ServerURL launchOptions:launchOptions];
    options.autoTrackEventType = ZAAutoTrackEventTypeALL;

    options.sendNetworkPolicy = ZANetworkTypeALL;

    options.enableDeviceOrientation = YES;
    options.enableEncrypt = YES;
    options.enableTrackAppCrash = YES;
    options.sendInterval = 1 * 1000;
    options.sendMaxSize = 100;
    options.enableHeatMap = YES;
    options.enableVisualizedAutoTrack = YES;
    options.enableLocation = YES;
    options.enableJavaScriptBridge = YES;
    options.enableLog = YES;
    options.cacheMaxSize = 20000;
    options.enableDeviceOrientation = YES;
    options.enableDebugMode = YES;
    options.enableAutoAddChannelCallbackEvent = YES;
    [ZallDataSDK completeConfigOption:options];
    
    [ZallDataSharedSDK() addWebViewUserAgentZallDataFlag];
    [ZallDataSharedSDK() enableTrackScreenOrientation:YES];
    [ZallDataSharedSDK() registerSuperProperties:@{@"AAA":UIDevice.currentDevice.identifierForVendor.UUIDString}];
    [ZallDataSharedSDK() trackAppInstallWithProperties:@{@"testValue" : @"testKey"}];
    [ZallDataSharedSDK() registerDynamicSuperProperties:^NSDictionary * _Nonnull{
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
    
     
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {

    if ([ZallDataSDK canHandleURL:url]) {
        [ZallDataSDK handleSchemeUrl:url];
    }
    return NO;
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
    if ([ZallDataSDK canHandleURL:userActivity.webpageURL]) {
        [ZallDataSDK handleSchemeUrl:userActivity.webpageURL];
    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    //@"group.cn.com.ZallData.share"
//    [[ZallDataSDK sharedInstance]trackEventFromExtensionWithGroupIdentifier:@"group.cn.zalldata.ZallData.share" completion:^(NSString *identifiy ,NSArray *events){
//
//    }];
//   NSArray  *eventArray = [[ZAAppExtensionDataManager sharedInstance] readAllEventsWithGroupIdentifier: @"group.cn.com.ZallData.share"];
//    NSLog(@"applicationDidBecomeActive::::::%@",eventArray);
//    for (NSDictionary *dict in eventArray  ) {
//        [[ZallDataSDK sharedInstance]track:dict[ZA_EVENT_NAME] withProperties:dict[ZA_EVENT_PROPERTIES]];
//    }
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    //[[ZAAppExtensionDataManager sharedInstance]deleteEventsWithGroupIdentifier:@"dd"];
    //[[ZAAppExtensionDataManager sharedInstance]readAllEventsWithGroupIdentifier:NULL];
    //[[ZAAppExtensionDataManager sharedInstance]writeEvent:@"eee" properties:@"" groupIdentifier:@"ff"];
    //[[ZAAppExtensionDataManager sharedInstance]fileDataCountForGroupIdentifier:@"ff"];
//    [[ZAAppExtensionDataManager sharedInstance]fileDataArrayWithPath:@"fff" limit:-1];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

