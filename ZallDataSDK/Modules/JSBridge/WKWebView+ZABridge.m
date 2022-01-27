//
// WKWebView+ZABridge.m
// ZallDataSDK
//
// Created by guo on 2020/3/21.
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

#import "WKWebView+ZABridge.h"
#import "ZAJavaScriptBridgeManager.h"

@implementation WKWebView (ZABridge)

- (WKNavigation *)zalldata_loadRequest:(NSURLRequest *)request {
    [[ZAJavaScriptBridgeManager defaultManager] addScriptMessageHandlerWithWebView:self];
    
    return [self zalldata_loadRequest:request];
}

- (WKNavigation *)zalldata_loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL {
    [[ZAJavaScriptBridgeManager defaultManager] addScriptMessageHandlerWithWebView:self];
    
    return [self zalldata_loadHTMLString:string baseURL:baseURL];
}

- (WKNavigation *)zalldata_loadFileURL:(NSURL *)URL allowingReadAccessToURL:(NSURL *)readAccessURL {
    [[ZAJavaScriptBridgeManager defaultManager] addScriptMessageHandlerWithWebView:self];
    
    return [self zalldata_loadFileURL:URL allowingReadAccessToURL:readAccessURL];
}

- (WKNavigation *)zalldata_loadData:(NSData *)data MIMEType:(NSString *)MIMEType characterEncodingName:(NSString *)characterEncodingName baseURL:(NSURL *)baseURL {
    [[ZAJavaScriptBridgeManager defaultManager] addScriptMessageHandlerWithWebView:self];
    
    return [self zalldata_loadData:data MIMEType:MIMEType characterEncodingName:characterEncodingName baseURL:baseURL];
}

@end
