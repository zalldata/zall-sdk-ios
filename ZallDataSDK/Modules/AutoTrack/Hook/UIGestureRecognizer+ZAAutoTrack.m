//
//  UIGestureRecognizer+ZAAutoTrack.m
//  ZallDataSDK
//
//  Created by guo on 2018/10/25.
//  Copyright © 2015-2020 Zall Data Co., Ltd. All rights reserved.
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

#import "UIGestureRecognizer+ZAAutoTrack.h"
#import <objc/runtime.h>
#import "ZASwizzle.h"
#import "ZALog.h"


@implementation UIGestureRecognizer (ZAAutoTrack)

#pragma mark - Hook Method
- (instancetype)za_autoTrack_initWithTarget:(id)target action:(SEL)action{
    [self za_autoTrack_initWithTarget:target action:action];
    [self removeTarget:target action:action];
    [self addTarget:target action:action];
    return self;
}
-(void)za_autoTrack_addTarget:(id)target action:(SEL)action{
    // 在 iOS 12 及以下系统中, 从 StoryBoard 加载的手势不会调用 - initWithTarget:action: 方法;
    // 1. 在 - addTarget:action 时对 zalldata_gestureTarget 和 zalldata_targetActionModels 进行初始化
    // 2. zalldata_gestureTarget 可能会初始化为空值, 因此使用 zalldata_targetActionModels 判断是否初始化过.
    if (!self.za_autoTrack_targetActionModels) {
        self.za_autoTrack_targetActionModels = [NSMutableArray array];
        self.za_autoTrack_gestureTarget = [ZAGestureTarget targetWithGesture:self];
    }

    // Track 事件需要在原有事件之前触发(原有事件中更改页面内容,会导致部分内容获取不准确)
    if (self.za_autoTrack_gestureTarget) {
        if (![ZAGestureTargetActionModel containsObjectWithTarget:target andAction:action fromModels:self.za_autoTrack_targetActionModels]) {
            ZAGestureTargetActionModel *resulatModel = [[ZAGestureTargetActionModel alloc] initWithTarget:target action:action];
            [self.za_autoTrack_targetActionModels addObject:resulatModel];
            [self za_autoTrack_addTarget:self.za_autoTrack_gestureTarget action:@selector(trackGestureRecognizerAppClick:)];
        }
    }
    [self za_autoTrack_addTarget:target action:action];
}
-(void)za_autoTrack_removeTarget:(id)target action:(SEL)action{
    if (self.za_autoTrack_gestureTarget) {
        ZAGestureTargetActionModel *existModel = [ZAGestureTargetActionModel containsObjectWithTarget:target andAction:action fromModels:self.za_autoTrack_targetActionModels];
        if (existModel) {
            [self.za_autoTrack_targetActionModels removeObject:existModel];
        }
    }
    [self za_autoTrack_removeTarget:target action:action];
}

#pragma mark - Associated Object
-(ZAGestureTarget *)za_autoTrack_gestureTarget{
    return objc_getAssociatedObject(self, @selector(za_autoTrack_gestureTarget));
}
-(void)setZa_autoTrack_gestureTarget:(ZAGestureTarget * _Nonnull)za_autoTrack_gestureTarget{
    objc_setAssociatedObject(self, @selector(za_autoTrack_gestureTarget), za_autoTrack_gestureTarget, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NSMutableArray<ZAGestureTargetActionModel *> *)za_autoTrack_targetActionModels{
    return objc_getAssociatedObject(self, @selector(za_autoTrack_targetActionModels));
}
-(void)setZa_autoTrack_targetActionModels:(NSMutableArray<ZAGestureTargetActionModel *> * _Nonnull)za_autoTrack_targetActionModels{
    objc_setAssociatedObject(self, @selector(za_autoTrack_targetActionModels), za_autoTrack_targetActionModels, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
 

@end
