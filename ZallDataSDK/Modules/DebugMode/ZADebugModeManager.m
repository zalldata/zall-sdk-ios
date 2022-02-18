//
// ZADebugModeManager.m
// ZallDataSDK
//
// Created by guo on 2020/11/20.
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

#import "ZADebugModeManager.h"
#import "ZAModuleManager.h"
#import "ZallDataSDK+ZADebugMode.h"
#import "ZAAlertViewController.h"
#import "ZAURLUtils.h"
#import "ZAJSONUtil.h"
#import "ZANetwork.h"
#import "ZALog.h"
#import "ZAQuickUtil.h"
#import "ZAModuleManagerProtocol.h"
#import "ZallDataSDK+ZAPrivate.h"


@ZAAppLoadModule(ZADebugModeManager)
@interface ZADebugModeManager ()

@property (nonatomic) UInt8 debugAlertViewHasShownNumber;

@end

@implementation ZADebugModeManager

+ (instancetype)defaultManager {
    static dispatch_once_t onceToken;
    static ZADebugModeManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[ZADebugModeManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _showDebugAlertView = YES;
        _debugAlertViewHasShownNumber = 0;
    }
    return self;
}

- (void)setConfigOptions:(ZAConfigOptions *)configOptions {
    if (za_quick_app_extension()) {
        configOptions.enableDebugMode = NO;
    }
    _configOptions = configOptions;
    self.enable = configOptions.enableDebugMode;
}
- (ZADebugModeType)debugMode{
    return self.enable?ZADebugModeTypeTrack:_debugMode;
}
#pragma mark - ZAOpenURLProtocol

- (BOOL)canHandleURL:(nonnull NSURL *)url {
    return [url.host isEqualToString:@"debugmode"];
}

- (BOOL)handleURL:(nonnull NSURL *)url {
    // url query 解析
    NSDictionary *paramDic = [ZAURLUtils queryItemsWithURL:url];

    //如果没传 info_id，视为伪造二维码，不做处理
    if (paramDic.allKeys.count && [paramDic.allKeys containsObject:@"info_id"]) {
        [self showDebugModeAlertWithParams:paramDic];
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - ZADebugModeModuleProtocol

- (void)handleDebugMode:(ZADebugModeType)mode {
    if (_debugMode == mode) {
        return;
    }
    _debugMode = mode;

    if (_debugMode == ZADebugModeTypeOff) {
        return;
    }

    // 打开debug模式，弹出提示
    NSString *alertMessage = nil;
    if (_debugMode == ZADebugModeTypeOnly) {
        alertMessage = @"现在您打开了'DEBUG_ONLY'模式，此模式下只校验数据但不导入数据，数据出错时会以提示框的方式提示开发者，请上线前一定关闭。";
    } else if (_debugMode == ZADebugModeTypeTrack) {
        alertMessage = @"现在您打开了'DEBUG_AND_TRACK'模式，此模式下会校验数据并且导入数据，数据出错时会以提示框的方式提示开发者，请上线前一定关闭。";
    }
    [self showDebugModeWarning:alertMessage withNoMoreButton:NO];
}

- (void)showDebugModeWarning:(NSString *)message {
    [self showDebugModeWarning:message withNoMoreButton:YES];
}

#pragma mark - Private

- (void)showDebugModeAlertWithParams:(NSDictionary<NSString *, NSString *> *)params {
    dispatch_async(dispatch_get_main_queue(), ^{
        dispatch_block_t alterViewBlock = ^{

            NSString *alterViewMessage = @"";
            if (self.debugMode == ZADebugModeTypeTrack) {
                alterViewMessage = @"开启调试模式，校验数据，并将数据导入卓尔分析中；\n关闭 App 进程后，将自动关闭调试模式。";
            } else if (self.debugMode == ZADebugModeTypeOnly) {
                alterViewMessage = @"开启调试模式，校验数据，但不进行数据导入；\n关闭 App 进程后，将自动关闭调试模式。";
            } else {
                alterViewMessage = @"已关闭调试模式，重新扫描二维码开启";
            }
            ZAAlertViewController *alertController = [[ZAAlertViewController alloc] initWithTitle:@"" message:alterViewMessage preferredStyle:ZAAlertControllerStyleAlert];
            [alertController addActionWithTitle:@"确定" style:ZAAlertActionStyleCancel handler:nil];
            [alertController show];
        };

        NSString *alertTitle = @"SDK 调试模式选择";
        NSString *alertMessage = @"";
        if (self.debugMode == ZADebugModeTypeTrack) {
            alertMessage = @"当前为 调试模式（导入数据）";
        } else if (self.debugMode == ZADebugModeTypeOnly) {
            alertMessage = @"当前为 调试模式（不导入数据）";
        } else {
            alertMessage = @"调试模式已关闭";
        }
        ZAAlertViewController *alertController = [[ZAAlertViewController alloc] initWithTitle:alertTitle message:alertMessage preferredStyle:ZAAlertControllerStyleAlert];
        void(^handler)(ZADebugModeType) = ^(ZADebugModeType debugMode) {
            self.debugMode = debugMode;
            alterViewBlock();
            [self debugModeCallbackWithDistinctId:[ZallDataSDK sharedInstance].distinctId params:params];
        };
        [alertController addActionWithTitle:@"开启调试模式（导入数据）" style:ZAAlertActionStyleDefault handler:^(ZAAlertAction * _Nonnull action) {
            handler(ZADebugModeTypeTrack);
        }];
        [alertController addActionWithTitle:@"开启调试模式（不导入数据）" style:ZAAlertActionStyleDefault handler:^(ZAAlertAction * _Nonnull action) {
            handler(ZADebugModeTypeOnly);
        }];
        [alertController addActionWithTitle:@"取消" style:ZAAlertActionStyleCancel handler:nil];
        [alertController show];
    });
}

- (NSString *)debugModeToString:(ZADebugModeType)debugMode {
    NSString *modeStr = nil;
    switch (debugMode) {
        case ZADebugModeTypeOff:
            modeStr = @"DebugOff";
            break;
        case ZADebugModeTypeTrack:
            modeStr = @"DebugAndTrack";
            break;
        case ZADebugModeTypeOnly:
            modeStr = @"DebugOnly";
            break;
        default:
            modeStr = @"Unknown";
            break;
    }
    return modeStr;
}

- (void)showDebugModeWarning:(NSString *)message withNoMoreButton:(BOOL)showNoMore {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([ZAModuleManager.sharedInstance isDisableSDK]) {
            return;
        }

        if (self.debugMode == ZADebugModeTypeOff) {
            return;
        }

        if (!self.showDebugAlertView) {
            return;
        }

        if (self.debugAlertViewHasShownNumber >= 3) {
            return;
        }
        self.debugAlertViewHasShownNumber += 1;
        NSString *alertTitle = @"ZallData 重要提示";
        ZAAlertViewController *alertController = [[ZAAlertViewController alloc] initWithTitle:alertTitle message:message preferredStyle:ZAAlertControllerStyleAlert];
        [alertController addActionWithTitle:@"确定" style:ZAAlertActionStyleCancel handler:^(ZAAlertAction * _Nonnull action) {
            self.debugAlertViewHasShownNumber -= 1;
        }];
        if (showNoMore) {
            [alertController addActionWithTitle:@"不再显示" style:ZAAlertActionStyleDefault handler:^(ZAAlertAction * _Nonnull action) {
                self.showDebugAlertView = NO;
            }];
        }
        [alertController show];
    });
}

- (NSURL *)serverURL {
    return [ZallDataSDK sdkInstance].network.serverURL;
}

#pragma mark - Request

- (NSURL *)buildDebugModeCallbackURLWithParams:(NSDictionary<NSString *, NSString *> *)params {
    NSURLComponents *urlComponents = nil;
    NSString *sfPushCallbackUrl = params[@"sf_push_distinct_id"];
    NSString *infoId = params[@"info_id"];
    NSString *project = params[@"project"];
    if (sfPushCallbackUrl.length > 0 && infoId.length > 0 && project.length > 0) {
        NSURL *url = [NSURL URLWithString:sfPushCallbackUrl];
        urlComponents = [[NSURLComponents alloc] initWithURL:url resolvingAgainstBaseURL:NO];
        urlComponents.queryItems = @[[[NSURLQueryItem alloc] initWithName:@"project" value:project], [[NSURLQueryItem alloc] initWithName:@"info_id" value:infoId]];
        return urlComponents.URL;
    }
    urlComponents = [NSURLComponents componentsWithURL:self.serverURL resolvingAgainstBaseURL:NO];
    NSString *queryString = [ZAURLUtils urlQueryStringWithParams:params];
    if (urlComponents.query.length) {
        urlComponents.query = [NSString stringWithFormat:@"%@&%@", urlComponents.query, queryString];
    } else {
        urlComponents.query = queryString;
    }
    return urlComponents.URL;
}

- (NSURLRequest *)buildDebugModeCallbackRequestWithURL:(NSURL *)url distinctId:(NSString *)distinctId {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.timeoutInterval = 30;
    [request setHTTPMethod:@"POST"];
    [request setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];

    NSDictionary *callData = @{@"distinct_id": distinctId};
    NSString *jsonString = [ZAJSONUtil stringWithJSONObject:callData];
    [request setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];

    return request;
}

- (NSURLSessionTask *)debugModeCallbackWithDistinctId:(NSString *)distinctId params:(NSDictionary<NSString *, NSString *> *)params {
    if (self.serverURL.absoluteString.length == 0) {
        ZALogError(@"serverURL error，Please check the serverURL");
        return nil;
    }
    NSURL *url = [self buildDebugModeCallbackURLWithParams:params];
    if (!url) {
        ZALogError(@"callback url in debug mode was nil");
        return nil;
    }

    NSURLRequest *request = [self buildDebugModeCallbackRequestWithURL:url distinctId:distinctId];

    NSURLSessionDataTask *task = [ZAHTTPSession.sharedInstance dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSHTTPURLResponse * _Nullable response, NSError * _Nullable error) {
        NSInteger statusCode = response.statusCode;
        if (statusCode == 200) {
            ZALogDebug(@"config debugMode CallBack success");
        } else {
            ZALogError(@"config debugMode CallBack Faild statusCode：%ld，url：%@", (long)statusCode, url);
        }
    }];
    [task resume];
    return task;
}

@end
