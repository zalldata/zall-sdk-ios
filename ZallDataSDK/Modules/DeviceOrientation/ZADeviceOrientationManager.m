//
//  ZADeviceOrientationManager.m
//  ZallDataSDK
//
//  Created by guo on 2018/5/21.
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

#import <UIKit/UIKit.h>
#import "ZADeviceOrientationManager.h"
#import "ZallDataSDK+ZADeviceOrientation.h"
#import "ZALog.h"

static NSTimeInterval const kZADefaultDeviceMotionUpdateInterval = 0.5;
static NSString * const kZAEventPresetPropertyScreenOrientation = @"$screen_orientation";
@ZAAppLoadModule(ZADeviceOrientationManager)
@interface ZADeviceOrientationManager()

@property (nonatomic, strong) CMMotionManager *cmmotionManager;
@property (nonatomic, strong) NSOperationQueue *updateQueue;
@property (nonatomic, strong) NSString *deviceOrientation;

@end

@implementation ZADeviceOrientationManager

+ (instancetype)defaultManager {
    static dispatch_once_t onceToken;
    static ZADeviceOrientationManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[ZADeviceOrientationManager alloc] init];
    });
    return manager;
}

- (void)setup {
    if (_cmmotionManager) {
        return;
    }
    _cmmotionManager = [[CMMotionManager alloc] init];
    _cmmotionManager.deviceMotionUpdateInterval = kZADefaultDeviceMotionUpdateInterval;
    _updateQueue = [[NSOperationQueue alloc] init];
    _updateQueue.name = @"com.zalldata.analytics.deviceMotionUpdatesQueue";

    [self setupListeners];
}

#pragma mark - ZAModuleProtocol

- (void)setEnable:(BOOL)enable {
    _enable = enable;

    if (enable) {
        [self setup];
        [self startDeviceMotionUpdates];
    } else {
        self.deviceOrientation = nil;
        [self stopDeviceMotionUpdates];
    }
}

- (void)setConfigOptions:(ZAConfigOptions *)configOptions {
    _configOptions = configOptions;
    self.enable = configOptions.enableDeviceOrientation;
}

- (NSDictionary *)properties {
    return self.deviceOrientation ? @{kZAEventPresetPropertyScreenOrientation: self.deviceOrientation} : nil;
}

#pragma mark - Listener

- (void)setupListeners {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    // 这里只需要监听 App 进入后台的原因是在应用启动的时候，远程配置都会去主动开启设备方向监听
    [notificationCenter addObserver:self
                           selector:@selector(applicationDidEnterBackground:)
                               name:UIApplicationDidEnterBackgroundNotification
                             object:nil];
    [notificationCenter addObserver:self
                           selector:@selector(remoteConfigManagerModelChanged:)
                               name:ZA_REMOTE_CONFIG_MODEL_CHANGED_NOTIFICATION
                             object:nil];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    [self stopDeviceMotionUpdates];
}

- (void)remoteConfigManagerModelChanged:(NSNotification *)sender {
    BOOL disableSDK = NO;
    @try {
        disableSDK = [[sender.object valueForKey:@"disableSDK"] boolValue];
    } @catch(NSException *exception) {
        ZALogError(@"%@ error: %@", self, exception);
    }
    if (disableSDK) {
        [self stopDeviceMotionUpdates];
    } else if (self.enable) {
        [self startDeviceMotionUpdates];
    }
}

#pragma mark - Public

- (void)startDeviceMotionUpdates {
    if (self.cmmotionManager.isDeviceMotionAvailable && !self.cmmotionManager.isDeviceMotionActive) {
        __weak ZADeviceOrientationManager *weakSelf = self;
        [self.cmmotionManager startDeviceMotionUpdatesToQueue:self.updateQueue withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
            [weakSelf handleDeviceMotion:motion];
        }];
    }
}

- (void)stopDeviceMotionUpdates {
    if (self.cmmotionManager.isDeviceMotionActive) {
        [self.cmmotionManager stopDeviceMotionUpdates];
    }
}

- (void)handleDeviceMotion:(CMDeviceMotion *)deviceMotion {
    double x = deviceMotion.gravity.x;
    double y = deviceMotion.gravity.y;
    if (fabs(y)  >= fabs(x)) {
        //y>0  UIDeviceOrientationPortraitUpsideDown;
        //y<0  UIDeviceOrientationPortrait;
        self.deviceOrientation = @"portrait";
    } else if (fabs(x) >= fabs(y)) {
        //x>0  UIDeviceOrientationLandscapeRight;
        //x<0  UIDeviceOrientationLandscapeLeft;
        self.deviceOrientation = @"landscape";
    }
}

- (void)dealloc {
    [self stopDeviceMotionUpdates];
    [self.updateQueue cancelAllOperations];
    [self.updateQueue waitUntilAllOperationsAreFinished];
    self.updateQueue = nil;
    self.cmmotionManager = nil;

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
