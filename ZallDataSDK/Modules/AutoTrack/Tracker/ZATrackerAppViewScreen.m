//
// ZAAppViewScreenTracker.m
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

#import "ZATrackerAppViewScreen.h"
#import "ZAConstantsDefin.h"
#import "ZAReferrerManager.h"
#import "ZAAutoTrackProperty.h"
#import "ZAModuleManager.h"
#import "ZAUtilCheck.h"

@interface ZATrackerAppViewScreen ()

@property (nonatomic, strong) NSMutableArray<UIViewController *> *launchedPassivelyControllers;

@end

@implementation ZATrackerAppViewScreen

- (instancetype)init {
    self = [super init];
    if (self) {
        _launchedPassivelyControllers = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Override

- (NSString *)eventId {
    return kZAEventNameAppViewScreen;
}

- (BOOL)shouldTrackViewController:(UIViewController *)viewController {
    if ([self isViewControllerIgnored:viewController]) {
        return NO;
    }

    return ![self isBlackListContainsViewController:viewController];
}

#pragma mark - Public Methods

- (void)autoTrackEventWithViewController:(UIViewController *)viewController {
    if (!viewController) {
        return;
    }
    
    if (self.isIgnored) {
        return;
    }
    
    //过滤用户设置的不被AutoTrack的Controllers
    if (![self shouldTrackViewController:viewController]) {
        return;
    }

    if (self.isPassively) {
        [self.launchedPassivelyControllers addObject:viewController];
        return;
    }
    
    NSDictionary *eventProperties = [self buildWithViewController:viewController properties:nil autoTrack:YES];
    [self trackAutoTrackEventWithProperties:eventProperties];
}

- (void)trackEventWithViewController:(UIViewController *)viewController properties:(NSDictionary<NSString *, id> *)properties {
    if (!viewController) {
        return;
    }

    if ([self isBlackListContainsViewController:viewController]) {
        return;
    }

    NSDictionary *eventProperties = [self buildWithViewController:viewController properties:properties autoTrack:NO];
    [self trackPresetEventWithProperties:eventProperties];
}

- (void)trackEventWithURL:(NSString *)url properties:(NSDictionary<NSString *,id> *)properties {
    NSDictionary *eventProperties = [[ZAReferrerManager sharedInstance] propertiesWithURL:url eventProperties:properties];
    [self trackPresetEventWithProperties:eventProperties];
}

- (void)trackEventOfLaunchedPassively {
    if (self.launchedPassivelyControllers.count == 0) {
        return;
    }

    if (self.isIgnored) {
        return;
    }

    for (UIViewController *vc in self.launchedPassivelyControllers) {
        if ([self shouldTrackViewController:vc]) {
            NSDictionary *eventProperties = [self buildWithViewController:vc properties:nil autoTrack:YES];
            [self trackAutoTrackEventWithProperties:eventProperties];
        }
    }
    [self.launchedPassivelyControllers removeAllObjects];
}

#pragma mark – Private Methods

- (BOOL)isBlackListContainsViewController:(UIViewController *)viewController {
    NSDictionary *autoTrackBlackList = [self autoTrackViewControllerBlackList];
    NSDictionary *appViewScreenBlackList = autoTrackBlackList[kZAEventNameAppViewScreen];
    return [self isViewController:viewController inBlackList:appViewScreenBlackList];
}

- (NSDictionary *)buildWithViewController:(UIViewController *)viewController properties:(NSDictionary<NSString *, id> *)properties autoTrack:(BOOL)autoTrack {
    NSMutableDictionary *eventProperties = [[NSMutableDictionary alloc] init];
 
    NSDictionary *autoTrackProperties = [ZAAutoTrackProperty propertiesWithViewController:(UIViewController<ZAAutoTrackViewControllerProperty>*)viewController];
    [eventProperties addEntriesFromDictionary:autoTrackProperties];

    if (autoTrack) {
        // App 通过 Deeplink 启动时第一个页面浏览事件会添加 utms 属性
        // 只需要处理全埋点的页面浏览事件
        [eventProperties addEntriesFromDictionary:ZAModuleManager.sharedInstance.utmProperties];
        [ZAModuleManager.sharedInstance clearUtmProperties];
    }

    if (!za_check_empty_dict(properties)) {
        [eventProperties addEntriesFromDictionary:properties];
    }

    NSString *currentURL;
    if ([viewController conformsToProtocol:@protocol(ZAScreenAutoTrackProperties)] && [viewController respondsToSelector:@selector(getScreenUrl)]) {
        
        UIViewController<ZAScreenAutoTrackProperties> *screenAutoTrackerController = (UIViewController<ZAScreenAutoTrackProperties> *)viewController;
        currentURL = [screenAutoTrackerController getScreenUrl];
    }
    currentURL = [currentURL isKindOfClass:NSString.class] ? currentURL : NSStringFromClass(viewController.class);

    // 添加 $url 和 $referrer 页面浏览相关属性
    NSDictionary *newProperties = [ZAReferrerManager.sharedInstance propertiesWithURL:currentURL eventProperties:eventProperties];

    return newProperties;
}

@end
