//
// ZallDataSDK.m
// ZallDataSDK
//
// Created by guo on 2021/12/29.
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
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"


#import "ZallDataSDK.h"
#import "ZallDataSDK+ZAPrivate.h"
#import "ZAConfigOptions+ZAPrivately.h"
#import "ZallDataSDK+ZATrack.h"

@interface ZallDataSDK()

@property (nonatomic, strong) NSTimer * _Nullable timer;


@end
static ZallDataSDK * ZallDataSDKInstance;

@implementation ZallDataSDK
+ (void)completeConfigOption:(ZAConfigOptions *)config{
    NSParameterAssert(config);
   
    if (za_quick_app_extension() || config.isDisableSDK) {
        return;
    }
     
    [[ZallDataSDK sharedInstance] configOption];
}


+ (ZallDataSDK * _Nullable)sharedInstance{
    if (ZAConfigOptions.sharedInstance.isDisableSDK) {
        ZALogDebug(@"ZallDataSDK is Disable");
        return nil;
    }
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ZallDataSDKInstance = [[ZallDataSDK alloc] init];
    });
    
    return ZallDataSDKInstance;
}
+ (ZallDataSDK *)sdkInstance{
    NSAssert(ZallDataSDKInstance, @"请先使用 startWithConfigOptions: 初始化 SDK");

    return ZallDataSDKInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        @try {
            ZAHTTPSession.sharedInstance.securityPolicy = ZAConfigOptions.sharedInstance.securityPolicy;
            self.network = [[ZANetwork alloc] init];
            self.presetProperty = [[ZAPresetProperty alloc] init];
            self.superProperty = [[ZASuperProperty alloc] init];
            self.identifier = [[ZAIdentifier alloc] initWithLoginIDKey:ZAConfigOptions.sharedInstance.loginIDKey];
            
            self.trackTimer = [[ZATrackerAppTimer alloc] init];
            self.eventTracker = [[ZAEventTracker alloc] init];
            self.appLifeCycle = [ZAAppLifeCycleMonitor sharedInstance];

            if (!ZAConfigOptions.sharedInstance.isDisableSDK) {
                [[ZAReachability sharedInstance] startMonitoring];
            }
        } @catch (NSException *exception) {
            ZALogError(@"❌%s error: %@", __FUNCTION__, exception);
        }
        
    }
    return self;
}
-(void)configOption{
    @try {
         
        /// loadModules
        [[ZAModuleManager sharedInstance] loadModules];
        
        /// 添加远程配置
        za_quick_add_observer(self, @selector(remoteConfigManagerModelChanged:), ZA_REMOTE_CONFIG_MODEL_CHANGED_NOTIFICATION, nil);
        /// 生命周期
        [self appLifeCycleBlcoks];
        [self startFlushTimer];
    } @catch (NSException *exception) {
        ZALogError(@"❌%s error: %@", __FUNCTION__, exception);
    }
    
}
- (void)remoteConfigManagerModelChanged:(NSNotification *)sender {
    @try {
        BOOL isDisableDebugMode = [[sender.object valueForKey:@"disableDebugMode"] boolValue];
        if (isDisableDebugMode) {
            ZAModuleManager.sharedInstance.debugMode = ZADebugModeTypeOff;
        }

        BOOL isDisableSDK = [[sender.object valueForKey:@"disableSDK"] boolValue];
        if (isDisableSDK) {
            [self stopForceTimer];
            za_quick_get_class_method(self, @"removeWebViewUserAgent");

            // 停止采集数据之后 flush 本地数据
            [self trackForceSendAll];
        } else {
            [self startFlushTimer];
            za_quick_get_class_method(self, @"appendWebViewUserAgent");
        }
    } @catch(NSException *exception) {
        ZALogError(@"%@ error: %@", self, exception);
    }
}



-(void)appLifeCycleBlcoks{
    
    __weak __typeof(self)weakSelf = self;
    
    self.appLifeCycle.lifeCycleWillStart = ^{
        [ZAQueueManage sdkOperationQueueAsync:^{
            [weakSelf.trackTimer resumeAllEventTimers:za_current_system_time()];
        }];
         
    };
    
    self.appLifeCycle.lifeCycleWillEnd = ^{
        // 清除本次启动解析的来源渠道信息
        [ZAModuleManager.sharedInstance clearUtmProperties];
        // 停止计时器
        [weakSelf stopForceTimer];
        // 遍历 trackTimer
        [ZAQueueManage sdkOperationQueueAsync:^{
            [weakSelf.trackTimer pauseAllEventTimers:za_current_system_time()];
        }];
        // 清除 $referrer
        [[ZAReferrerManager sharedInstance] clearReferrer];
    };
    
    self.appLifeCycle.lifeCycleDidStart = ^{
        [weakSelf trackForceSendAll];
    };
    
    self.appLifeCycle.lifeCycleDidEnd = ^{

        
        UIApplication *application = za_quick_shared_application();
        __block UIBackgroundTaskIdentifier backgroundTaskIdentifier = UIBackgroundTaskInvalid;
        void (^endBackgroundTask)(void) = ^() {
            [application endBackgroundTask:backgroundTaskIdentifier];
            backgroundTaskIdentifier = UIBackgroundTaskInvalid;
        };
        backgroundTaskIdentifier = [application beginBackgroundTaskWithExpirationHandler:endBackgroundTask];
        [ZAQueueManage sdkOperationQueueAsync:^{
            // 上传所有的数据
            [weakSelf.eventTracker trackForceSendAllEventRecordsWithCompletion:endBackgroundTask];
        }];
        
        
    };
    
    self.appLifeCycle.lifeCycleDidQuit = ^{
        [ZAQueueManage sdkOperationQueueSync:^{}];
    };
    [self.appLifeCycle beginMonitor];
}
- (void)startFlushTimer {
    ZALogDebug(@"starting flush timer.");
    za_quick_dispatch_async_on_main_queue(^{
        if (self.timer && [self.timer isValid]) {
            return;
        }

        if (!za_quick_app_extension() && self.appLifeCycle.state != ZAAppLifeCycleMonitorStateStart) {
            return;
        }

        if (ZAConfigOptions.sharedInstance.isDisableSDK) {
            return;
        }
        
        if (ZAConfigOptions.sharedInstance.sendInterval > 0) {
            double interval = ZAConfigOptions.sharedInstance.sendInterval > 100 ? (double)ZAConfigOptions.sharedInstance.sendInterval / 1000.0 : 0.1f;
            self.timer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                          target:self
                                                        selector:@selector(trackForceSendAll)
                                                        userInfo:nil
                                                         repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        }
    });
   
}

- (void)stopForceTimer {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.timer) {
            [self.timer invalidate];
        }
        self.timer = nil;
    });
}


#pragma mark - ZallDataSDKPubic
+ (void)disableSDK:(BOOL)isDisable{
    if (ZAConfigOptions.sharedInstance.disableSDK == isDisable) {
        return;
    }
    ZAConfigOptions.sharedInstance.disableSDK = isDisable;

    ZallDataSDK *instance = ZallDataSDKInstance;
    if (isDisable) {
        [instance track:kZAEventNameAppTrackingClose];
        [instance trackForceSendAll];
        
        [instance clearTrackTimer];
        [instance stopForceTimer];
        [instance removeObservers];
        za_quick_get_class_method(instance, @"removeWebViewUserAgent");
        [ZAReachability.sharedInstance stopMonitoring];
        [ZAModuleManager.sharedInstance disableAllModules];
        ZALogWarn(@"ZallDataSDK disabled");
        [ZALog sharedLog].enableLog = NO;
    }else{
        // 部分模块和监听依赖网络状态，所以需要优先开启
        [ZAReachability.sharedInstance startMonitoring];
        [ZALog sharedLog].enableLog = ZAConfigOptions.sharedInstance.enableLog;

        za_quick_get_class_method(instance, @"appendWebViewUserAgent");

        [instance startFlushTimer];
        [ZAModuleManager.sharedInstance loadModules];
        ZALogInfo(@"ZallDataSDK enabled");
    }
    
   

}

+ (void)updateServerUrl:(NSString *)serverUrl{
    ZAConfigOptions.sharedInstance.serverURL = serverUrl;
}

+ (void)clearReferrerWhenAppEnd{
    [ZAReferrerManager sharedInstance].isClearReferrer = YES;
}

 
+ (NSString *)libVersion{
    static NSString *versionString;
    if (!versionString) {
        NSString * sdkString = [NSString stringWithFormat:@"%s",ZallDataSDKVersionString];
        NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        sdkString = [sdkString stringByTrimmingCharactersInSet:set];
        NSArray * sdkArray = [sdkString componentsSeparatedByString:@"-"];
        versionString = sdkArray.lastObject;
    }
   
    return versionString;
}

+ (BOOL)canHandleURL:(NSURL *)url{
    return [ZAModuleManager.sharedInstance canHandleURL:url];
}

+ (BOOL)handleSchemeUrl:(NSURL *)url{
    if (!url) {
        return NO;
    }
    
    // 退到后台时的网络状态变化不会监听，因此通过 handleSchemeUrl 唤醒 App 时主动获取网络状态
    [[ZAReachability sharedInstance] startMonitoring];

    return [ZAModuleManager.sharedInstance handleURL:url];
}
- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
#pragma clang diagnostic pop
