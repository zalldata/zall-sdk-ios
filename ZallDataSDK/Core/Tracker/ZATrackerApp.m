//
// ZAAppTracker.m
// ZallDataSDK
//
// Created by guo on 2021/5/20.
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

#import "ZATrackerApp.h"
#import "ZAJSONUtil.h"
#import "ZAEventTrackObject.h"
#import "ZallDataSDK+ZAPrivate.h"

@implementation ZATrackerApp

#pragma mark - Life Cycle

- (instancetype)init {
    self = [super init];
    if (self) {
        _ignored = NO;
        _passively = NO;
        _ignoredViewControllers = [NSMutableSet set];
    }
    return self;
}

#pragma mark - Public Methods

- (NSString *)eventId {
    return nil;
}

- (void)trackAutoTrackEventWithProperties:(NSDictionary *)properties {
    ZAEventAutoTrackObject *object = [[ZAEventAutoTrackObject alloc] initWithEventId:[self eventId]];
    [ZallDataSDK.sharedInstance asyncTrackEventObject:object properties:properties];
}

- (void)trackPresetEventWithProperties:(NSDictionary *)properties {
    ZAEventPresetTrackObject *object  = [[ZAEventPresetTrackObject alloc] initWithEventId:[self eventId]];
    [ZallDataSDK.sharedInstance asyncTrackEventObject:object properties:properties];
}

- (BOOL)shouldTrackViewController:(UIViewController *)viewController {
    return YES;
}

- (void)ignoreAutoTrackViewControllers:(NSArray<NSString *> *)controllers {
    if (controllers == nil || controllers.count == 0) {
        return;
    }
    [self.ignoredViewControllers addObjectsFromArray:controllers];
}

- (BOOL)isViewControllerIgnored:(UIViewController *)viewController {
    if (viewController == nil) {
        return NO;
    }

    NSString *screenName = NSStringFromClass([viewController class]);
    return [self.ignoredViewControllers containsObject:screenName];
}

- (NSDictionary *)autoTrackViewControllerBlackList {
    static dispatch_once_t onceToken;
    static NSDictionary *allClasses = nil;
    dispatch_once(&onceToken, ^{
        //文件路径
        allClasses = [ZAQuickUtil zaBudleWithJsonName:@"za_autotrack_viewcontroller_blacklist"];
    });
    return allClasses;
}

- (BOOL)isViewController:(UIViewController *)viewController inBlackList:(NSDictionary *)blackList {
    if (!viewController || za_check_empty_dict(blackList)) {
        return NO;
    }

    for (NSString *publicClass in blackList[@"public"]) {
        if ([viewController isKindOfClass:NSClassFromString(publicClass)]) {
            return YES;
        }
    }
    return [(NSArray *)blackList[@"private"] containsObject:NSStringFromClass(viewController.class)];
}

@end
