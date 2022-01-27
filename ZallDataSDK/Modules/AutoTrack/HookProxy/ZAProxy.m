//
//  ZADelegateProxy.m
//  ZallDataSDK
//
//  Created by guo on 2019/6/19.
//  Copyright © 2019 ZallData. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag on this file.
#endif

#import "ZAProxy.h"
#import "ZAClassHelper.h"
#import "ZAMethodHelper.h"
#import "ZALog.h"
#import "NSObject+HookProxy.h"
#import <objc/message.h>
#import "ZAQuickUtil.h"
#import "ZAProxyObject.h"

static NSString * const kZANSObjectRemoveObserverSelector = @"removeObserver:forKeyPath:";
static NSString * const kZANSObjectAddObserverSelector = @"addObserver:forKeyPath:options:context:";
static NSString * const kZANSObjectClassSelector = @"class";

@implementation ZAProxy

+ (void)proxyDelegate:(id)delegate selectors:(NSSet<NSString *> *)selectors {
    if (object_isClass(delegate) || selectors.count == 0) {
        return;
    }
    
    Class proxyClass = [self class];
    NSMutableSet *delegateSelectors = [NSMutableSet setWithSet:selectors];

    ZAProxyObject *object = [delegate za_hook_proxyObject];
    if (!object) {
        object = [[ZAProxyObject alloc] initWithDelegate:delegate proxy:proxyClass];
        [delegate setZa_hook_proxyObject:object];
    }

    [delegateSelectors minusSet:object.selectors];
    if (delegateSelectors.count == 0) {
        return;
    }

    if (object.zallClass) {
        [self addInstanceMethodWithSelectors:delegateSelectors fromClass:proxyClass toClass:object.zallClass];
        [object.selectors unionSet:delegateSelectors];

        // 代理对象未继承自卓尔类, 需要重置代理对象的 isa 为卓尔类
        if (![object_getClass(delegate) isSubclassOfClass:object.zallClass]) {
            [ZAClassHelper setObject:delegate toClass:object.zallClass];
        }
        return;
    }

    if (object.kvoClass) {
        // 在移除所有的 KVO 属性监听时, 系统会重置对象的 isa 指针为原有的类;
        // 因此需要在移除监听时, 重新为代理对象设置新的子类, 来采集点击事件.
        if ([delegate isKindOfClass:NSObject.class] && ![object.selectors containsObject:kZANSObjectRemoveObserverSelector]) {
            [delegateSelectors addObject:kZANSObjectRemoveObserverSelector];
        }
        [self addInstanceMethodWithSelectors:delegateSelectors fromClass:proxyClass toClass:object.kvoClass];
        [object.selectors unionSet:delegateSelectors];
        return;
    }

    Class zallClass = [ZAClassHelper allocateClassWithObject:delegate className:object.zallClassName];
    [ZAClassHelper registerClass:zallClass];

    // 新建子类后, 需要监听是否添加了 KVO, 因为添加 KVO 属性监听后,
    // KVO 会重写 Class 方法, 导致获取的 Class 为卓尔添加的子类
    if ([delegate isKindOfClass:NSObject.class] && ![object.selectors containsObject:kZANSObjectAddObserverSelector]) {
        [delegateSelectors addObject:kZANSObjectAddObserverSelector];
    }

    // 重写 Class 方法
    if (![object.selectors containsObject:kZANSObjectClassSelector]) {
        [delegateSelectors addObject:kZANSObjectClassSelector];
    }

    [self addInstanceMethodWithSelectors:delegateSelectors fromClass:proxyClass toClass:zallClass];
    [object.selectors unionSet:delegateSelectors];

    [ZAClassHelper setObject:delegate toClass:zallClass];
}

+ (void)addInstanceMethodWithSelectors:(NSSet<NSString *> *)selectors fromClass:(Class)fromClass toClass:(Class)toClass {
    for (NSString *selector in selectors) {
        SEL sel = NSSelectorFromString(selector);
        [ZAMethodHelper addInstanceMethodWithSelector:sel fromClass:fromClass toClass:toClass];
    }
}

+ (void)invokeWithTarget:(NSObject *)target selector:(SEL)selector, ... {
    Class originalClass = target.za_hook_proxyObject.delegateISA;

    va_list args;
    va_start(args, selector);
    id arg1 = nil, arg2 = nil, arg3 = nil, arg4 = nil;
    NSInteger count = [NSStringFromSelector(selector) componentsSeparatedByString:@":"].count - 1;
    for (NSInteger i = 0; i < count; i++) {
        i == 0 ? (arg1 = va_arg(args, id)) : nil;
        i == 1 ? (arg2 = va_arg(args, id)) : nil;
        i == 2 ? (arg3 = va_arg(args, id)) : nil;
        i == 3 ? (arg4 = va_arg(args, id)) : nil;
    }
    struct objc_super targetSuper = {
        .receiver = target,
        .super_class = originalClass
    };
    // 消息转发给原始类
    @try {
        void (*func)(struct objc_super *, SEL, id, id, id, id) = (void *)&objc_msgSendSuper;
        func(&targetSuper, selector, arg1, arg2, arg3, arg4);
    } @catch (NSException *exception) {
        ZALogInfo(@"msgSendSuper with exception: %@", exception);
    } @finally {
        va_end(args);
    }
}

+ (void)resolveOptionalSelectorsForDelegate:(id)delegate {
    if (object_isClass(delegate)) {
        return;
    }

    NSSet *currentOptionalSelectors = ((NSObject *)delegate).za_hook_optionalSelectors;
    NSMutableSet *optionalSelectors = [[NSMutableSet alloc] init];
    if (currentOptionalSelectors) {
        [optionalSelectors unionSet:currentOptionalSelectors];
    }
    
    if ([self respondsToSelector:@selector(optionalSelectors)] &&[self optionalSelectors]) {
        [optionalSelectors unionSet:[self optionalSelectors]];
    }
    ((NSObject *)delegate).za_hook_optionalSelectors = [optionalSelectors copy];
}

@end

#pragma mark - Class
@implementation ZAProxy (Class)

- (Class)class {
    if (self.za_hook_proxyObject.delegateClass) {
        return self.za_hook_proxyObject.delegateClass;
    }
    return [super class];
}

@end

#pragma mark - KVO
@implementation ZAProxy (KVO)

- (void)addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context {
    [super addObserver:observer forKeyPath:keyPath options:options context:context];
    if (self.za_hook_proxyObject) {
        // 由于添加了 KVO 属性监听, KVO 会创建子类并重写 Class 方法,返回原始类; 此时的原始类为卓尔添加的子类,因此需要重写 class 方法
        [ZAMethodHelper replaceInstanceMethodWithDestinationSelector:@selector(class) sourceSelector:@selector(class) fromClass:ZAProxy.class toClass:object_getClass(self)];
    }
}

- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath {
    // remove 前代理对象是否归属于 KVO 创建的类
    BOOL oldClassIsKVO = [ZAProxyObject isKVOClass:object_getClass(self)];
    [super removeObserver:observer forKeyPath:keyPath];
    // remove 后代理对象是否归属于 KVO 创建的类
    BOOL newClassIsKVO = [ZAProxyObject isKVOClass:object_getClass(self)];
    
    // 有多个属性监听时, 在最后一个监听被移除后, 对象的 isa 发生变化, 需要重新为代理对象添加子类
    if (oldClassIsKVO && !newClassIsKVO) {
        Class delegateProxy = self.za_hook_proxyObject.delegateProxy;
        NSSet *selectors = [self.za_hook_proxyObject.selectors copy];

        [self.za_hook_proxyObject removeKVO];
        if ([delegateProxy respondsToSelector:@selector(proxyDelegate:selectors:)]) {
            [delegateProxy proxyDelegate:self selectors:selectors];
        }
    }
}

@end
