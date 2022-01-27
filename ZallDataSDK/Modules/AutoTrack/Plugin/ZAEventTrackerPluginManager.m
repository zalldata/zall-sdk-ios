//
// ZAEventTrackerPluginManager.m
// ZallDataSDK
//
// Created by guo on 2021/11/8.
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

#import "ZAEventTrackerPluginManager.h"
#import "ZAUtilCheck.h"

@interface ZAEventTrackerPluginManager ()

@property (nonatomic, strong) NSMutableArray<ZAEventTrackerPlugin<ZAEventTrackerPluginProtocol> *> *plugins;

@end

@implementation ZAEventTrackerPluginManager

+ (instancetype)defaultManager {
    static dispatch_once_t onceToken;
    static ZAEventTrackerPluginManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[ZAEventTrackerPluginManager alloc] init];
    });
    return manager;
}

- (void)registerPlugin:(ZAEventTrackerPlugin<ZAEventTrackerPluginProtocol> *)plugin {
    //object basic check, nil、class and protocol
    if (![ZAUtilCheck zaCheckWithTarget:plugin withProtocols:@[@protocol(ZAEventTrackerPluginProtocol)] withClass:@[ZAEventTrackerPlugin.class] withSelector:@selector(install),@selector(uninstall),nil]) {
        return;
    }
    
    
    //duplicate check
    if ([self.plugins containsObject:plugin]) {
        return;
    }

    //same type plugin check
    [self.plugins enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(ZAEventTrackerPlugin<ZAEventTrackerPluginProtocol> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.type isEqualToString:plugin.type]) {
            [plugin uninstall];
            [self.plugins removeObject:obj];
            *stop = YES;
        }
    }];

    [self.plugins addObject:plugin];
    [plugin install];
}

- (void)unregisterPlugin:(Class)pluginClass {
    [self.plugins enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(ZAEventTrackerPlugin<ZAEventTrackerPluginProtocol> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:pluginClass] && [obj respondsToSelector:@selector(uninstall)]) {
            [obj uninstall];
            [self.plugins removeObject:obj];
            *stop = YES;
        }
    }];
}

- (void)unregisterAllPlugins {
    [self.plugins enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(ZAEventTrackerPlugin<ZAEventTrackerPluginProtocol> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(uninstall)]) {
            [obj uninstall];
            [self.plugins removeObject:obj];
        }
    }];
}

- (void)enableAllPlugins {
    for (ZAEventTrackerPlugin<ZAEventTrackerPluginProtocol> *plugin in self.plugins) {
        plugin.enable = YES;
    }
}

- (void)disableAllPlugins {
    for (ZAEventTrackerPlugin<ZAEventTrackerPluginProtocol> *plugin in self.plugins) {
        plugin.enable = NO;
    }
}

- (ZAEventTrackerPlugin<ZAEventTrackerPluginProtocol> *)pluginWithType:(NSString *)pluginType {
    for (ZAEventTrackerPlugin<ZAEventTrackerPluginProtocol> *plugin in self.plugins) {
        if ([plugin.type isEqualToString:pluginType]) {
            return plugin;
        }
    }
    return nil;
}

- (NSMutableArray<ZAEventTrackerPlugin<ZAEventTrackerPluginProtocol> *> *)plugins {
    if (!_plugins) {
        _plugins = [[NSMutableArray alloc] init];
    }
    return _plugins;
}

@end
