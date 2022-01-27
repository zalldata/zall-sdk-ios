//
// ZAVisualizedManager.m
// ZallDataSDK
//
// Created by guo on 2020/12/25.
// Copyright © 2020 Zall Data Co., Ltd. All rights reserved.
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

#import "ZAVisualizedManager.h"
#import "ZAVisualizedConnection.h"
#import "ZAAlertViewController.h"
#import "UIViewController+ZAElementPath.h"
#import "ZallDataSDK+ZAVisualized.h"
#import "ZAVisualizedUtils.h"
#import "ZAModuleManager.h"
#import "ZAJavaScriptBridgeManager.h"
#import "ZAReachability.h"
#import "ZAURLUtils.h"
#import "ZASwizzle.h"
#import "ZallDataSDK+ZAPrivate.h"
#import "UIView+AutoTrackProperty.h"

@interface ZAVisualizedManager()<ZAConfigChangesDelegate>

@property (nonatomic, strong) ZAVisualizedConnection *visualizedConnection;

/// 当前类型
@property (nonatomic, assign) ZallAnalyticsVisualizedType visualizedType;

/// 指定开启可视化的 viewControllers 名称
@property (nonatomic, strong) NSMutableSet<NSString *> *visualizedViewControllers;

/// 自定义属性采集
@property (nonatomic, strong) ZAVisualPropertiesTracker *visualPropertiesTracker;

/// 获取远程配置
@property (nonatomic, strong, readwrite) ZAVisualPropertiesConfigSources *configSources;

/// 埋点校验
@property (nonatomic, strong, readwrite) ZAVisualizedEventCheck *eventCheck;

@end

@ZAAppLoadModule(ZAVisualizedManager)
@implementation ZAVisualizedManager

+ (instancetype)defaultManager {
    static dispatch_once_t onceToken;
    static ZAVisualizedManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[ZAVisualizedManager alloc] init];
    });
    return manager;
}

#pragma mark initialize
- (instancetype)init {
    self = [super init];
    if (self) {
        _visualizedViewControllers = [[NSMutableSet alloc] init];
    }
    return self;
}

#pragma mark ZAConfigChangesDelegate
- (void)configChangedWithValid:(BOOL)valid {
    if (valid){
        if (!self.visualPropertiesTracker) {
            // 配置可用，开启自定义属性采集
            self.visualPropertiesTracker = [[ZAVisualPropertiesTracker alloc] initWithConfigSources:self.configSources];
        }

        // 可能扫码阶段，可能尚未请求到配置，此处再次尝试开启埋点校验
        if (!self.eventCheck && self.visualizedType == ZallAnalyticsVisualizedTypeAutoTrack) {
            self.eventCheck = [[ZAVisualizedEventCheck alloc] initWithConfigSources:self.configSources];
        }

        // 配置更新，发送到 WKWebView 的内嵌 H5
        [self.visualPropertiesTracker.viewNodeTree updateConfig:self.configSources.originalResponse];
    } else {
        self.visualPropertiesTracker = nil;
        self.eventCheck = nil;
    }
}

#pragma mark -
- (void)setEnable:(BOOL)enable {
    _enable = enable;

    if (!enable) {
        self.configSources = nil;
        self.visualPropertiesTracker = nil;
        [self.visualizedConnection close];
        return;
    }

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSError *error = nil;
        [UIViewController za_swizzleMethod:@selector(viewDidAppear:) withMethod:@selector(zalldata_visualize_viewDidAppear:) error:&error];
        if (error) {
            ZALogError(@"Failed to swizzle on UIViewController. Details: %@", error);
        }
    });

    // 未开启自定义属性
    if (!self.configOptions.enableVisualizedProperties) {
        ZALogDebug(@"Current App does not support visualizedProperties");
        return;
    }

    if (!self.configSources) {
        // 获取自定义属性配置
        self.configSources = [[ZAVisualPropertiesConfigSources alloc] initWithDelegate:self];
        [self.configSources loadConfig];
    }
}

- (void)setConfigOptions:(ZAConfigOptions *)configOptions {
    _configOptions = configOptions;

    // 由于自定义属性依赖于可视化全埋点，所以只要开启自定义属性，默认打开可视化全埋点相关功能
    // 可视化全埋点或点击分析开启
    self.enable = configOptions.enableHeatMap || configOptions.enableVisualizedAutoTrack || configOptions.enableVisualizedProperties;
}

-(void)updateServerURL:(NSString *)serverURL {
    if (za_check_empty_string(serverURL)) {
        return;
    }
    // 刷新自定义属性配置
    [self.configSources reloadConfig];
}

#pragma mark -
- (NSString *)javaScriptSource {
    if (!self.enable) {
        return nil;
    }
    // App 内嵌 H5 数据交互
    NSMutableString *javaScriptSource = [NSMutableString string];
    if (self.visualizedConnection.isVisualizedConnecting) {
        NSString *jsVisualizedMode = [ZAJavaScriptBridgeBuilder buildVisualBridgeWithVisualizedMode:YES];
        [javaScriptSource appendString:jsVisualizedMode];
    }

    if (!self.configOptions.enableVisualizedProperties || !self.configSources.isValid || self.configSources.originalResponse.count == 0) {
        return javaScriptSource;
    }

    // 注入完整配置信息
    NSString *webVisualConfig = [ZAJavaScriptBridgeBuilder buildVisualPropertyBridgeWithVisualConfig:self.configSources.originalResponse];
    if (!webVisualConfig) {
        return javaScriptSource;
    }
    [javaScriptSource appendString:webVisualConfig];
    return javaScriptSource;
}

#pragma mark - handle URL
- (BOOL)canHandleURL:(NSURL *)url {
    return [self isHeatMapURL:url] || [self isVisualizedAutoTrackURL:url];
}

// 待优化，拆分可视化和点击分析
- (BOOL)isHeatMapURL:(NSURL *)url {
    return [url.host isEqualToString:@"heatmap"];
}

- (BOOL)isVisualizedAutoTrackURL:(NSURL *)url {
    return [url.host isEqualToString:@"visualized"];
}

- (BOOL)handleURL:(NSURL *)url {
    if (![self canHandleURL:url]) {
        return NO;
    }

    NSDictionary *queryItems = [ZAURLUtils decodeRueryItemsWithURL:url];
    NSString *featureCode = queryItems[@"feature_code"];
    NSString *postURLStr = queryItems[@"url"];

    // project 和 host 不同
    NSString *project = [ZAURLUtils queryItemsWithURLString:postURLStr][@"project"] ?: @"default";
    BOOL isEqualProject = [[ZallDataSDK sharedInstance].network.project isEqualToString:project];
    if (!isEqualProject) {
        if ([self isHeatMapURL:url]) {
            [ZAVisualizedManager showAlterViewWithTitle:@"提示" message:@"App 集成的项目与电脑浏览器打开的项目不同，无法进行点击分析"];
        } else if([self isVisualizedAutoTrackURL:url]){
            [ZAVisualizedManager showAlterViewWithTitle:@"提示" message:@"App 集成的项目与电脑浏览器打开的项目不同，无法进行可视化全埋点"];
        }
        return YES;
    }

    // 未开启点击图
    if ([url.host isEqualToString:@"heatmap"] && ![[ZallDataSDK sharedInstance] isHeatMapEnabled]) {
        [ZAVisualizedManager showAlterViewWithTitle:@"提示" message:@"SDK 没有被正确集成，请联系贵方技术人员开启点击分析"];
        return YES;
    }

    // 未开启可视化全埋点
    if ([url.host isEqualToString:@"visualized"] && ![[ZallDataSDK sharedInstance] isVisualizedAutoTrackEnabled]) {
        [ZAVisualizedManager showAlterViewWithTitle:@"提示" message:@"SDK 没有被正确集成，请联系贵方技术人员开启可视化全埋点"];
        return YES;
    }
    if (featureCode && postURLStr && self.isEnable) {
        [ZAVisualizedManager.defaultManager showOpenAlertWithURL:url featureCode:featureCode postURL:postURLStr];
        return YES;
    }
    //feature_code url 参数错误
    [ZAVisualizedManager showAlterViewWithTitle:@"ERROR" message:@"参数错误"];
    return NO;
}

+ (void)showAlterViewWithTitle:(NSString *)title message:(NSString *)message {
    ZAAlertViewController *alertController = [[ZAAlertViewController alloc] initWithTitle:title message:message preferredStyle:ZAAlertControllerStyleAlert];
    [alertController addActionWithTitle:@"确认" style:ZAAlertActionStyleDefault handler:nil];
    [alertController show];
}

- (void)showOpenAlertWithURL:(NSURL *)URL featureCode:(NSString *)featureCode postURL:(NSString *)postURL {
    NSString *alertTitle = @"提示";
    NSString *alertMessage = [self alertMessageWithURL:URL];

    ZAAlertViewController *alertController = [[ZAAlertViewController alloc] initWithTitle:alertTitle message:alertMessage preferredStyle:ZAAlertControllerStyleAlert];

    [alertController addActionWithTitle:@"取消" style:ZAAlertActionStyleCancel handler:^(ZAAlertAction *_Nonnull action) {
        [self.visualizedConnection close];
        self.visualizedConnection = nil;
    }];

    [alertController addActionWithTitle:@"继续" style:ZAAlertActionStyleDefault handler:^(ZAAlertAction *_Nonnull action) {
        // 关闭之前的连接
        [self.visualizedConnection close];
        // start
        self.visualizedConnection = [[ZAVisualizedConnection alloc] init];
        if ([self isHeatMapURL:URL]) {
            ZALogDebug(@"Confirmed to open HeatMap ...");
            self.visualizedType = ZallAnalyticsVisualizedTypeHeatMap;
        } else if ([self isVisualizedAutoTrackURL:URL]) {
            ZALogDebug(@"Confirmed to open VisualizedAutoTrack ...");
            self.visualizedType = ZallAnalyticsVisualizedTypeAutoTrack;

            // 开启埋点校验
            [self enableEventCheck:YES];
        }
        [self.visualizedConnection startConnectionWithFeatureCode:featureCode url:postURL];
    }];

    [alertController show];
}

- (NSString *)alertMessageWithURL:(NSURL *)URL{
    NSString *alertMessage = nil;
    if ([self isHeatMapURL:URL]) {
        alertMessage = @"正在连接 App 点击分析";
    } else {
        alertMessage = @"正在连接 App 可视化全埋点";
    }

    if (![ZAReachability sharedInstance].isReachableViaWiFi) {
        alertMessage = [alertMessage stringByAppendingString: @"，建议在 WiFi 环境下使用"];
    }
    return alertMessage;
}

/// 当前类型
- (ZallAnalyticsVisualizedType)currentVisualizedType {
    return self.visualizedType;
}

#pragma mark - Visualize

- (void)addVisualizeWithViewControllers:(NSArray<NSString *> *)controllers {
    if (![controllers isKindOfClass:[NSArray class]] || controllers.count == 0) {
        return;
    }
    [self.visualizedViewControllers addObjectsFromArray:controllers];
}

- (BOOL)isVisualizeWithViewController:(UIViewController *)viewController {
    if (!viewController) {
        return YES;
    }

    if (self.visualizedViewControllers.count == 0) {
        return YES;
    }

    NSString *screenName = NSStringFromClass([viewController class]);
    return [self.visualizedViewControllers containsObject:screenName];
}

#pragma mark - Property
- (nullable NSDictionary *)propertiesWithView:(UIView *)view {
    if (![view isKindOfClass:UIView.class]) {
        return nil;
    }
    UIViewController<ZAAutoTrackViewControllerProperty> *viewController = view.za_property_viewController;
    if (!viewController) {
        return nil;
    }

    NSString *screenName = NSStringFromClass([viewController class]);
    if (self.visualizedViewControllers.count > 0 && ![self.visualizedViewControllers containsObject:screenName]) {
        return nil;
    }

    // 1 获取 viewPath 相关属性
    NSString *elementSelector = [ZAVisualizedUtils viewPathForView:view atViewController:viewController];

    NSString *elementPath = [ZAVisualizedUtils viewSimilarPathForView:view atViewController:viewController shouldSimilarPath:YES];
    
    NSMutableDictionary *viewPthProperties = [NSMutableDictionary dictionary];
    viewPthProperties[kZAEventPropertyElementSelector] = elementSelector;
    viewPthProperties[kZAEventPropertyElementPath] = elementPath;

    return viewPthProperties.count > 0 ? viewPthProperties : nil;
}

- (void)visualPropertiesWithView:(UIView *)view completionHandler:(void (^)(NSDictionary * _Nullable))completionHandler {
    if (![view isKindOfClass:UIView.class] || !self.visualPropertiesTracker) {
        return completionHandler(nil);
    }

    @try {
        [self.visualPropertiesTracker visualPropertiesWithView:view completionHandler:completionHandler];
    } @catch (NSException *exception) {
        ZALogError(@"visualPropertiesWithView error: %@", exception);
        completionHandler(nil);
    }
}

- (void)queryVisualPropertiesWithConfigs:(NSArray<NSDictionary *> *)propertyConfigs completionHandler:(void (^)(NSDictionary * _Nullable))completionHandler {
    if (propertyConfigs.count == 0 || !self.visualPropertiesTracker) {
        return completionHandler(nil);
    }
    
    @try {
        [self.visualPropertiesTracker queryVisualPropertiesWithConfigs:propertyConfigs completionHandler:completionHandler];
    } @catch (NSException *exception) {
        ZALogError(@"visualPropertiesWithView error: %@", exception);
        completionHandler(nil);
    }
}

#pragma mark - eventCheck
/// 是否开启埋点校验
- (void)enableEventCheck:(BOOL)enable {
    if (!enable) {
        self.eventCheck = nil;
        return;
    }

    // 配置可用才需开启埋点校验
    if (!self.eventCheck && self.configSources.isValid) {
        self.eventCheck = [[ZAVisualizedEventCheck alloc] initWithConfigSources:self.configSources];
    }
}

- (void)dealloc {
    // 断开连接，防止 visualizedConnection 内 timer 导致无法释放
    [self.visualizedConnection close];
}

@end
