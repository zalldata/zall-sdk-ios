//
// ZASuperProperty.m
// ZallDataSDK
//
// Created by guo on 2021/4/10.
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

#import "ZASuperProperty.h"
#import "ZAFileStore.h"
#import "ZAModuleManager.h"
#import "ZALog.h"
#import "ZAQuickUtil.h"
#import "ZAUtilCheck.h"


static NSString *const kZASavedSuperPropertiesFileName = @"super_properties";

@interface ZASuperProperty ()

@property(nonatomic, assign) dispatch_queue_t queue_t;
/// 静态公共属性
@property (atomic, strong) NSDictionary *superProperties;

/// 动态公共属性
@property (nonatomic, copy) NSDictionary<NSString *, id> *(^dynamicSuperProperties)(void);

@end

@implementation ZASuperProperty

- (instancetype)init {
    self = [super init];
    if (self) {
        _queue_t = za_quick_queue_serial_create(NSStringFromClass(self.class));
        [self unarchiveSuperProperties];
    }
    return self;
}

- (void)registerSuperProperties:(NSDictionary *)propertyDict {
    NSDictionary *validProperty = [ZAUtilCheck zaCheckProperties:propertyDict];
    [self unregisterSameLetterSuperProperties:validProperty];
    // 注意这里的顺序，发生冲突时是以 propertyDict 为准，所以它是后加入的
    NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:self.superProperties];
    [tmp addEntriesFromDictionary:validProperty];
    self.superProperties = [NSDictionary dictionaryWithDictionary:tmp];
    [self archiveSuperProperties];
}

- (void)unregisterSuperProperty:(NSString *)property {
    if (!property) {
        return;
    }
    NSMutableDictionary *superProperties = [NSMutableDictionary dictionaryWithDictionary:self.superProperties];
    [superProperties removeObjectForKey:property];
    self.superProperties = [NSDictionary dictionaryWithDictionary:superProperties];
    [self archiveSuperProperties];
}

- (NSDictionary *)currentSuperProperties {
    return [self.superProperties copy];
}

- (void)clearSuperProperties {
    self.superProperties = @{};
    [self archiveSuperProperties];
}

/// 注销仅大小写不同的 SuperProperties
/// @param propertyDict 公共属性
- (void)unregisterSameLetterSuperProperties:(NSDictionary *)propertyDict {
    NSArray *allNewKeys = [propertyDict.allKeys copy];
    //如果包含仅大小写不同的 key ,unregisterSuperProperty
    NSArray *superPropertyAllKeys = [self.superProperties.allKeys copy];
    NSMutableArray *unregisterPropertyKeys = [NSMutableArray array];
    for (NSString *newKey in allNewKeys) {
        [superPropertyAllKeys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *usedKey = (NSString *)obj;
            if ([usedKey caseInsensitiveCompare:newKey] == NSOrderedSame) { // 存在不区分大小写相同 key
                [unregisterPropertyKeys addObject:usedKey];
            }
        }];
    }
    if (unregisterPropertyKeys.count > 0) {
        NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:self.superProperties];
        [tmp removeObjectsForKeys:unregisterPropertyKeys];
        self.superProperties = [NSDictionary dictionaryWithDictionary:tmp];
    }
}

- (void)registerDynamicSuperProperties:(NSDictionary<NSString *, id> *(^)(void)) dynamicSuperProperties {
    self.dynamicSuperProperties = dynamicSuperProperties;
    
}

- (NSDictionary *)acquireDynamicSuperProperties {
    if (self.dynamicSuperProperties) {
        NSDictionary *dynamicProperties = self.dynamicSuperProperties();
        NSDictionary *validProperties = [ZAUtilCheck zaCheckProperties:dynamicProperties];
        [self unregisterSameLetterSuperProperties:validProperties];
        return validProperties;
    }
    
    return nil;
    
}

#pragma mark - 缓存

- (void)unarchiveSuperProperties {
    NSDictionary *archivedSuperProperties = (NSDictionary *)[ZAFileStore unarchiveWithFileName:kZASavedSuperPropertiesFileName];
    _superProperties = archivedSuperProperties ? [archivedSuperProperties copy] : [NSDictionary dictionary];
}

- (void)archiveSuperProperties {
    [ZAFileStore archiveWithFileName:kZASavedSuperPropertiesFileName value:self.superProperties];
}

@end
