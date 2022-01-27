//
// ZallDataSDK+ZAAutoTrack.m
// ZallDataSDK
//
// Created by guo on 2022/1/11.
// Copyright © 2022 Zall Data Co., Ltd. All rights reserved.
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

#import "ZallDataSDK+ZAAutoTrack.h"
#import "ZAAutoTrackManager.h"

@implementation ZallDataSDK (ZAAutoTrack)

- (BOOL)isAutoTrackEnabled{
    return [ZAAutoTrackManager defaultManager].isEnable;
}
#pragma mark - TrackView
- (void)trackViewAppClick:(nonnull UIView *)view{
    [self trackViewAppClick:view withProperties:nil];
}


- (void)trackViewAppClick:(nonnull UIView *)view withProperties:(nullable NSDictionary *)properties{
    [ZAAutoTrackManager.defaultManager.trackerAppClick trackEventWithView:view properties:properties];
}

- (void)trackViewScreen:(UIViewController *)viewController{
    [self trackViewScreen:viewController properties:nil];

}
- (void)trackViewScreen:(UIViewController *)viewController properties:(nullable NSDictionary<NSString *,id> *)properties{
    [ZAAutoTrackManager.defaultManager.trackerAppViewScreen trackEventWithViewController:viewController properties:properties];

}


- (void)trackViewScreen:(NSString *)url withProperties:(NSDictionary *)properties{
    [ZAAutoTrackManager.defaultManager.trackerAppViewScreen trackEventWithURL:url properties:properties];
}



#pragma mark - Ignore
- (BOOL)isAutoTrackEventTypeIgnored:(ZAAutoTrackEventType)eventType{
    return [ZAAutoTrackManager.defaultManager isAutoTrackEventTypeIgnored:eventType];
}

- (void)ignoreViewType:(Class)aClass{
    [ZAAutoTrackManager.defaultManager.trackerAppClick ignoreViewType:aClass];
}


- (BOOL)isViewTypeIgnored:(Class)aClass{
    return [ZAAutoTrackManager.defaultManager.trackerAppClick isViewTypeIgnored:aClass];
}

- (void)ignoreAutoTrackViewControllers:(NSArray<NSString *> *)controllers{
    [ZAAutoTrackManager.defaultManager.trackerAppClick ignoreAutoTrackViewControllers:controllers];
    [ZAAutoTrackManager.defaultManager.trackerAppViewScreen ignoreAutoTrackViewControllers:controllers];
}


- (BOOL)isViewControllerIgnored:(UIViewController *)viewController{
    BOOL isIgnoreAppClick = [ZAAutoTrackManager.defaultManager.trackerAppClick isViewControllerIgnored:viewController];
    BOOL isIgnoreAppViewScreen = [ZAAutoTrackManager.defaultManager.trackerAppViewScreen isViewControllerIgnored:viewController];

    return isIgnoreAppClick || isIgnoreAppViewScreen;
}

@end

