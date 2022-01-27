//
// UIViewController+ZA.m
// ZallDataSDK
//
// Created by guo on 2022/1/4.
// Copyright © 2022 Zall Data Co., Ltd. All rights reserved.
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

#import "UIViewController+ZAAdd.h"
#import "ZAQuickUtil.h"

@implementation UIViewController (ZAAdd)

+ (UIViewController *)za_currentViewController {
    __block UIViewController *currentViewController = nil;
    dispatch_block_t block = ^{
        UIViewController *rootViewController = UIApplication.sharedApplication.keyWindow.rootViewController;
        currentViewController = [self za_findCurrentViewControllerFromRootViewController:rootViewController isRoot:YES];
    };
    za_quick_dispatch_sync_on_main_queue(block);
    return currentViewController;
}

+ (UIViewController *)za_findNextViewControllerByResponder:(UIResponder *)responder {
    UIResponder *next = responder;
    do {
        if (![next isKindOfClass:UIViewController.class]) {
            continue;
        }
        UIViewController *vc = (UIViewController *)next;
        if ([vc isKindOfClass:UINavigationController.class]) {
            return [self za_findNextViewControllerByResponder:[(UINavigationController *)vc topViewController]];
        } else if ([vc isKindOfClass:UITabBarController.class]) {
            return [self za_findNextViewControllerByResponder:[(UITabBarController *)vc selectedViewController]];
        }
        
        UIViewController *parentVC = vc.parentViewController;
        if (!parentVC) {
            break;
        }
        if ([parentVC isKindOfClass:UINavigationController.class] ||
            [parentVC isKindOfClass:UITabBarController.class] ||
            [parentVC isKindOfClass:UIPageViewController.class] ||
            [parentVC isKindOfClass:UISplitViewController.class]) {
            break;
        }
    } while ((next = next.nextResponder));
    return [next isKindOfClass:UIViewController.class] ? (UIViewController *)next : nil;
}

+ (UIViewController *)za_findCurrentViewControllerFromRootViewController:(UIViewController *)viewController isRoot:(BOOL)isRoot {
    if ([self za_canFindPresentedViewController:viewController.presentedViewController]) {
         return [self za_findCurrentViewControllerFromRootViewController:viewController.presentedViewController isRoot:NO];
     }

    if ([viewController isKindOfClass:[UITabBarController class]]) {
        return [self za_findCurrentViewControllerFromRootViewController:[(UITabBarController *)viewController selectedViewController] isRoot:NO];
    }

    if ([viewController isKindOfClass:[UINavigationController class]]) {
        // 根视图为 UINavigationController
        UIViewController *topViewController = [(UINavigationController *)viewController topViewController];
        return [self za_findCurrentViewControllerFromRootViewController:topViewController isRoot:NO];
    }

    if (viewController.childViewControllers.count > 0) {
        if (viewController.childViewControllers.count == 1 && isRoot) {
            return [self za_findCurrentViewControllerFromRootViewController:viewController.childViewControllers.firstObject isRoot:NO];
        } else {
            __block UIViewController *currentViewController = viewController;
            //从最上层遍历（逆序），查找正在显示的 UITabBarController 或 UINavigationController 类型的
            // 是否包含 UINavigationController 或 UITabBarController 类全屏显示的 controller
            [viewController.childViewControllers enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(__kindof UIViewController *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
                // 判断 obj.view 是否加载，如果尚未加载，调用 obj.view 会触发 viewDidLoad，可能影响客户业务
                if (obj.isViewLoaded) {
                    CGPoint point = [obj.view convertPoint:CGPointZero toView:nil];
                    CGSize windowSize = obj.view.window.bounds.size;
                   // 正在全屏显示
                    BOOL isFullScreenShow = !obj.view.hidden && obj.view.alpha > 0.01 && CGPointEqualToPoint(point, CGPointZero) && CGSizeEqualToSize(obj.view.bounds.size, windowSize);
                   // 判断类型
                    BOOL isStopFindController = [obj isKindOfClass:UINavigationController.class] || [obj isKindOfClass:UITabBarController.class];
                    if (isFullScreenShow && isStopFindController) {
                        currentViewController = [self za_findCurrentViewControllerFromRootViewController:obj isRoot:NO];
                        *stop = YES;
                    }
                }
            }];
            return currentViewController;
        }
    } else if ([viewController respondsToSelector:NSSelectorFromString(@"contentViewController")]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        UIViewController *tempViewController = [viewController performSelector:NSSelectorFromString(@"contentViewController")];
#pragma clang diagnostic pop
        if (tempViewController) {
            return [self za_findCurrentViewControllerFromRootViewController:tempViewController isRoot:NO];
        }
    }
    return viewController;
}

+ (BOOL)za_canFindPresentedViewController:(UIViewController *)viewController {
    if (!viewController) {
        return NO;
    }
    if ([viewController isKindOfClass:UIAlertController.class]) {
        return NO;
    }
    if ([@"_UIContextMenuActionsOnlyViewController" isEqualToString:NSStringFromClass(viewController.class)]) {
        return NO;
    }
    return YES;
}


@end
