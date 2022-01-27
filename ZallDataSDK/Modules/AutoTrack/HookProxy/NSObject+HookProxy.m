//
// NSObject+ZACellClick.m
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

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag on this file.
#endif

#import "NSObject+HookProxy.h"
#import <objc/runtime.h>




@implementation NSObject (HookProxy)

-(NSSet<NSString *> *)za_hook_optionalSelectors{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setZa_hook_optionalSelectors:(NSSet<NSString *> *)za_hook_optionalSelectors{
    objc_setAssociatedObject(self, @selector(za_hook_optionalSelectors), za_hook_optionalSelectors, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
-(ZAProxyObject *)za_hook_proxyObject{
    return objc_getAssociatedObject(self, _cmd);
}
-(void)setZa_hook_proxyObject:(ZAProxyObject *)za_hook_proxyObject{
    objc_setAssociatedObject(self, @selector(za_hook_proxyObject), za_hook_proxyObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
  
 
- (BOOL)za_hook_respondsToSelector:(nonnull SEL)aSelector {
    if ([self za_hook_respondsToSelector:aSelector]) {
        return YES;
    }
    if ([self.za_hook_optionalSelectors containsObject:NSStringFromSelector(aSelector)]) {
        return YES;
    }
    return NO;
}

 
@end

@implementation NSProxy (HookProxy)

-(NSSet<NSString *> *)za_hook_optionalSelectors{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setZa_hook_optionalSelectors:(NSSet<NSString *> *)za_hook_optionalSelectors{
    objc_setAssociatedObject(self, @selector(za_hook_optionalSelectors), za_hook_optionalSelectors, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
-(ZAProxyObject *)za_hook_proxyObject{
    return objc_getAssociatedObject(self, _cmd);
}
-(void)setZa_hook_proxyObject:(ZAProxyObject *)za_hook_proxyObject{
    objc_setAssociatedObject(self, @selector(za_hook_proxyObject), za_hook_proxyObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
  
 
- (BOOL)za_hook_respondsToSelector:(nonnull SEL)aSelector {
    if ([self za_hook_respondsToSelector:aSelector]) {
        return YES;
    }
    if ([self.za_hook_optionalSelectors containsObject:NSStringFromSelector(aSelector)]) {
        return YES;
    }
    return NO;
}


@end
