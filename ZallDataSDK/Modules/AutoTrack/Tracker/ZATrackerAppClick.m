//
// ZAAppClickTracker.m
// ZallDataSDK
//
// Created by guo on 2021/4/27.
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

#import "ZATrackerAppClick.h"
#import "ZAEventTrackObject.h"
#import "ZALog.h"
#import "ZAConstantsDefin.h"
#import "ZAAutoTrackManager.h"
#import "ZAAutoTrackProperty.h"
#import "UIView+AutoTrackProperty.h"
#import "ZAUtilCheck.h"
#import "ZAModuleManager.h"
#import "ZAQuickUtil.h"

@interface ZATrackerAppClick ()

@property (nonatomic, strong) NSMutableSet<Class> *ignoredViewTypeList;

@end

@implementation ZATrackerAppClick

#pragma mark - Life Cycle

- (instancetype)init {
    self = [super init];
    if (self) {
        _ignoredViewTypeList = [NSMutableSet set];
    }
    return self;
}

#pragma mark - Override

- (NSString *)eventId {
    return kZAEventNameAppClick;
}

- (BOOL)shouldTrackViewController:(UIViewController *)viewController {
    if ([self isViewControllerIgnored:viewController]) {
        return NO;
    }

    return ![self isBlackListContainsViewController:viewController];
}

#pragma mark - Public Methods

- (void)autoTrackEventWithView:(UIView *)view {
    // 判断时间间隔
    if (![ZAAutoTrackManager isValidAppClickForObject:view]) {
        return;
    }

    NSMutableDictionary *properties = [ZAAutoTrackProperty propertiesWithAutoTrackObject:view viewController:nil];
    if (!properties) {
        return;
    }

    // 保存当前触发时间
    view.za_property_timeIntervalForLastAppClick = za_current_system_time();

    [self autoTrackEventWithView:view properties:properties];
}

- (void)autoTrackEventWithScrollView:(UIScrollView *)scrollView atIndexPath:(NSIndexPath *)indexPath {
    NSMutableDictionary *properties = [ZAAutoTrackProperty propertiesWithAutoTrackObject:(UIScrollView<ZAAutoTrackViewProperty> *)scrollView didSelectedAtIndexPath:indexPath];
    if (!properties) {
        return;
    }
    NSDictionary *dic = [ZAAutoTrackProperty propertiesWithAutoTrackDelegate:scrollView didSelectedAtIndexPath:indexPath];
    [properties addEntriesFromDictionary:dic];

    // 解析 Cell
    UIView *cell = [ZAAutoTrackProperty cellWithScrollView:scrollView selectedAtIndexPath:indexPath];
    if (!cell) {
        return;
    }

    [self autoTrackEventWithView:cell properties:properties];
}

- (void)autoTrackEventWithGestureView:(UIView *)view {
    NSMutableDictionary *properties = [[ZAAutoTrackProperty propertiesWithAutoTrackObject:view] mutableCopy];
    if (properties.count == 0) {
        return;
    }

    [self autoTrackEventWithView:view properties:properties];
}

- (void)trackEventWithView:(UIView *)view properties:(NSDictionary<NSString *,id> *)properties {
    @try {
        if (view == nil) {
            return;
        }
        NSMutableDictionary *eventProperties = [[NSMutableDictionary alloc]init];
        [eventProperties addEntriesFromDictionary:[ZAAutoTrackProperty propertiesWithAutoTrackObject:view isCodeTrack:YES]];
        if (!za_check_empty_dict(properties)) {
            [eventProperties addEntriesFromDictionary:properties];
        }

        // 添加自定义属性
        [ZAModuleManager.sharedInstance visualPropertiesWithView:view completionHandler:^(NSDictionary * _Nullable visualProperties) {
            if (visualProperties) {
                [eventProperties addEntriesFromDictionary:visualProperties];
            }

            [self trackPresetEventWithProperties:eventProperties];
        }];
    } @catch (NSException *exception) {
        ZALogError(@"%@: %@", self, exception);
    }
}

- (void)ignoreViewType:(Class)aClass {
    [_ignoredViewTypeList addObject:aClass];
}

- (BOOL)isViewTypeIgnored:(Class)aClass {
    for (Class obj in _ignoredViewTypeList) {
        if ([aClass isSubclassOfClass:obj]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isIgnoreEventWithView:(UIView *)view {
    return self.isIgnored || [self isViewTypeIgnored:[view class]];
}

#pragma mark – Private Methods

- (BOOL)isBlackListContainsViewController:(UIViewController *)viewController {
    NSDictionary *autoTrackBlackList = [self autoTrackViewControllerBlackList];
    NSDictionary *appClickBlackList = autoTrackBlackList[kZAEventNameAppClick];
    return [self isViewController:viewController inBlackList:appClickBlackList];
}

- (void)autoTrackEventWithView:(UIView *)view properties:(NSDictionary<NSString *, id> * _Nullable)properties {
    if (self.isIgnored) {
        return;
    }

    NSMutableDictionary *eventProperties = [NSMutableDictionary dictionaryWithDictionary:properties];
    [ZAModuleManager.sharedInstance visualPropertiesWithView:view completionHandler:^(NSDictionary * _Nullable visualProperties) {
        if (visualProperties) {
            [eventProperties addEntriesFromDictionary:visualProperties];
        }

        [self trackAutoTrackEventWithProperties:eventProperties];
    }];
}

@end
