//
// ZAAppPageLeaveTracker.m
// ZallDataSDK
//
// Created by guo on 2021/7/19.
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

#import "ZATrackerAppPageLeave.h"
#import "ZAConstantsDefin.h"
#import "ZAEventTrackObject.h"
#import "ZAAppLifeCycleMonitor.h"
#import "ZAAutoTrackProperty.h"
#import "ZallDataSDK+ZAPrivate.h"

@interface ZATrackerAppPageLeave ()

@property (nonatomic, copy, readwrite) NSDictionary *referrerProperties;
@property (nonatomic, copy, readwrite) NSString *referrerURL;
@end

@implementation ZATrackerAppPageLeave

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appLifecycleStateDidChange:) name:kZAAppLifeCycleMonitorDidChangeNotification object:nil];
        
    }
    return self;
}

 
- (void)appLifecycleStateDidChange:(NSNotification *)sender {
    if (self.isIgnored) {
        return;
    }
    NSDictionary *userInfo = sender.userInfo;
    ZAAppLifeCycleMonitorState newState = [userInfo[kZAAppLifeCycleMonitorNewStateKey] integerValue];
    if (newState == ZAAppLifeCycleMonitorStateStart) {
        [self.timestamp enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSMutableDictionary * _Nonnull obj, BOOL * _Nonnull stop) {
            obj[kZAPageLeaveTimestamp] = @([[NSDate date] timeIntervalSince1970]);
        }];
        
        return;
    }
    // 退出
    if (newState == ZAAppLifeCycleMonitorStateEnd) {
        [self trackEvents];
        return;
    }

}




- (NSString *)eventId {
    return kZAEventNameAppPageLeave;
}

- (void)trackEvents {
    [self.timestamp enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSMutableDictionary * _Nonnull obj, BOOL * _Nonnull stop) {
        NSTimeInterval currentTimestamp = [[NSDate date] timeIntervalSince1970];
        NSNumber *timestamp = obj[kZAPageLeaveTimestamp];
        NSTimeInterval startTimestamp = [timestamp doubleValue];
        NSMutableDictionary *tempProperties = [[NSMutableDictionary alloc] initWithDictionary:obj[kZAPageLeaveAutoTrackProperties]];
        NSTimeInterval duration = (currentTimestamp - startTimestamp) < 24 * 60 * 60 ? (currentTimestamp - startTimestamp) : 0;
        tempProperties[kZAEventDurationProperty] = @([[NSString stringWithFormat:@"%.3f", duration] floatValue]);
        [self trackWithProperties:[tempProperties copy]];
    }];
}

- (void)trackPageEnter:(UIViewController *)viewController {
    if (![self shouldTrackViewController:viewController]) {
        return;
    }
    NSString *address = [NSString stringWithFormat:@"%p", viewController];
    if (self.timestamp[address]) {
        return;
    }
    NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
    properties[kZAPageLeaveTimestamp] = @([[NSDate date] timeIntervalSince1970]);
    properties[kZAPageLeaveAutoTrackProperties] = [self propertiesWithViewController:viewController];
    self.timestamp[address] = properties;
}

- (void)trackPageLeave:(UIViewController *)viewController {
    if (![self shouldTrackViewController:viewController] || self.isIgnored) {
        return;
    }
    NSString *address = [NSString stringWithFormat:@"%p", viewController];
    if (!self.timestamp[address]) {
        return;
    }
    NSTimeInterval currentTimestamp = [[NSDate date] timeIntervalSince1970];
    NSMutableDictionary *properties = self.timestamp[address];
    NSNumber *timestamp = properties[kZAPageLeaveTimestamp];
    NSTimeInterval startTimestamp = [timestamp doubleValue];
    NSMutableDictionary *tempProperties = [[NSMutableDictionary alloc] initWithDictionary:properties[kZAPageLeaveAutoTrackProperties]];
    NSTimeInterval duration = (currentTimestamp - startTimestamp) < 24 * 60 * 60 ? (currentTimestamp - startTimestamp) : 0;
    tempProperties[kZAEventDurationProperty] = @([[NSString stringWithFormat:@"%.3f", duration] floatValue]);
    [self trackWithProperties:tempProperties];
    self.timestamp[address] = nil;
}

- (void)trackWithProperties:(NSDictionary *)properties {
    ZAEventPresetTrackObject *object = [[ZAEventPresetTrackObject alloc] initWithEventId:kZAEventNameAppPageLeave];
    [ZallDataSDK.sharedInstance asyncTrackEventObject:object properties:properties];
 
    
}


- (NSDictionary *)propertiesWithViewController:(UIViewController<ZAAutoTrackViewControllerProperty> *)viewController {
    NSMutableDictionary *eventProperties = [[NSMutableDictionary alloc] init];
    NSDictionary *autoTrackProperties = [ZAAutoTrackProperty propertiesWithViewController:viewController];
    [eventProperties addEntriesFromDictionary:autoTrackProperties];

    NSString *currentURL;
    if ([viewController conformsToProtocol:@protocol(ZAScreenAutoTrackProperties)] && [viewController respondsToSelector:@selector(getScreenUrl)]) {
        UIViewController<ZAScreenAutoTrackProperties> *screenAutoTrackerController = (UIViewController<ZAScreenAutoTrackProperties> *)viewController;
        currentURL = [screenAutoTrackerController getScreenUrl];
    }
    currentURL = [currentURL isKindOfClass:NSString.class] ? currentURL : NSStringFromClass(viewController.class);

    // 添加 $url 和 $referrer 页面浏览相关属性
    NSDictionary *newProperties = [self propertiesWithURL:currentURL eventProperties:eventProperties];

    return newProperties;
}

- (NSDictionary *)propertiesWithURL:(NSString *)currentURL eventProperties:(NSDictionary *)eventProperties {
    NSString *referrerURL = self.referrerURL;
    NSMutableDictionary *newProperties = [NSMutableDictionary dictionaryWithDictionary:eventProperties];

    // 客户自定义属性中包含 $url 时，以客户自定义内容为准
    if (!newProperties[kZAEventPropertyScreenUrl]) {
        newProperties[kZAEventPropertyScreenUrl] = currentURL;
    }
    // 客户自定义属性中包含 $referrer 时，以客户自定义内容为准
    if (referrerURL && !newProperties[kZAEventPropertyScreenReferrerUrl]) {
        newProperties[kZAEventPropertyScreenReferrerUrl] = referrerURL;
    }
    // $referrer 内容以最终页面浏览事件中的 $url 为准
    self.referrerURL = newProperties[kZAEventPropertyScreenUrl];
    self.referrerProperties = newProperties;

    return newProperties;
}

- (BOOL)shouldTrackViewController:(UIViewController *)viewController {
    NSDictionary *autoTrackBlackList = [self autoTrackViewControllerBlackList];
    NSDictionary *appViewScreenBlackList = autoTrackBlackList[kZAEventNameAppViewScreen];
    if ([self isViewController:viewController inBlackList:appViewScreenBlackList]) {
        return NO;
    }
    
    if (ZAConfigOptions.sharedInstance.autoTrackEventType & ZAAutoTrackEventTypeAppViewScreen && (
        !viewController.parentViewController ||
        [viewController.parentViewController isKindOfClass:[UITabBarController class]] ||
        [viewController.parentViewController isKindOfClass:[UINavigationController class]] ||
        [viewController.parentViewController isKindOfClass:[UIPageViewController class]] ||
        [viewController.parentViewController isKindOfClass:[UISplitViewController class]])) {
        return YES;
    }
    return NO;
}

- (NSMutableDictionary<NSString *,NSMutableDictionary *> *)timestamp {
    if (!_timestamp) {
        _timestamp = [[NSMutableDictionary alloc] init];
    }
    return _timestamp;
}

@end
