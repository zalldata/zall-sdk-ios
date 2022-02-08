//
// ZAPresetProperty.h
// ZallDataSDK
//
// Created by guo on 2020/5/12.
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN



#pragma mark -
@interface ZAPresetProperty : NSObject

@property (nonatomic, strong, readonly) NSMutableDictionary *automaticProperties;
@property (nonatomic, copy, readonly) NSString *appVersion;
@property (nonatomic, copy, readonly) NSString *deviceID;

/**
获取 lib 相关属性

@param libMethod SDK 方法

@return lib 相关属性
*/
- (NSDictionary *)libPropertiesWithLibMethod:(NSString *)libMethod;

/// 是否为首日
- (BOOL)isFirstDay;

/// 当前的网络属性
- (NSDictionary *)currentNetworkProperties;

/// 当前的预置属性
- (NSDictionary *)currentPresetProperties;

@end

NS_ASSUME_NONNULL_END
