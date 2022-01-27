//
// ZAAppLifeMonitor.m
// ZallDataSDK
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


#import "ZAAppLifeCycleMonitor.h"
#import "ZAQuickUtil.h"
#import "ZALog.h"
#import "ZAConstantsDefin.h"
#import "ZAUtilCheck.h"
#import <UIKit/UIKit.h>


@interface ZAAppLifeCycleMonitor()
@property(nonatomic, strong) NSMutableDictionary *notificetionDict;
@end


@implementation ZAAppLifeCycleMonitor

+(instancetype)sharedInstance{
    static ZAAppLifeCycleMonitor *zaAppLifeCycleMonitor;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        zaAppLifeCycleMonitor = [[ZAAppLifeCycleMonitor alloc] init];
    });
    return zaAppLifeCycleMonitor;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.notificetionDict = @{
            UIApplicationDidBecomeActiveNotification:NSStringFromSelector(@selector(applicationDidBecomeActive:)),
            UIApplicationDidEnterBackgroundNotification:NSStringFromSelector(@selector(applicationDidEnterBackground:)),
            UIApplicationWillTerminateNotification:NSStringFromSelector(@selector(applicationWillTerminate:)),
            kZAAppLifeCycleMonitorWillChangeNotification:NSStringFromSelector(@selector(appLifecycleStateWillChange:)),
            kZAAppLifeCycleMonitorDidChangeNotification:NSStringFromSelector(@selector(appLifecycleStateDidChange:))
        }.mutableCopy;
        if (!za_quick_sceneDelegate()) {
            
            [self.notificetionDict setDictionary:@{
                UIApplicationDidFinishLaunchingNotification:NSStringFromSelector(@selector(applicationDidFinishLaunching:))
            }];
        }
        
        za_quick_dispatch_async_on_main_queue(^{
            UIApplication *application = za_quick_shared_application();
            BOOL isAppStateBackground = application.applicationState == UIApplicationStateBackground;

            self.state = isAppStateBackground ? ZAAppLifeCycleMonitorStatePassiveStart : ZAAppLifeCycleMonitorStateStart;
        });
        
    }
    return self;
}

-(void)beginMonitor{
    if (!za_quick_app_extension()) {
        [self setState:ZAAppLifeCycleMonitorStateInitiativeStart];
        [self addSystemNotification];
    }
}

/// 状态修改
-(void)setState:(ZAAppLifeCycleMonitorState)state{
    if (_state == state) {
        return;
    }
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:2];
    userInfo[kZAAppLifeCycleMonitorNewStateKey] = @(state);
    userInfo[kZAAppLifeCycleMonitorOldStateKey] = @(_state);
    za_quick_post_observer(kZAAppLifeCycleMonitorWillChangeNotification, self, userInfo);
    _state = state;
    za_quick_post_observer(kZAAppLifeCycleMonitorDidChangeNotification,self,userInfo);
  
    
}
/// 添加系统通知
-(void)addSystemNotification{

    [self.notificetionDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        za_quick_add_observer(self, NSSelectorFromString(obj), key, nil);
    }];
    
    
   
    [self.notificetionDict removeAllObjects];

}
#pragma mark - NSNotification
- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    ZALogDebug(@"%s",__func__);
    

    UIApplication *application = za_quick_shared_application();
    BOOL isAppStateBackground = application.applicationState == UIApplicationStateBackground;
    self.state = isAppStateBackground ? ZAAppLifeCycleMonitorStatePassiveStart : ZAAppLifeCycleMonitorStateStart;

}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    ZALogDebug(@"%s",__func__);
 
    if (![notification.object isKindOfClass:[UIApplication class]]) {
        return;
    }

    UIApplication *application = (UIApplication *)notification.object;
    if (application.applicationState != UIApplicationStateActive) {
        return;
    }


    self.state = ZAAppLifeCycleMonitorStateStart;
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    ZALogDebug(@"%s",__func__);

    // 防止主动触发 UIApplicationDidEnterBackgroundNotification
    if (![notification.object isKindOfClass:[UIApplication class]]) {
        return;
    }

    UIApplication *application = (UIApplication *)notification.object;
    if (application.applicationState != UIApplicationStateBackground) {
        return;
    }
    
    self.state = ZAAppLifeCycleMonitorStateEnd;
}



- (void)applicationWillTerminate:(NSNotification *)notification {
    ZALogDebug(@"%s",__func__);

    self.state = ZAAppLifeCycleMonitorStateQuit;
}



- (void)appLifecycleStateWillChange:(NSNotification *)sender {
    NSDictionary *userInfo = sender.userInfo;
    ZAAppLifeCycleMonitorState newState = [userInfo[kZAAppLifeCycleMonitorNewStateKey] integerValue];
    ZAAppLifeCycleMonitorState oldState = [userInfo[kZAAppLifeCycleMonitorOldStateKey] integerValue];
   

    // 热启动
    if (oldState != ZAAppLifeCycleMonitorStateInitiativeStart && newState == ZAAppLifeCycleMonitorStateStart) {
        
        za_check_block(self.lifeCycleWillStart);
        return;
    }

    // 退出
    if (newState == ZAAppLifeCycleMonitorStateEnd) {
        za_check_block(self.lifeCycleWillEnd);
         
    }
}

- (void)appLifecycleStateDidChange:(NSNotification *)sender {
    NSDictionary *userInfo = sender.userInfo;
    ZAAppLifeCycleMonitorState newState = [userInfo[kZAAppLifeCycleMonitorNewStateKey] integerValue];

    // 冷（热）启动
    if (newState == ZAAppLifeCycleMonitorStateStart) {
        za_check_block(self.lifeCycleDidStart);
        
        return;
    }

    // 退出
    if (newState == ZAAppLifeCycleMonitorStateEnd) {
         
        za_check_block(self.lifeCycleDidEnd);

        return;
    }

    // 终止
    if (newState == ZAAppLifeCycleMonitorStateQuit) {
        za_check_block(self.lifeCycleDidQuit);
 
    }
}


 






@end
