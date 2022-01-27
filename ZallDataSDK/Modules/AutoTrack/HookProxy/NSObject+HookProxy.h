//
// NSObject+DelegateProxy.h
// ZallDataSDK
//
// Created by guo on 2020/11/5.
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

 

@class ZAProxyObject;
@interface NSObject (HookProxy)

@property (nonatomic, copy) NSSet<NSString *> *za_hook_optionalSelectors;
@property (nonatomic, strong) ZAProxyObject *za_hook_proxyObject;

/// hook respondsToSelector to resolve optional selectors
/// @param aSelector selector
- (BOOL)za_hook_respondsToSelector:(SEL)aSelector;

@end
 
@interface NSProxy (HookProxy)
@property (nonatomic, copy) NSSet<NSString *> *za_hook_optionalSelectors;
@property (nonatomic, strong) ZAProxyObject *za_hook_proxyObject;

/// hook respondsToSelector to resolve optional selectors
/// @param aSelector selector
- (BOOL)za_hook_respondsToSelector:(SEL)aSelector;


@end

NS_ASSUME_NONNULL_END
