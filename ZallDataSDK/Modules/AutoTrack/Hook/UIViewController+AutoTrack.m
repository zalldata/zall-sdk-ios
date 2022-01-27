//
//  UIViewController+AutoTrack.m
//  ZallDataSDK
//
//  Created by guo on 2017/10/18.
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


#import "UIViewController+AutoTrack.h"
#import "ZallDataSDK.h"
#import "ZALog.h"
#import "ZAAutoTrackManager.h"
#import <objc/runtime.h>
#import "ZAQuickUtil.h"
#import "UIView+ZAProperty.h"
#import "UIView+AutoTrackProperty.h"
#import "ZAWeakDelegate.h"

@implementation UIViewController (AutoTrack)

-(BOOL)za_property_isIgnored{
    return ![[ZAAutoTrackManager defaultManager].trackerAppClick shouldTrackViewController:self];
}
-(NSString *)za_property_screenName{
    return NSStringFromClass([self class]);
}
-(NSString *)za_property_title{
    __block NSString *titleViewContent = nil;
    __block NSString *controllerTitle = nil;
    za_quick_dispatch_sync_on_main_queue(^{
        titleViewContent = self.navigationItem.titleView.za_property_elementContent;
        controllerTitle = self.navigationItem.title;
    });
    
    if (titleViewContent.length > 0) {
        return titleViewContent;
    }

    if (controllerTitle.length > 0) {
        return controllerTitle;
    }
    return nil;
}
 
- (void)za_autoTrack_viewDidAppear:(BOOL)animated {
    // 防止 tabbar 切换，可能漏采 $AppViewScreen 全埋点
    if ([self isKindOfClass:UINavigationController.class]) {
        UINavigationController *nav = (UINavigationController *)self;
        nav.za_autoTrack_previousViewController = nil;
    }

    ZATrackerAppViewScreen *appViewScreenTracker = ZAAutoTrackManager.defaultManager.trackerAppViewScreen;

    // parentViewController 判断，防止开启子页面采集时候的侧滑多采集父页面 $AppViewScreen 事件
    if (self.navigationController && self.parentViewController == self.navigationController) {
        // 全埋点中，忽略由于侧滑部分返回原页面，重复触发 $AppViewScreen 事件
        if (self.navigationController.za_autoTrack_previousViewController == self) {
            return [self za_autoTrack_viewDidAppear:animated];
        }
    }
    
    
    if (ZAConfigOptions.sharedInstance.autoTrackEventType & ZAAutoTrackEventTypeAppViewScreen && (
                                                                          !self.parentViewController ||
                                                                          [self.parentViewController isKindOfClass:[UITabBarController class]] ||
                                                                          [self.parentViewController isKindOfClass:[UINavigationController class]] ||
                                                                          [self.parentViewController isKindOfClass:[UIPageViewController class]] ||
                                                                          [self.parentViewController isKindOfClass:[UISplitViewController class]])) {
        [appViewScreenTracker autoTrackEventWithViewController:self];
    }

    // 标记 previousViewController
    if (self.navigationController && self.parentViewController == self.navigationController) {
        self.navigationController.za_autoTrack_previousViewController = self;
    }

    [self za_autoTrack_viewDidAppear:animated];
}

- (void)za_autoTrack_viewLeave_viewDidAppear:(BOOL)animated {
    ZATrackerAppPageLeave *tracker = [ZAAutoTrackManager defaultManager].trackerAppPageLeave;
    [tracker trackPageEnter:self];
    [self za_autoTrack_viewLeave_viewDidAppear:animated];
}

- (void)za_autoTrack_viewLeave_viewDidDisappear:(BOOL)animated {
    ZATrackerAppPageLeave *tracker = [ZAAutoTrackManager defaultManager].trackerAppPageLeave;
    [tracker trackPageLeave:self];
    [self za_autoTrack_viewLeave_viewDidDisappear:animated];
}


@end
 

@implementation UINavigationController (AutoTrack)

-(void)setZa_autoTrack_previousViewController:(UIViewController *)za_autotrack_previousViewController{
    ZAWeakDelegate *container = [ZAWeakDelegate containerWithWeakDelegate:za_autotrack_previousViewController];
    objc_setAssociatedObject(self, @selector(za_autoTrack_previousViewController), container, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(UIViewController *)za_autoTrack_previousViewController{
    ZAWeakDelegate *container = objc_getAssociatedObject(self, @selector(za_autoTrack_previousViewController));
    return container.weakDelegate;
}
 

@end
