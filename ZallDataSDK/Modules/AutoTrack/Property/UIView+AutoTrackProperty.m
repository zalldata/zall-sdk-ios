//
//  UIView+za_autoTrack.m
//  ZallDataSDK
//
//  Created by guo on 2018/6/11.
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

#import "UIView+AutoTrackProperty.h"
#import <objc/runtime.h>
#import "ZAAutoTrackManager.h"
#import "UIView+ZAProperty.h"
#import "ZAViewElementInfo.h"
#import "ZAViewElementInfoFactory.h"
#import "UIView+ZAAdd.h"
#import "UIViewController+ZAAdd.h"
#import "ZallDataSDK+ZAPrivate.h"

#pragma mark - UIView

@implementation UIView (AutoTrackProperty)

-(BOOL)za_property_isIgnored{
    if (self.isHidden || self.za_viewPropertyIgnore) {
        return YES;
    }

    return [ZAAutoTrackManager.defaultManager.trackerAppClick isIgnoreEventWithView:self];
}

-(void)setZa_property_timeIntervalForLastAppClick:(NSTimeInterval)za_property_timeIntervalForLastAppClick{
    objc_setAssociatedObject(self, @selector(za_property_timeIntervalForLastAppClick), [NSNumber numberWithDouble:za_property_timeIntervalForLastAppClick], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSTimeInterval)za_property_timeIntervalForLastAppClick{
    return [objc_getAssociatedObject(self, @selector(za_property_timeIntervalForLastAppClick)) doubleValue];
}
 

-(NSString *)za_property_elementType{
    ZAViewElementInfo *elementInfo = [ZAViewElementInfoFactory elementInfoWithView:self];
    return elementInfo.elementType;
}
- (NSString *)za_property_elementContent {
    if ([self isKindOfClass:NSClassFromString(@"RTLabel")]) {   // RTLabel:https://github.com/honcheng/RTLabel
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        if ([self respondsToSelector:NSSelectorFromString(@"text")]) {
            NSString *title = [self performSelector:NSSelectorFromString(@"text")];
            if (title.length > 0) {
                return title;
            }
        }
        return nil;
    }
    if ([self isKindOfClass:NSClassFromString(@"YYLabel")]) {    // RTLabel:https://github.com/ibireme/YYKit
        if ([self respondsToSelector:NSSelectorFromString(@"text")]) {
            NSString *title = [self performSelector:NSSelectorFromString(@"text")];
            if (title.length > 0) {
                return title;
            }
        }
        return nil;
#pragma clang diagnostic pop
    }
    if (self.za_isKindOfRNView) { // RN 元素，https://reactnative.dev
        NSString *content = [self.accessibilityLabel stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (content.length > 0) {
            return content;
        }
    }

    if ([self isKindOfClass:NSClassFromString(@"WXView")]) { // WEEX 元素，http://doc.weex.io/zh/docs/components/a.html
        NSString *content = [self.accessibilityValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (content.length > 0) {
            return content;
        }
    }

    NSMutableArray<NSString *> *elementContentArray = [NSMutableArray array];
    for (UIView *subview in self.subviews) {
        // 忽略隐藏控件
        if (subview.isHidden || subview.za_viewPropertyIgnore) {
            continue;
        }
        NSString *temp = subview.za_property_elementContent;
        if (temp.length > 0) {
            [elementContentArray addObject:temp];
        }
    }
    if (elementContentArray.count > 0) {
        return [elementContentArray componentsJoinedByString:@"-"];
    }
    
    return nil;
}
-(NSString *)za_property_elementPosition{
    UIView *superView = self.superview;
    if (!superView) {
        return nil;
    }
    return superView.za_property_elementPosition;
}
-(NSString *)za_property_elementId{
    return self.za_viewPropertyID;
}

-(UIViewController *)za_property_viewController{
    UIViewController *viewController = [UIViewController za_findNextViewControllerByResponder:self];

    // 获取当前 controller 作为 screen_name
    if (!viewController || [viewController isKindOfClass:UIAlertController.class]) {
        viewController = UIViewController.za_currentViewController;
    }
    return viewController;
}
 

@end

@implementation UILabel (AutoTrackProperty)
-(NSString *)za_property_elementContent{
    return self.text ?: super.za_property_elementContent;
}

@end

@implementation UIImageView (AutoTrackProperty)
-(NSString *)za_property_elementContent{
    NSString *imageName = self.image.za_imageName;
    if (imageName.length > 0) {
        return [NSString stringWithFormat:@"%@", imageName];
    }
    return super.za_property_elementContent;
}
-(NSString *)za_property_elementPosition{
    if ([NSStringFromClass(self.class) isEqualToString:@"UISegment"]) {
        NSInteger index = [ZAAutoTrackProperty itemIndexForResponder:self];
        return index > 0 ? [NSString stringWithFormat:@"%ld", (long)index] : @"0";
    }
    return [super za_property_elementPosition];
}

@end

@implementation UISearchBar (AutoTrackProperty)

- (NSString *)za_property_elementContent {
    return self.text;
}

@end

#pragma mark - UIControl

@implementation UIControl (AutoTrackProperty)
-(BOOL)za_property_isIgnored{
    // 忽略 UITabBarItem
    
    BOOL ignoredUITabBarItem = [ZallDataSDK.sdkInstance isViewTypeIgnored:UITabBarItem.class] && [NSStringFromClass(self.class) isEqualToString:@"UITabBarButton"];

    // 忽略 UIBarButtonItem
    BOOL ignoredUIBarButtonItem = [ZallDataSDK.sdkInstance isViewTypeIgnored:UIBarButtonItem.class] && ([NSStringFromClass(self.class) isEqualToString:@"UINavigationButton"] || [NSStringFromClass(self.class) isEqualToString:@"_UIButtonBarButton"]);

    return super.za_property_isIgnored || ignoredUITabBarItem || ignoredUIBarButtonItem;
}
-(NSString *)za_property_elementType{
    // UIBarButtonItem
    if (([NSStringFromClass(self.class) isEqualToString:@"UINavigationButton"] || [NSStringFromClass(self.class) isEqualToString:@"_UIButtonBarButton"])) {
        return @"UIBarButtonItem";
    }

    // UITabBarItem
    if ([NSStringFromClass(self.class) isEqualToString:@"UITabBarButton"]) {
        return @"UITabBarItem";
    }
    return NSStringFromClass(self.class);
}


- (NSString *)za_property_elementPosition {
    // UITabBarItem
    if ([NSStringFromClass(self.class) isEqualToString:@"UITabBarButton"]) {
        NSInteger index = [ZAAutoTrackProperty itemIndexForResponder:self];
        if (index < 0) {
            index = 0;
        }
        return [NSString stringWithFormat:@"%ld", (long)index];
    }

    return super.za_property_elementPosition;
}

@end

@implementation UIButton (AutoTrackProperty)
-(NSString *)za_property_elementContent{
    NSString *text = self.titleLabel.text;
    if (!text) {
        text = super.za_property_elementContent;
    }
    return text;
}

@end

@implementation UISwitch (AutoTrackProperty)
-(NSString *)za_property_elementContent{
    return self.on ? @"checked" : @"unchecked";
}

@end

@implementation UIStepper (AutoTrackProperty)

- (NSString *)za_property_elementContent {
    return [NSString stringWithFormat:@"%g", self.value];
}

@end

@implementation UISegmentedControl (AutoTrackProperty)

- (BOOL)za_property_isIgnored {
    return super.za_property_isIgnored || self.selectedSegmentIndex == UISegmentedControlNoSegment;
}

- (NSString *)za_property_elementContent {
    return  self.selectedSegmentIndex == UISegmentedControlNoSegment ? [super za_property_elementContent] : [self titleForSegmentAtIndex:self.selectedSegmentIndex];
}

- (NSString *)za_property_elementPosition {
    return self.selectedSegmentIndex == UISegmentedControlNoSegment ? [super za_property_elementPosition] : [NSString stringWithFormat: @"%ld", (long)self.selectedSegmentIndex];
}

@end

@implementation UIPageControl (AutoTrackProperty)

- (NSString *)za_property_elementContent {
    return [NSString stringWithFormat:@"%ld", (long)self.currentPage];
}

@end

@implementation UISlider (AutoTrack)

- (BOOL)za_property_isIgnored {
    return self.tracking || super.za_property_isIgnored;
}

- (NSString *)za_property_elementContent {
    return [NSString stringWithFormat:@"%f", self.value];
}

@end

#pragma mark - Cell

@implementation UITableViewCell (AutoTrackProperty)

-(NSString *)za_property_elementPositionWithIndexPath:(NSIndexPath *)indexPath{
    return [NSString stringWithFormat: @"%ld:%ld", (long)indexPath.section, (long)indexPath.row];
}




@end

@implementation UICollectionViewCell (AutoTrackProperty)

- (NSString *)za_property_elementPositionWithIndexPath:(NSIndexPath *)indexPath {
    return [NSString stringWithFormat: @"%ld:%ld", (long)indexPath.section, (long)indexPath.item];
}
 
@end
