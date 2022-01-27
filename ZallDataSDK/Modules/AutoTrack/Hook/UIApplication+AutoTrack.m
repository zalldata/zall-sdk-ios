//
//  UIApplication+AutoTrack.m
//  ZallDataSDK
//
//  Created by guo on 17/3/22.
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

#import "UIApplication+AutoTrack.h"
#import "ZALog.h"
#import "ZallDataSDK.h"
#import "UIViewController+AutoTrack.h"
#import "ZAAutoTrackManager.h"
#import "UIView+ZAProperty.h"
@implementation UIApplication (AutoTrack)

- (BOOL)za_autotrack_sendAction:(SEL)action to:(id)to from:(id)from forEvent:(UIEvent *)event {

    BOOL ret = YES;

    // 针对 tab 切换，采集切换后的页面信息，先执行系统 sendAction 完成页面切换
    BOOL isTabBar = [to isKindOfClass:UITabBar.class] || [to isKindOfClass:UITabBarController.class];
    /*
     默认先执行 AutoTrack
     如果先执行原点击处理逻辑，可能已经发生页面 push 或者 pop，导致获取当前 ViewController 不正确
     可以通过 UIView 扩展属性 zallAnalyticsAutoTrackAfterSendAction，来配置 AutoTrack 是发生在原点击处理函数之前还是之后
     */
    BOOL zaAutoTrackAfterSendAction = [from isKindOfClass:[UIView class]] && [(UIView *)from za_viewPropertyAutoTrackAfterSendAction];
    BOOL autoTrackAfterSendAction = isTabBar || zaAutoTrackAfterSendAction;

    if (autoTrackAfterSendAction) {
        ret = [self za_autotrack_sendAction:action to:to from:from forEvent:event];
    }

    @try {
            [self za_track:action to:to from:from forEvent:event];
    } @catch (NSException *exception) {
        ZALogError(@"%@ error: %@", self, exception);
    }

    if (!autoTrackAfterSendAction) {
        ret = [self za_autotrack_sendAction:action to:to from:from forEvent:event];
    }

    return ret;
}

- (void)za_track:(SEL)action to:(id)to from:(NSObject *)from forEvent:(UIEvent *)event {
    // 过滤多余点击事件，因为当 from 为 UITabBarItem，event 为 nil， 采集下次类型为 button 的事件。
    if ([from isKindOfClass:UITabBarItem.class] || [from isKindOfClass:UIBarButtonItem.class]) {
        return;
    }

    NSObject<ZAAutoTrackViewProperty> *object = (NSObject<ZAAutoTrackViewProperty> *)from;
    if ([object isKindOfClass:[UISwitch class]] ||
        [object isKindOfClass:[UIStepper class]] ||
        [object isKindOfClass:[UISegmentedControl class]] ||
        [object isKindOfClass:[UIPageControl class]]) {
        [ZAAutoTrackManager.defaultManager.trackerAppClick autoTrackEventWithView:(UIView *)object];
        return;
    }

    if ([event isKindOfClass:[UIEvent class]] && event.type == UIEventTypeTouches && [[[event allTouches] anyObject] phase] == UITouchPhaseEnded) {
        [ZAAutoTrackManager.defaultManager.trackerAppClick autoTrackEventWithView:(UIView *)object];
    }
}

@end
