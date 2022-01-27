//
// ZAEventLibObject.m
// ZallDataSDK
//
// Created by guo on 2021/4/6.
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

#import "ZAEventLibObject.h"
#import "ZAConstantsDefin.h"
#import "ZallDataSDK.h"
#import "ZAPresetProperty.h"
#import "ZAQuickUtil.h"
#import "ZAUtilCheck.h"

@implementation ZAEventLibObject

- (instancetype)init {
    self = [super init];
    if (self) {
        _lib = @"iOS";
        _method = kZALibMethodCode;
        _version = [ZallDataSDK libVersion];
        _appVersion = za_quick_app_version();
        _detail = nil;
    }
    return self;
}

- (void)setMethod:(NSString *)method {
    if (za_check_empty_string(method)) {
        return;
    }
    _method = method;
}

#pragma mark - public
- (NSMutableDictionary *)jsonObject {
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    properties[kZAEventPresetPropertyLib] = self.lib;
    properties[kZAEventPresetPropertyLibVersion] = self.version;
    properties[kZAEventPresetPropertyAppVersion] = self.appVersion;
    properties[kZAEventPresetPropertyLibMethod] = self.method;
    properties[kZAEventPresetPropertyLibDetail] = self.detail;
    return properties;
}

@end
