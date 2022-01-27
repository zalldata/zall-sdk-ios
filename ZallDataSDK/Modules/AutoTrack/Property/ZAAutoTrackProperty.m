//
// ZAAutoTrackProperty.m
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

#import "ZAAutoTrackProperty.h"
#import "ZAAutoTrackProperty.h"
#import "ZAConstantsDefin.h"
#import "ZAUtilCheck.h"
#import "UIView+ZAProperty.h"
#import "ZAModuleManager.h"
#import "UIView+AutoTrackProperty.h"
#import "ZALog.h"
@implementation ZAAutoTrackProperty

+ (NSInteger)itemIndexForResponder:(UIResponder *)responder {
    NSString *classString = NSStringFromClass(responder.class);
    NSInteger count = 0;
    NSInteger index = -1;
    NSArray<UIResponder *> *brothersResponder = [self brothersElementForResponder:responder];

    for (UIResponder *res in brothersResponder) {
        if ([classString isEqualToString:NSStringFromClass(res.class)]) {
            count++;
        }
        if (res == responder) {
            index = count - 1;
        }
    }
    // 单个 UIViewController（即不存在其他兄弟 viewController） 拼接路径，不需要序号
    if ([responder isKindOfClass:UIViewController.class] && ![responder isKindOfClass:UIAlertController.class] && count == 1) {
        return -2;
    }

    /* 序号说明
     -2：nextResponder 不是父视图或同类元素，比如 controller.view，涉及路径不带序号
     -1：同级只存在一个同类元素
     >=0：元素序号
     */
    // 如果 responder 是 UIViewController.view，此时 count = 0
    return count == 0 || count == 1 ? count - 2 : index;
}

/// 寻找所有兄弟元素
+ (NSArray <UIResponder *> *)brothersElementForResponder:(UIResponder *)responder {
    if ([responder isKindOfClass:UIView.class]) {
        UIResponder *next = [responder nextResponder];
        if ([next isKindOfClass:UIView.class]) {
            NSArray<UIView *> *subViews = [(UIView *)next subviews];
            if ([next isKindOfClass:UISegmentedControl.class]) {
                // UISegmentedControl 点击之后，subviews 顺序会变化，需要根据坐标排序才能得到准确序号
                NSArray<UIView *> *brothers = [subViews sortedArrayUsingComparator:^NSComparisonResult (UIView *obj1, UIView *obj2) {
                    if (obj1.frame.origin.x > obj2.frame.origin.x) {
                        return NSOrderedDescending;
                    } else {
                        return NSOrderedAscending;
                    }
                }];
                return brothers;
            }
            return subViews;
        }
    } else if ([responder isKindOfClass:UIViewController.class]) {
        return [(UIViewController *)responder parentViewController].childViewControllers;
    }
    return nil;
}

+ (NSDictionary<NSString *, NSString *> *)propertiesWithViewController:(UIViewController<ZAAutoTrackViewControllerProperty> *)viewController {
    NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
    properties[kZAEventPropertyScreenName] = viewController.za_property_screenName;
    properties[kZAEventPropertyTitle] = viewController.za_property_title;
    
    if ([viewController conformsToProtocol:@protocol(ZAAutoTrackProperties)] &&
        [viewController respondsToSelector:@selector(getTrackProperties)]) {
        NSDictionary *trackProperties = [(UIViewController<ZAAutoTrackProperties> *)viewController getTrackProperties];
        if (!za_check_empty_dict(trackProperties)) {
            [properties addEntriesFromDictionary:trackProperties];
        }
    }

    return [properties copy];
}

+ (NSMutableDictionary<NSString *, NSString *> *)propertiesWithAutoTrackObject:(id<ZAAutoTrackViewProperty>)object {
    return [self propertiesWithAutoTrackObject:object viewController:nil isCodeTrack:NO];
}

+ (NSMutableDictionary<NSString *, NSString *> *)propertiesWithAutoTrackObject:(id<ZAAutoTrackViewProperty>)object isCodeTrack:(BOOL)isCodeTrack {
    return [self propertiesWithAutoTrackObject:object viewController:nil isCodeTrack:isCodeTrack];
}

+ (NSMutableDictionary<NSString *, NSString *> *)propertiesWithAutoTrackObject:(id<ZAAutoTrackViewProperty>)object viewController:(nullable UIViewController<ZAAutoTrackViewControllerProperty> *)viewController {
    return [self propertiesWithAutoTrackObject:object viewController:viewController isCodeTrack:NO];
}

+ (NSMutableDictionary<NSString *, NSString *> *)propertiesWithAutoTrackObject:(id<ZAAutoTrackViewProperty>)object viewController:(nullable UIViewController<ZAAutoTrackViewControllerProperty> *)viewController isCodeTrack:(BOOL)isCodeTrack {
    if (![object respondsToSelector:@selector(za_property_isIgnored)] || (!isCodeTrack && object.za_property_isIgnored)) {
        return nil;
    }

    NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
    // ViewID
    properties[kZAEventPropertyElementId] = object.za_property_elementId;

    viewController = viewController ? : object.za_property_viewController;
    if (!isCodeTrack && viewController.za_property_isIgnored) {
        return nil;
    }

    NSDictionary *dic = [self propertiesWithViewController:viewController];
    [properties addEntriesFromDictionary:dic];

    properties[kZAEventPropertyElementType] = object.za_property_elementType;
    properties[kZAEventPropertyElementContent] = object.za_property_elementContent;
    properties[kZAEventPropertyElementPosition] = object.za_property_elementPosition;

    UIView *view = (UIView *)object;
    //View Properties
    if ([object isKindOfClass:UIView.class]) {
        [properties addEntriesFromDictionary:view.za_viewProperties];
    } else {
        return properties;
    }

    // viewPath
    NSDictionary *viewPathProperties = [[ZAModuleManager sharedInstance] propertiesWithView:view];
    if (viewPathProperties) {
        [properties addEntriesFromDictionary:viewPathProperties];
    }

    return properties;
}

+ (NSMutableDictionary<NSString *, NSString *> *)propertiesWithAutoTrackObject:(UIScrollView<ZAAutoTrackViewProperty> *)object didSelectedAtIndexPath:(NSIndexPath *)indexPath {
    if (![object respondsToSelector:@selector(za_property_isIgnored)] || object.za_property_isIgnored) {
        return nil;
    }
    NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];

    UIView <ZAAutoTrackItemProperty> *cell = (UIView <ZAAutoTrackItemProperty> *)[self cellWithScrollView:object selectedAtIndexPath:indexPath];
    if (!cell) {
        return nil;
    }

    // ViewID
    properties[kZAEventPropertyElementId] = object.za_property_elementId;

    UIViewController<ZAAutoTrackViewControllerProperty> *viewController = object.za_property_viewController;
    if (viewController.za_property_isIgnored) {
        return nil;
    }

    NSDictionary *dic = [self propertiesWithViewController:viewController];
    [properties addEntriesFromDictionary:dic];

    properties[kZAEventPropertyElementType] = object.za_property_elementType;
    properties[kZAEventPropertyElementContent] = cell.za_property_elementContent;
    properties[kZAEventPropertyElementPosition] = [cell za_property_elementPositionWithIndexPath:indexPath];

    //View Properties
    NSDictionary *viewProperties = ((UIView *)object).za_viewProperties;
    if (viewProperties.count > 0) {
        [properties addEntriesFromDictionary:viewProperties];
    }

    // viewPath
    NSDictionary *viewPathProperties = [[ZAModuleManager sharedInstance] propertiesWithView:(UIView *)cell];
    if (viewPathProperties) {
        [properties addEntriesFromDictionary:viewPathProperties];
    }

    return properties;
}

+ (UIView *)cellWithScrollView:(UIScrollView *)scrollView selectedAtIndexPath:(NSIndexPath *)indexPath {
    UIView *cell = nil;
    if ([scrollView isKindOfClass:UITableView.class]) {
        UITableView *tableView = (UITableView *)scrollView;
        cell = [tableView cellForRowAtIndexPath:indexPath];
        if (!cell) {
            [tableView layoutIfNeeded];
            cell = [tableView cellForRowAtIndexPath:indexPath];
        }
    } else if ([scrollView isKindOfClass:UICollectionView.class]) {
        UICollectionView *collectionView = (UICollectionView *)scrollView;
        cell = [collectionView cellForItemAtIndexPath:indexPath];
        if (!cell) {
            [collectionView layoutIfNeeded];
            cell = [collectionView cellForItemAtIndexPath:indexPath];
        }
    }
    return cell;
}

+ (NSDictionary *)propertiesWithAutoTrackDelegate:(UIScrollView *)scrollView didSelectedAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *properties = nil;
    @try {
        if ([scrollView isKindOfClass:UITableView.class]) {
            UITableView *tableView = (UITableView *)scrollView;
            
            if ([tableView.za_viewPropertyDelegate respondsToSelector:@selector(za_tableView:autoTrackPropertiesAtIndexPath:)]) {
                properties = [tableView.za_viewPropertyDelegate za_tableView:tableView autoTrackPropertiesAtIndexPath:indexPath];
            }
        } else if ([scrollView isKindOfClass:UICollectionView.class]) {
            UICollectionView *collectionView = (UICollectionView *)scrollView;
            if ([collectionView.za_viewPropertyDelegate respondsToSelector:@selector(za_collectionView:autoTrackPropertiesAtIndexPath:)]) {
                properties = [collectionView.za_viewPropertyDelegate za_collectionView:collectionView autoTrackPropertiesAtIndexPath:indexPath];
            }
        }
    } @catch (NSException *exception) {
        ZALogError(@"%@ error: %@", self, exception);
    }
    NSAssert(!properties || [properties isKindOfClass:[NSDictionary class]], @"You must return a dictionary object ❌");
    return properties;
}

@end
