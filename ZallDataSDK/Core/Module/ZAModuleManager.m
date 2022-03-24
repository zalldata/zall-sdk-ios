//
// ZAModuleManager.m
// ZallDataSDK
//
// Created by guo on 2021/12/30.
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

#import "ZAModuleManager.h"
#import "ZAQuickUtil.h"
#import "ZALog.h"
#import "ZAConfigOptions.h"
#import "ZAUtilCheck.h"
#import <objc/runtime.h>
@interface ZAModuleManager ()

@property (nonatomic, strong) NSDictionary *mapModules;

@end

@implementation ZAModuleManager


+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static ZAModuleManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[ZAModuleManager alloc] init];
    });
    return manager;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.mapModules = [ZAQuickUtil zaGetModulesClassWithProtocols];
    }
    return self;
}

// module加载
-(void)loadModules{
    if (ZAConfigOptions.sharedInstance.disableSDK) {
        return;
    }
    NSArray * array = [self.mapModules objectForKey:NSStringFromProtocol(@protocol(ZAModuleProtocol))];
    [array makeObjectsPerformSelector:@selector(setConfigOptions:) withObject:ZAConfigOptions.sharedInstance];
//#ifdef DEBUG
//    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        ZALogDebug(@"loadModules -> %@",obj);
//    }];
//
//#endif
  
}

- (void)disableAllModules {
   
    [[self.mapModules objectForKey:NSStringFromProtocol(@protocol(ZAModuleProtocol))] makeObjectsPerformSelector:@selector(setEnable:) withObject:@(NO)];
    
}

#pragma mark - ZAModuleFactory
-(id<ZAModuleProtocol>)getManagerWithProtocol:(Protocol *)protocol{
    return [self getManagerWithProtocol:protocol withOnce:YES];
}
-(id<ZAModuleProtocol>)getManagerWithProtocol:(Protocol *)protocol withOnce:(BOOL)isOnce{
    
    id module = [self.mapModules objectForKey:NSStringFromProtocol(protocol)];
    NSMutableArray <ZAModuleProtocol>* array = @[].mutableCopy;
    [module enumerateObjectsUsingBlock:^(id<ZAModuleProtocol> obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id object = obj.isEnable?obj:nil;
        if (object) {
            [array addObject:object];
            *stop = !za_check_empty_array(array) && isOnce;
        }
    }];
    if (isOnce && !za_check_empty_array(array)) {
        return array.firstObject;
    }
    return za_check_empty_array(array) ?nil:array;
}

-(void)getModulesWith:(Protocol *)protocol withInstance:(NSArray *)methods withSuccsss:(BOOL (^)(id  module))blockModule{
    id module = [self getManagerWithProtocol:protocol withOnce:NO];
    if ([module isKindOfClass:NSArray.class]) {
        [module enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([ZAQuickUtil zaGetIsProtocolWithObject:obj withMethods:methods]) {
                *stop=blockModule(obj);
            }
        }];
    }else if (module){
        if ([ZAQuickUtil zaGetIsProtocolWithObject:module withMethods:methods]) {
            blockModule(module);
        }
    }
}
 

#pragma mark - ZAModulePropertyProtocol
- (NSDictionary *)properties {
    __block NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    [self getModulesWith:@protocol(ZAModulePropertyProtocol) withInstance:@[NSStringFromSelector(_cmd)] withSuccsss:^BOOL(id <ZAModulePropertyProtocol> module) {
        if (module.properties.count > 0) {
            [properties addEntriesFromDictionary:module.properties];
        }
        return NO;
    }];
    return properties;
}
#pragma mark - ZAModuleOpenURLProtocol
- (BOOL)canHandleURL:(NSURL *)url {
    __block BOOL isCan = NO;
    
    [self getModulesWith:@protocol(ZAModuleOpenURLProtocol) withInstance:@[NSStringFromSelector(_cmd)] withSuccsss:^BOOL(id <ZAModuleOpenURLProtocol>module) {
        if ([module canHandleURL:url]) {
            return isCan = YES;
        }
        return NO;
    }];
    return isCan;
}

- (BOOL)handleURL:(NSURL *)url {
    __block BOOL isCan = NO;
    [self getModulesWith:@protocol(ZAModuleOpenURLProtocol) withInstance:@[NSStringFromSelector(_cmd),NSStringFromSelector(@selector(canHandleURL:))] withSuccsss:^BOOL(id<ZAModuleOpenURLProtocol> module) {
        if ([module canHandleURL:url]) {
            isCan = [module handleURL:url];
            return YES;
        }
        return NO;
    }];
    return isCan;
}

#pragma mark - ZAModuleChannelMatchProtocol
- (NSDictionary *)channelInfoWithEvent:(NSString *)event{
    __block NSMutableDictionary * channelInfo = @{}.mutableCopy;
    [self getModulesWith:@protocol(ZAModuleChannelMatchProtocol) withInstance:@[NSStringFromSelector(_cmd)] withSuccsss:^BOOL(id module) {
        NSDictionary * dict =[module channelInfoWithEvent:event];
        if (!za_check_empty_dict(dict)) {
            [channelInfo addEntriesFromDictionary:dict];
        }
        return NO;
    }];
    
    return channelInfo;
}

#pragma mark - ZAModuleDebugModeProtocol
- (id<ZAModuleDebugModeProtocol>)debugModeManager {
    return (id<ZAModuleDebugModeProtocol>)[self getManagerWithProtocol:@protocol(ZAModuleDebugModeProtocol)];
   
}
-(void)setDebugMode:(ZADebugModeType)debugMode{
    self.debugModeManager.debugMode = debugMode;
}

- (ZADebugModeType)debugMode {
    return self.debugModeManager.debugMode;
}

-(BOOL)isDebugMode{
    return self.debugMode != ZADebugModeTypeOff;
}


- (void)setShowDebugAlertView:(BOOL)isShow {
    [self.debugModeManager setShowDebugAlertView:isShow];
}

- (void)handleDebugMode:(ZADebugModeType)mode {
    [self.debugModeManager handleDebugMode:mode];
}

- (void)showDebugModeWarning:(NSString *)message {
    [self.debugModeManager showDebugModeWarning:message];
}


#pragma mark - ZAModuleEncryptProtocol
- (id<ZAModuleEncryptProtocol>)encryptManager {
   
    return (id<ZAModuleEncryptProtocol>)[self getManagerWithProtocol:@protocol(ZAModuleEncryptProtocol)];;
}

- (BOOL)hasSecretKey {
    return self.encryptManager.hasSecretKey;
}

- (nullable NSDictionary *)encryptJSONObject:(nonnull id)obj {
    return [self.encryptManager encryptJSONObject:obj];
}

- (void)handleEncryptWithConfig:(nonnull NSDictionary *)encryptConfig {
    [self.encryptManager handleEncryptWithConfig:encryptConfig];
}


#pragma mark - ZAModuleAutoTrackProtocol
- (id<ZAModuleAutoTrackProtocol>)autoTrackManager {
   
    return (id<ZAModuleAutoTrackProtocol>)[self getManagerWithProtocol:@protocol(ZAModuleAutoTrackProtocol)];;
}

- (void)trackAppEndWhenCrashed {
    [self.autoTrackManager trackAppEndWhenCrashed];
}

- (void)trackPageLeaveWhenCrashed {
    [self.autoTrackManager trackPageLeaveWhenCrashed];
}

#pragma mark - ZAModuleJavaScriptBridgeProtocol
- (NSString *)javaScriptSource {
    __block NSMutableString *source = [NSMutableString string];
    [self getModulesWith:@protocol(ZAModuleJavaScriptBridgeProtocol) withInstance:@[NSStringFromSelector(_cmd)] withSuccsss:^BOOL(id module) {
        id<ZAModuleJavaScriptBridgeProtocol, ZAModuleProtocol>moduleObject = module;
        NSString *javaScriptSource = [moduleObject javaScriptSource];
        javaScriptSource.length > 0 ? [source appendString:javaScriptSource] : nil;
        return NO;
    }];
    
    
    return source;
}

#pragma mark - ZAModuleRemoteConfigProtocol
- (id<ZAModuleRemoteConfigProtocol>)remoteConfigManager {
    return (id<ZAModuleRemoteConfigProtocol>)[self getManagerWithProtocol:@protocol(ZAModuleRemoteConfigProtocol)];
}

- (void)retryRequestRemoteConfigWithForceUpdateFlag:(BOOL)isForceUpdate {
    [self.remoteConfigManager retryRequestRemoteConfigWithForceUpdateFlag:isForceUpdate];
}

- (BOOL)isIgnoreEventObject:(ZAEventBaseObject *)obj {
    return [self.remoteConfigManager isIgnoreEventObject:obj];
}

- (BOOL)isDisableSDK {
    return [self.remoteConfigManager isDisableSDK];
}



#pragma mark - ZAModuleVisualizedProtocol
- (id<ZAModuleVisualizedProtocol>)visualizedManager {
    return (id<ZAModuleVisualizedProtocol>)[self getManagerWithProtocol:@protocol(ZAModuleVisualizedProtocol)];
}

#pragma mark properties
// 采集元素属性
- (nullable NSDictionary *)propertiesWithView:(id)view {
    return [self.visualizedManager propertiesWithView:view];
}

#pragma mark visualProperties
// 采集元素自定义属性
- (void)visualPropertiesWithView:(id)view completionHandler:(void (^)(NSDictionary *_Nullable))completionHandler {
    id<ZAModuleVisualizedProtocol> manager = self.visualizedManager;
    if (!manager) {
        return completionHandler(nil);
    }
    [self.visualizedManager visualPropertiesWithView:view completionHandler:completionHandler];
}

// 根据属性配置，采集 App 属性值
- (void)queryVisualPropertiesWithConfigs:(NSArray <NSDictionary *>*)propertyConfigs completionHandler:(void (^)(NSDictionary *_Nullable properties))completionHandler {
    id<ZAModuleVisualizedProtocol> manager = self.visualizedManager;
    if (!manager) {
        return completionHandler(nil);
    }
    [manager queryVisualPropertiesWithConfigs:propertyConfigs completionHandler:completionHandler];
}

#pragma mark - ZAModuleDeeplinkProtocol
- (id<ZAModuleDeeplinkProtocol>)deeplinkManager {
    return (id<ZAModuleDeeplinkProtocol>)[self getManagerWithProtocol:@protocol(ZAModuleDeeplinkProtocol)];
}

- (void)setLinkHandlerCallback:(void (^ _Nonnull)(NSString * _Nullable, BOOL, NSInteger))linkHandlerCallback {
    [self.deeplinkManager setLinkHandlerCallback:linkHandlerCallback];
}

- (NSDictionary *)latestUtmProperties {
    return self.deeplinkManager.latestUtmProperties;
}

- (NSDictionary *)utmProperties {
    return self.deeplinkManager.utmProperties;
}

- (void)clearUtmProperties {
    [self.deeplinkManager clearUtmProperties];
}

- (void)trackDeepLinkLaunchWithURL:(NSString *)url {
    [self.deeplinkManager trackDeepLinkLaunchWithURL:url];
}


@end
