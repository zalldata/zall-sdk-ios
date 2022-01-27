//
// ZAAutoTrackManager.m
// ZallDataSDK
//
// Created by guo on 2021/4/2.
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

#import "ZAAutoTrackManager.h"
#import "ZAConfigOptions.h"
#import "ZAModuleManager.h"
#import "ZAAppLifeCycleMonitor.h"
#import "ZALog.h"
#import "UIApplication+AutoTrack.h"
#import "UIViewController+AutoTrack.h"
#import "ZASwizzle.h"
#import "ZATrackerAppStart.h"
#import "ZATrackerAppEnd.h"

#import "ZAAppLifeCycleMonitor.h"
#import "ZAQuickUtil.h"
#import "ZAConstantsDefin.h"
#import "ZAConfigOptions+ZAPrivately.h"
#import "ZAModuleManager.h"
#import "UIGestureRecognizer+ZAAutoTrack.h"
#import "ZAGeneralGestureViewProcessor.h"
#import "ZAGestureViewProcessorFactory.h"
#import "ZallDataSDK+ZAAutoTrack.h"

//event tracker plugins
#if __has_include("ZACellClickHookDelegatePlugin.h")
#import "ZACellClickHookDelegatePlugin.h"
#endif
#import "ZACellClickDynamicSubclassPlugin.h"
#import "ZAEventTrackerPluginManager.h"
#if __has_include("ZAGesturePlugin.h")
#import "ZAGesturePlugin.h"
#endif

@ZAAppLoadModule(ZAAutoTrackManager)
@interface ZAAutoTrackManager ()

@property (nonatomic, assign) ZAAutoTrackModeState autoTrackMode;

@end

@implementation ZAAutoTrackManager

+ (instancetype)defaultManager {
    static dispatch_once_t onceToken;
    static ZAAutoTrackManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[ZAAutoTrackManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _trackerappStart = [[ZATrackerAppStart alloc] init];
        _trackerAppEnd = [[ZATrackerAppEnd alloc] init];
        _trackerAppViewScreen = [[ZATrackerAppViewScreen alloc] init];
        _trackerAppClick = [[ZATrackerAppClick alloc] init];
        _trackerAppPageLeave = [[ZATrackerAppPageLeave alloc] init];
        
        _autoTrackMode = ZAAutoTrackModeStateDefault;
        
         
        self.enable = ZAConfigOptions.sharedInstance.autoTrackEventType > ZAAutoTrackEventTypeNone;
        za_quick_add_observer(self, @selector(appLifecycleStateDidChange:), kZAAppLifeCycleMonitorDidChangeNotification, nil);
        za_quick_add_observer(self, @selector(remoteConfigModelChanged:), ZA_REMOTE_CONFIG_MODEL_CHANGED_NOTIFICATION, nil);

    }
    return self;
}
- (void)setConfigOptions:(ZAConfigOptions *)configOptions {
    
    self.enable = ZAConfigOptions.sharedInstance.autoTrackEventType > ZAAutoTrackEventTypeNone;
}
- (ZAConfigOptions *)configOptions{
    return ZAConfigOptions.sharedInstance;
}

- (void)setEnable:(BOOL)enable {
    [self updateAutoTrackEventType];
    if (enable) {
        [self enableAutoTrack];
        [self registerPlugins];
        return;
    }
    [self.trackerAppPageLeave.timestamp removeAllObjects];
    [self unregisterPlugins];
}

-(BOOL)isEnable{
    if (ZAConfigOptions.sharedInstance.disableSDK) {
        ZALogDebug(@"SDK is disabled");
        return NO;
    }

    NSInteger autoTrackMode = self.autoTrackMode;
    if (autoTrackMode == ZAAutoTrackModeStateDefault) {
        // 远程配置不修改现有的 autoTrack 方式
        return (ZAConfigOptions.sharedInstance.autoTrackEventType != ZAAutoTrackEventTypeNone);
    } else {
        // 远程配置修改现有的 autoTrack 方式
        BOOL isEnabled = (autoTrackMode != ZAAutoTrackModeStateDisabledAll);
        if (!isEnabled) {
            ZALogDebug(@"【remote config】AutoTrack Event is ignored by remote config");
        }
        return isEnabled;
    }
}

#pragma mark - PublicMethod

- (BOOL)isAutoTrackEventTypeIgnored:(ZAAutoTrackEventType)eventType {
    if (ZAConfigOptions.sharedInstance.disableSDK) {
        ZALogDebug(@"SDK is disabled");
        return YES;
    }

    NSInteger autoTrackMode = self.autoTrackMode;
    if (autoTrackMode == ZAAutoTrackModeStateDefault) {
        // 远程配置不修改现有的 autoTrack 方式
        return !(ZAConfigOptions.sharedInstance.autoTrackEventType & eventType);
    } else {
        // 远程配置修改现有的 autoTrack 方式
        BOOL isIgnored = (autoTrackMode == ZAAutoTrackModeStateDisabledAll) ? YES : !(autoTrackMode & eventType);
        if (isIgnored) {
            NSString *ignoredEvent = @"None";
            switch (eventType) {
                case ZAAutoTrackEventTypeAppStart:
                    ignoredEvent = kZAEventNameAppStart;
                    break;

                case ZAAutoTrackEventTypeAppEnd:
                    ignoredEvent = kZAEventNameAppEnd;
                    break;

                case ZAAutoTrackEventTypeAppClick:
                    ignoredEvent = kZAEventNameAppClick;
                    break;

                case ZAAutoTrackEventTypeAppViewScreen:
                    ignoredEvent = kZAEventNameAppViewScreen;
                    break;
                case ZAAutoTrackEventTypeAppViewLeave:
                    ignoredEvent = kZAEventNameAppViewScreen;
                    break;

                default:
                    break;
            }
            ZALogDebug(@"【remote config】%@ is ignored by remote config", ignoredEvent);
        }
        return isIgnored;
    }
}

- (void)updateAutoTrackEventType {
    self.trackerappStart.ignored = [self isAutoTrackEventTypeIgnored:ZAAutoTrackEventTypeAppStart];
    self.trackerAppEnd.ignored = [self isAutoTrackEventTypeIgnored:ZAAutoTrackEventTypeAppEnd];
    
    self.trackerAppClick.ignored = [self isAutoTrackEventTypeIgnored:ZAAutoTrackEventTypeAppClick];
    self.trackerAppViewScreen.ignored = [self isAutoTrackEventTypeIgnored:ZAAutoTrackEventTypeAppViewScreen];
    self.trackerAppPageLeave.ignored = [self isAutoTrackEventTypeIgnored:ZAAutoTrackEventTypeAppViewLeave];

}

- (BOOL)isGestureVisualView:(id)obj {
    if (!self.enable) {
        return NO;
    }
    if (![obj isKindOfClass:UIView.class]) {
        return NO;
    }
    UIView *view = (UIView *)obj;
    for (UIGestureRecognizer *gesture in view.gestureRecognizers) {
        if (gesture.za_autoTrack_gestureTarget) {
            ZAGeneralGestureViewProcessor *processor = [ZAGestureViewProcessorFactory processorWithGesture:gesture];
            if (processor.isTrackable && processor.trackableView == gesture.view) {
                return YES;
            }
        }
    }
    return NO;
}



#pragma mark - ZAAutoTrackModuleProtocol
- (void)trackAppEndWhenCrashed {
    if (!self.enable) {
        return;
    }
    if (self.trackerAppEnd.isIgnored) {
        return;
    }
    za_quick_dispatch_sync_on_main_queue(^{
        if (UIApplication.sharedApplication.applicationState == UIApplicationStateActive) {
            [self.trackerAppEnd autoTrackEvent];
        }
    });
   
}

- (void)trackPageLeaveWhenCrashed {
    if (!self.enable) {
        return;
    }
    if (!(ZAConfigOptions.sharedInstance.autoTrackEventType & ZAAutoTrackEventTypeAppViewLeave)) {
        return;
    }
    za_quick_dispatch_sync_on_main_queue(^{
        if (UIApplication.sharedApplication.applicationState == UIApplicationStateActive) {
            [self.trackerAppPageLeave trackEvents];
        }
    });
     
}

#pragma mark - Notification
- (void)appLifecycleStateDidChange:(NSNotification *)sender {
    if (!self.enable) {
        return;
    }
    ZAAutoTrackEventType type = ZAConfigOptions.sharedInstance.autoTrackEventType;
    
    if (type & ZAAutoTrackEventTypeAppStart || type & ZAAutoTrackEventTypeAppEnd) {
        NSDictionary *userInfo = sender.userInfo;
        ZAAppLifeCycleMonitorState newState = [userInfo[kZAAppLifeCycleMonitorNewStateKey] integerValue];
        ZAAppLifeCycleMonitorState oldState = [userInfo[kZAAppLifeCycleMonitorOldStateKey] integerValue];

        self.trackerappStart.passively = NO;
        self.trackerAppViewScreen.passively = NO;

        // 被动启动
        if (oldState == ZAAppLifeCycleMonitorStateInitiativeStart && newState == ZAAppLifeCycleMonitorStatePassiveStart) {
            self.trackerappStart.passively = YES;
            self.trackerAppViewScreen.passively = YES;
            
            [self.trackerappStart autoTrackEventWithProperties:ZAModuleManager.sharedInstance.utmProperties];
            return;
        }

        // 冷（热）启动
        if (newState == ZAAppLifeCycleMonitorStateStart) {
            // 启动 AppEnd 事件计时器
            [self.trackerAppEnd trackTimerStartAppEnd];
            // 触发启动事件
            [self.trackerappStart autoTrackEventWithProperties:ZAModuleManager.sharedInstance.utmProperties];
            // 热启动时触发被动启动的页面浏览事件
            if (oldState == ZAAppLifeCycleMonitorStatePassiveStart) {
                [self.trackerAppViewScreen trackEventOfLaunchedPassively];
            }
            return;
        }

        // 退出
        if (newState == ZAAppLifeCycleMonitorStateEnd) {
            [self.trackerAppEnd autoTrackEvent];
        }
    }
    
}

- (void)remoteConfigModelChanged:(NSNotification *)sender {
    @try {
        self.autoTrackMode = [[sender.object valueForKey:@"autoTrackMode"] integerValue];

        [self updateAutoTrackEventType];
    } @catch(NSException *exception) {
        ZALogError(@"%@ error: %@", self, exception);
    }
}
#pragma mark – Private Methods
- (void)enableAutoTrack {
    // 监听所有 UIViewController 显示事件
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self enableAppViewScreenAutoTrack];
        [self enableAppClickAutoTrack];
        [self enableAppPageLeave];
    });
}

#pragma mark – za_swizzleMethod
- (void)enableAppViewScreenAutoTrack {
    if (!(ZAConfigOptions.sharedInstance.autoTrackEventType & ZAAutoTrackEventTypeAppViewScreen)) {
        return;
    }
    [UIViewController za_swizzleMethod:@selector(viewDidAppear:)
                            withMethod:@selector(za_autoTrack_viewDidAppear:)
                                 error:NULL];
    
}

- (void)enableAppClickAutoTrack {
    if (!(ZAConfigOptions.sharedInstance.autoTrackEventType & ZAAutoTrackEventTypeAppClick)) {
        return;
    }
    // Actions & Events
    NSError *error = NULL;
    [UIApplication za_swizzleMethod:@selector(sendAction:to:from:forEvent:)
                         withMethod:@selector(za_autotrack_sendAction:to:from:forEvent:)
                              error:&error];
    if (error) {
        ZALogError(@"Failed to swizzle sendAction:to:forEvent: on UIAppplication. Details: %@", error);
        error = NULL;
    }
}

- (void)enableAppPageLeave {
    if (!(ZAConfigOptions.sharedInstance.autoTrackEventType & ZAAutoTrackEventTypeAppViewLeave)) {
        return;
    }
    
    [UIViewController za_swizzleMethod:@selector(viewDidAppear:) withMethod:@selector(za_autoTrack_viewLeave_viewDidAppear:) error:NULL];
    [UIViewController za_swizzleMethod:@selector(viewDidDisappear:) withMethod:@selector(za_autoTrack_viewLeave_viewDidDisappear:) error:NULL];
}

+ (BOOL)isValidAppClickForObject:(id<ZAAutoTrackViewProperty>)object {
    if (!object) {
        return NO;
    }
    
    if (![object respondsToSelector:@selector(za_property_timeIntervalForLastAppClick)]) {
        return YES;
    }

    NSTimeInterval lastTime = object.za_property_timeIntervalForLastAppClick;
    NSTimeInterval currentTime = za_current_system_time();
    if (lastTime > 0 && currentTime - lastTime < ZAConfigOptions.sharedInstance.tarckIntervalTime*1000) {
        return NO;
    }
    return YES;
}

#pragma mark - Plugins
- (void)registerPlugins {
    BOOL enableAppClick = ZAConfigOptions.sharedInstance.autoTrackEventType & ZAAutoTrackEventTypeAppClick;
    if (!enableAppClick) {
        return;
    }
    [[ZAEventTrackerPluginManager defaultManager] registerPlugin:[[ZACellClickDynamicSubclassPlugin alloc] init]];
    [[ZAEventTrackerPluginManager defaultManager] registerPlugin:[[ZAGesturePlugin alloc] init]];

}

- (void)unregisterPlugins {
    //unregister UITableView/UICollectionView cell click plugin
    [[ZAEventTrackerPluginManager defaultManager] unregisterPlugin:[ZACellClickDynamicSubclassPlugin class]];

    //unregister ZAGesturePlugin
    [[ZAEventTrackerPluginManager defaultManager] unregisterPlugin:[ZAGesturePlugin class]];

}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end


 

