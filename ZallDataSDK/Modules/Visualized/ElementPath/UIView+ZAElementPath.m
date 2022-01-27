//
// UIView+ZAElementPath.m
// ZallDataSDK
//
// Created by guo on 2020/3/6.
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

#import <objc/runtime.h>
#import "UIView+ZAElementPath.h"
#import "UIViewController+AutoTrack.h"
#import "UIViewController+ZAElementPath.h"
#import "ZAVisualizedUtils.h"
#import "UIView+ZAAdd.h"
#import "UIView+AutoTrackProperty.h"
#import "ZAViewElementInfoFactory.h"
#import "ZAConstantsDefin.h"
#import "ZAAutoTrackProperty.h"

typedef BOOL (*ZAClickableImplementation)(id, SEL, UIView *);


static void *const kZAIsDisableRNSubviewsInteractivePropertyName = (void *)&kZAIsDisableRNSubviewsInteractivePropertyName;

#pragma mark - UIView
@implementation UIView (ZAElementPath)

// 判断一个 view 是否显示
- (BOOL)zalldata_isVisible {
    /* 忽略部分 view
     _UIAlertControllerTextFieldViewCollectionCell，包含 UIAlertController 中输入框，忽略采集
     */
    if ([NSStringFromClass(self.class) isEqualToString:@"_UIAlertControllerTextFieldViewCollectionCell"]) {
        return NO;
    }
    /* 特殊场景兼容
     controller1.vew 上直接添加 controller2.view，在 controller2 添加 UITabBarController 或 UINavigationController 作为 childViewController；
     此时如果 UITabBarController 或 UINavigationController 使用 presentViewController 弹出页面，则 UITabBarController.view (即为 UILayoutContainerView) 可能未 hidden，为了可以通过 UILayoutContainerView 找到 UITabBarController 的子元素，则这里特殊处理。
     */
    if ([NSStringFromClass(self.class) isEqualToString:@"UILayoutContainerView"] && [self.nextResponder isKindOfClass:UIViewController.class]) {
        UIViewController *controller = (UIViewController *)[self nextResponder];
        if (controller.presentedViewController) {
            return YES;
        }
    }

    if (!(self.window && self.superview) || ![ZAVisualizedUtils isVisibleForView:self]) {
        return NO;
    }
    // 计算 view 在 keyWindow 上的坐标
    CGRect rect = [self convertRect:self.bounds toView:nil];
    // 若 size 为 CGrectZero
    // 部分 view 设置宽高为 0，但是子视图可见，取消 CGRectIsEmpty(rect) 判断
    if (CGRectIsNull(rect) || CGSizeEqualToSize(rect.size, CGSizeZero)) {
        return NO;
    }

    // RN 项目，view 覆盖层次比较多，被覆盖元素，可以直接屏蔽，防止被覆盖元素可圈选
    BOOL isRNView = [self za_isKindOfRNView];
    if (isRNView && [ZAVisualizedUtils isCoveredForView:self]) {
        return NO;
    }

    return YES;
}

/// 判断 ReactNative 元素是否可点击
- (BOOL)zalldata_clickableForRNView {
    // RN 可点击元素的区分
    Class managerClass = NSClassFromString(@"ZAReactNativeManager");
    SEL sharedInstanceSEL = NSSelectorFromString(@"sharedInstance");
    if (managerClass && [managerClass respondsToSelector:sharedInstanceSEL]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        id manager = [managerClass performSelector:sharedInstanceSEL];
#pragma clang diagnostic pop
        SEL clickableSEL = NSSelectorFromString(@"clickableForView:");
        IMP clickableImp = [manager methodForSelector:clickableSEL];
        if (clickableImp) {
            return ((ZAClickableImplementation)clickableImp)(manager, clickableSEL, self);
        }
    }
    return NO;
}

/// 解析 ReactNative 元素页面信息
- (NSDictionary *)zalldata_RNElementScreenProperties {
    SEL screenPropertiesSEL = NSSelectorFromString(@"za_reactnative_screenProperties");
    // 获取 RN 元素所在页面信息
    if ([self respondsToSelector:screenPropertiesSEL]) {
        /* 处理说明
         在 RN 项目中，如果当前页面为 RN 页面，页面名称为 "Home"，如果弹出某些页面，其实是 Native 的自定义 UIViewController（比如 RCTModalHostViewController），会触发 Native 的 $AppViewScreen 事件。
         弹出页面的上的元素，依然为 RN 元素。按照目前 RN 插件的逻辑，这些元素触发 $AppClick 全埋点中的 $screen_name 为 "Home"。
         为了确保可视化全埋点上传页面信息中可点击元素获取页面名称（screenName）和 $AppClick 全埋点中的 $screen_name 保持一致，事件正确匹配。所以针对 RN 针对可点击元素，使用扩展属性绑定元素所在页面信息。
         详见 RNZallAnalyticsModule 实现：https://github.com/zalldata/react-native-zall-analytics/tree/master/ios
         */
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        NSDictionary *screenProperties = (NSDictionary *)[self performSelector:screenPropertiesSEL];
        if (screenProperties) {
            return screenProperties;
        }
        #pragma clang diagnostic pop
    }
        // 获取 RN 页面信息
    return [ZAVisualizedUtils currentRNScreenVisualizeProperties];
}

// 判断一个 view 是否会触发全埋点事件
- (BOOL)zalldata_isAutoTrackAppClick {
    // 判断是否被覆盖
    if ([ZAVisualizedUtils isCoveredForView:self]) {
        return NO;
    }
    
    // RN 已禁用了子视图交互
    if (![ZAVisualizedUtils isInteractiveEnabledRNView:self]) {
        return NO;
    }
    
    // UISegmentedControl 嵌套 UISegment 作为选项单元格，特殊处理
    if ([NSStringFromClass(self.class) isEqualToString:@"UISegment"]) {
        UISegmentedControl *segmentedControl = (UISegmentedControl *)[self superview];
        if (![segmentedControl isKindOfClass:UISegmentedControl.class]) {
            return NO;
        }
        // 可能是 RN 框架 中 RCTSegmentedControl 内嵌 UISegment，再执行一次 RN 的可点击判断
        BOOL clickable = [ZAVisualizedUtils isAutoTrackAppClickWithControl:segmentedControl];
        if (clickable){
            return YES;
        }
    }

    if ([self zalldata_clickableForRNView]) {
        return YES;
    }

    if ([self isKindOfClass:UIControl.class]) {
        // UISegmentedControl 高亮渲染内部嵌套的 UISegment
        if ([self isKindOfClass:UISegmentedControl.class]) {
            return NO;
        }

        // 部分控件，响应链中不采集 $AppClick 事件
        if ([self isKindOfClass:UITextField.class]) {
            return NO;
        }

        UIControl *control = (UIControl *)self;
        if ([ZAVisualizedUtils isAutoTrackAppClickWithControl:control]) {
            return YES;
        }
    } else if ([self isKindOfClass:UITableViewCell.class]) {
        UITableView *tableView = (UITableView *)[self superview];
        do {
            if ([tableView isKindOfClass:UITableView.class]) {
                if (tableView.delegate && [tableView.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
                    return YES;
                }
            }
        } while ((tableView = (UITableView *)[tableView superview]));
    } else if ([self isKindOfClass:UICollectionViewCell.class]) {
        UICollectionView *collectionView = (UICollectionView *)[self superview];
        if ([collectionView isKindOfClass:UICollectionView.class]) {
            if (collectionView.delegate && [collectionView.delegate respondsToSelector:@selector(collectionView:didSelectItemAtIndexPath:)]) {
                return YES;
            }
        }
    }
    
    ZAViewElementInfo *elementInfo = [ZAViewElementInfoFactory elementInfoWithView:self];
    return elementInfo.isVisualView;
}

#pragma mark ZAAutoTrackViewPathProperty
- (NSString *)zalldata_itemPath {
    /* 忽略路径
     UITableViewWrapperView 为 iOS11 以下 UITableView 与 cell 之间的 view
     _UITextFieldCanvasView 和 _UISearchBarFieldEditor 都是 UISearchBar 内部私有 view
     在输入状态下  ...UISearchBarTextField/_UISearchBarFieldEditor/_UITextFieldCanvasView/...
     非输入状态下 .../UISearchBarTextField/_UITextFieldCanvasView
     并且 _UITextFieldCanvasView 是个私有 view,无法获取元素内容(目前通过 nextResponder 获取 textField 采集内容)。方便路径统一，所以忽略 _UISearchBarFieldEditor 路径
     */
    if ([ZAVisualizedUtils isIgnoredItemPathWithView:self]) {
        return nil;
    }

    NSString *className = NSStringFromClass(self.class);
    NSInteger index = [ZAAutoTrackProperty itemIndexForResponder:self];
    if (index < -1) { // -2
        return className;
    }

    if (index < 0) { // -1
        index = 0;
    }
    return [NSString stringWithFormat:@"%@[%ld]", className, (long)index];
}

- (NSString *)zalldata_heatMapPath {
    /* 忽略路径
     UITableViewWrapperView 为 iOS11 以下 UITableView 与 cell 之间的 view
     */
    if ([NSStringFromClass(self.class) isEqualToString:@"UITableViewWrapperView"] || [NSStringFromClass(self.class) isEqualToString:@"UISegment"]) {
        return nil;
    }

    NSString *identifier = [ZAVisualizedUtils viewIdentifierForView:self];
    if (identifier) {
        return identifier;
    }
    return [ZAVisualizedUtils itemHeatMapPathForResponder:self];
}

- (NSString *)zalldata_similarPath {
    // 是否支持限定元素位置功能
    BOOL enableSupportSimilarPath = [NSStringFromClass(self.class) isEqualToString:@"UITabBarButton"];
    if (enableSupportSimilarPath && self.za_property_elementPosition) {
        return [NSString stringWithFormat:@"%@[-]",NSStringFromClass(self.class)];
    } else {
        return self.zalldata_itemPath;
    }
}

#pragma mark ZAVisualizedViewPathProperty
// 当前元素，前端是否渲染成可交互
- (BOOL)zalldata_enableAppClick {
    // 是否在屏幕显示
    // 是否触发 $AppClick 事件
    return self.zalldata_isVisible && self.zalldata_isAutoTrackAppClick;
}

- (NSString *)zalldata_elementValidContent {
    /*
     针对 RN 元素，上传页面信息中的元素内容，和 RN 插件触发全埋点一致，不遍历子视图元素内容
     获取 RN 元素自定义属性，会尝试遍历子视图
     */
    if ([self za_isKindOfRNView]) {
        return [self.accessibilityLabel stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    return self.za_property_elementContent;
}

/// 元素子视图
- (NSArray *)zalldata_subElements {
    //  部分元素，忽略子视图
    if ([ZAVisualizedUtils isIgnoreSubviewsWithView:self]) {
        return nil;
    }
    
    /* 特殊场景兼容
     controller1.vew 上直接添加 controller2.view，
     在 controller2 添加 UITabBarController 或 UINavigationController 作为 childViewController 场景兼容
     */
    if ([NSStringFromClass(self.class) isEqualToString:@"UILayoutContainerView"]) {
        if ([[self nextResponder] isKindOfClass:UIViewController.class]) {
            UIViewController *controller = (UIViewController *)[self nextResponder];
            return controller.zalldata_subElements;
        }
    }

    NSMutableArray *newSubViews = [NSMutableArray array];
    NSArray<UIView *>* subViews = self.subviews;
    // 针对 RCTView，获取按照 zIndex 排序后的子元素
    if ([ZAVisualizedUtils isKindOfRCTView:self]) {
        subViews = [ZAVisualizedUtils sortedRNSubviewsWithView:self];
    }
    for (UIView *view in subViews) {
        if (view.zalldata_isVisible) {
            [newSubViews addObject:view];
        }
    }
    return newSubViews;
}

- (NSString *)zalldata_elementPath {
    // 处理特殊控件
    // UISegmentedControl 嵌套 UISegment 作为选项单元格，特殊处理
    if ([NSStringFromClass(self.class) isEqualToString:@"UISegment"]) {
        UISegmentedControl *segmentedControl = (UISegmentedControl *)[self superview];
        if ([segmentedControl isKindOfClass:UISegmentedControl.class]) {
            return [ZAVisualizedUtils viewSimilarPathForView:segmentedControl atViewController:segmentedControl.za_property_viewController shouldSimilarPath:YES];
        }
    }
    // 支持自定义属性，可见元素均上传 elementPath
    return [ZAVisualizedUtils viewSimilarPathForView:self atViewController:self.za_property_viewController shouldSimilarPath:YES];
}

- (NSString *)zalldata_elementSelector {
    // 处理特殊控件
    // UISegmentedControl 嵌套 UISegment 作为选项单元格，特殊处理
    if ([NSStringFromClass(self.class) isEqualToString:@"UISegment"]) {
        UISegmentedControl *segmentedControl = (UISegmentedControl *)[self superview];
        if ([segmentedControl isKindOfClass:UISegmentedControl.class]) {
            /* 原始路径，都是类似以下结构：
             UINavigationController/AutoTrackViewController/UIView/UISegmentedControl[(jjf_varB='fac459bd36d8326d9140192c7900decaf3744f5e')]/UISegment[0]
             UISegment[0] 无法标识当前单元格当前显示的序号 index
             */
            NSString *elementSelector = [ZAVisualizedUtils viewPathForView:segmentedControl atViewController:segmentedControl.za_property_viewController];
            // 解析 UISegment 的显示序号 index
            NSString *postion = [self za_property_elementPosition];
            // 原始路径分割后的集合
            NSMutableArray <NSString *> *viewPaths = [[elementSelector componentsSeparatedByString:@"/"] mutableCopy];
            // 删除最后一个原始 UISegment 路径
            [viewPaths removeLastObject];
            // 添加使用位置拼接的正确路径
            [viewPaths addObject:[NSString stringWithFormat:@"UISegment[%@]", postion]];
            // 拼接完整路径信息
            NSString *newElementSelector = [viewPaths componentsJoinedByString:@"/"];
            return newElementSelector;
        }
    }
    if (self.zalldata_enableAppClick) {
        return [ZAVisualizedUtils viewPathForView:self atViewController:self.za_property_viewController];
    } else {
        return nil;
    }
}

- (BOOL)zalldata_isFromWeb {
    return NO;
}

- (BOOL)zalldata_isListView {
    // UISegmentedControl 嵌套 UISegment 作为选项单元格，特殊处理
    if ([NSStringFromClass(self.class) isEqualToString:@"UISegment"] || [NSStringFromClass(self.class) isEqualToString:@"UITabBarButton"]) {
        return YES;
    }
    return NO;
}

- (NSString *)zalldata_screenName {
    // 解析 ReactNative 元素页面名称
    if ([self za_isKindOfRNView]) {
        NSDictionary *screenProperties = [self zalldata_RNElementScreenProperties];
        // 如果 ReactNative 页面信息为空，则使用 Native 的
        NSString *screenName = screenProperties[kZAEventPropertyScreenName];
        if (screenName) {
            return screenName;
        }
    }

    // 解析 Native 元素页面信息
    if (self.za_property_viewController) {
        NSDictionary *autoTrackScreenProperties = [ZAAutoTrackProperty propertiesWithViewController:self.za_property_viewController];
        return autoTrackScreenProperties[kZAEventPropertyScreenName];
    }
    return nil;
}

- (NSString *)zalldata_title {
    // 处理 ReactNative 元素
    if ([self za_isKindOfRNView]) {
        NSDictionary *screenProperties = [self zalldata_RNElementScreenProperties];
        // 如果 ReactNative 的 screenName 不存在，则判断页面信息不存在，即使用 Native 逻辑
        if (screenProperties[kZAEventPropertyScreenName]) {
            return screenProperties[kZAEventPropertyTitle];
        }
    }

    // 处理 Native 元素
    if (self.za_property_viewController) {
        NSDictionary *autoTrackScreenProperties = [ZAAutoTrackProperty propertiesWithViewController:self.za_property_viewController];
        return autoTrackScreenProperties[kZAEventPropertyTitle];
    }
    return nil;
}

#pragma mark ZAVisualizedExtensionProperty
- (CGRect)zalldata_frame {
    CGRect showRect = [self convertRect:self.bounds toView:nil];
    if (self.superview) {
        // 计算可见区域
        CGRect visibleFrame = self.superview.zalldata_visibleFrame;
        return CGRectIntersection(showRect, visibleFrame);
    }
    return showRect;
}

- (CGRect)zalldata_visibleFrame {
    CGRect visibleFrame = [UIApplication sharedApplication].keyWindow.frame;
    if (self.superview) {
        CGRect superViewVisibleFrame = [self.superview zalldata_visibleFrame];
        visibleFrame = CGRectIntersection(visibleFrame, superViewVisibleFrame);
    }
    return visibleFrame;
}

- (BOOL)zalldata_isDisableRNSubviewsInteractive {
    return [objc_getAssociatedObject(self, kZAIsDisableRNSubviewsInteractivePropertyName) boolValue];
}

- (void)setZalldata_isDisableRNSubviewsInteractive:(BOOL)zalldata_isDisableRNSubviewsInteractive {
    objc_setAssociatedObject(self, kZAIsDisableRNSubviewsInteractivePropertyName, @(zalldata_isDisableRNSubviewsInteractive), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end


@implementation UIScrollView (ZAElementPath)

- (CGRect)zalldata_visibleFrame {
    CGRect showRect = [self convertRect:self.bounds toView:nil];
    if (self.superview) {
        /* UIScrollView 单独处理
         UIScrollView 上子元素超出父视图部分不可见。
         普通 UIView 超出父视图，依然显示，但是超出部分不可交互，除非实现 hitTest
         */
        CGRect superViewValidFrame = [self.superview zalldata_visibleFrame];
        showRect = CGRectIntersection(showRect, superViewValidFrame);
    }
    return showRect;
}

@end

@implementation WKWebView (ZAElementPath)

- (NSArray *)zalldata_subElements {
    NSArray *subElements = [ZAVisualizedUtils analysisWebElementWithWebView:self];
    if (subElements.count > 0) {
        return subElements;
    }
    return [super zalldata_subElements];
}

@end


@implementation UIWindow (ZAElementPath)

- (NSArray *)zalldata_subElements {
    if (!self.rootViewController) {
        return super.zalldata_subElements;
    }

    NSMutableArray *subElements = [NSMutableArray array];
    [subElements addObject:self.rootViewController];

    // 存在自定义弹框或浮层，位于 keyWindow
    NSArray <UIView *> *subviews = self.subviews;
    for (UIView *view in subviews) {
        if (view != self.rootViewController.view && view.zalldata_isVisible) {
            /*
             keyWindow 设置 rootViewController 后，视图层级为 UIWindow -> UITransitionView -> UIDropShadowView -> rootViewController.view
             */
            if ([NSStringFromClass(view.class) isEqualToString:@"UITransitionView"]) {
                continue;
            }
            [subElements addObject:view];

            CGRect rect = [view convertRect:view.bounds toView:nil];
            // 是否全屏
            BOOL isFullScreenShow = CGPointEqualToPoint(rect.origin, CGPointZero) && CGSizeEqualToSize(rect.size, self.bounds.size);
            // keyWindow 上存在全屏显示可交互的 view，此时 rootViewController 内元素不可交互
            if (isFullScreenShow && view.userInteractionEnabled) {
                [subElements removeObject:self.rootViewController];
            }
        }
    }
    return subElements;
}

@end

@implementation ZAWebElementView (ZAElementPath)

#pragma mark ZAVisualizedViewPathProperty
- (NSString *)zalldata_title {
    return self.title;
}

- (NSString *)zalldata_elementSelector {
    return self.elementSelector;
}

- (NSString *)zalldata_elementValidContent {
    return self.elementContent;
}

- (CGRect)zalldata_frame {
    return self.frame;
}

- (BOOL)zalldata_enableAppClick {
    return self.enableAppClick;
}

- (NSArray *)zalldata_subElements {
    if (self.jsSubviews.count > 0) {
        return self.jsSubviews;
    }
    return [super zalldata_subElements];
}

- (BOOL)zalldata_isFromWeb {
    return YES;
}

- (BOOL)zalldata_isListView {
    return self.isListView;
}

- (NSString *)zalldata_elementPath {
    return self.elementPath;
}

- (NSString *)zalldata_elementPosition {
    return self.elementPosition;
}

@end

#pragma mark - UIControl
@implementation UISwitch (ZAElementPath)

- (NSString *)zalldata_elementValidContent {
    return nil;
}

@end

@implementation UIStepper (ZAElementPath)

- (NSString *)zalldata_elementValidContent {
    return nil;
}

@end

@implementation UISegmentedControl (ZAElementPath)

- (NSString *)zalldata_itemPath {
    // 支持单个 UISegment 创建事件。UISegment 是 UIImageView 的私有子类，表示UISegmentedControl 单个选项的显示区域
    NSString *subPath = [NSString stringWithFormat:@"UISegment[%ld]", (long)self.selectedSegmentIndex];
    return [NSString stringWithFormat:@"%@/%@", super.zalldata_itemPath, subPath];
}

- (NSString *)zalldata_similarPath {
    return [NSString stringWithFormat:@"%@/UISegment[-]", super.zalldata_itemPath];
}

- (NSString *)zalldata_heatMapPath {
    NSString *subPath = [NSString stringWithFormat:@"UISegment[%ld]", (long)self.selectedSegmentIndex];
    return [NSString stringWithFormat:@"%@/%@", super.zalldata_heatMapPath, subPath];
}

@end

@implementation UISlider (ZAElementPath)

- (NSString *)zalldata_elementValidContent {
    return nil;
}

@end

@implementation UIPageControl (ZAElementPath)

- (NSString *)zalldata_elementValidContent {
    return nil;
}

@end


#pragma mark - TableView & Cell
@implementation UITableView (ZAElementPath)

- (NSArray *)zalldata_subElements {
    NSArray *subviews = self.subviews;
    NSMutableArray *newSubviews = [NSMutableArray array];
    NSArray *visibleCells = self.visibleCells;
    for (UIView *view in subviews) {
        if ([view isKindOfClass:UITableViewCell.class]) {
            if ([visibleCells containsObject:view] && view.zalldata_isVisible) {
                [newSubviews addObject:view];
            }
        } else if (view.zalldata_isVisible) {
            [newSubviews addObject:view];
        }
    }
    return newSubviews;
}

@end

@implementation UITableViewHeaderFooterView (ZAElementPath)

- (NSString *)zalldata_itemPath {
    UITableView *tableView = (UITableView *)self.superview;

    while (![tableView isKindOfClass:UITableView.class]) {
        tableView = (UITableView *)tableView.superview;
        if (!tableView) {
            return super.zalldata_itemPath;
        }
    }
    for (NSInteger i = 0; i < tableView.numberOfSections; i++) {
        if (self == [tableView headerViewForSection:i]) {
            return [NSString stringWithFormat:@"[SectionHeader][%ld]", (long)i];
        }
        if (self == [tableView footerViewForSection:i]) {
            return [NSString stringWithFormat:@"[SectionFooter][%ld]", (long)i];
        }
    }
    return super.zalldata_itemPath;
}

- (NSString *)zalldata_heatMapPath {
    UIView *currentTableView = self.superview;
    while (![currentTableView isKindOfClass:UITableView.class]) {
        currentTableView = currentTableView.superview;
        if (!currentTableView) {
            return super.zalldata_heatMapPath;
        }
    }

    UITableView *tableView = (UITableView *)currentTableView;
    for (NSInteger i = 0; i < tableView.numberOfSections; i++) {
        if (self == [tableView headerViewForSection:i]) {
            return [NSString stringWithFormat:@"[SectionHeader][%ld]", (long)i];
        }
        if (self == [tableView footerViewForSection:i]) {
            return [NSString stringWithFormat:@"[SectionFooter][%ld]", (long)i];
        }
    }
    return super.zalldata_heatMapPath;
}

@end


@implementation UICollectionView (ZAElementPath)

- (NSArray *)zalldata_subElements {
    NSArray *subviews = self.subviews;
    NSMutableArray *newSubviews = [NSMutableArray array];
    NSArray *visibleCells = self.visibleCells;
    for (UIView *view in subviews) {
        if ([view isKindOfClass:UICollectionViewCell.class]) {
            if ([visibleCells containsObject:view] && view.zalldata_isVisible) {
                [newSubviews addObject:view];
            }
        } else if (view.zalldata_isVisible) {
            [newSubviews addObject:view];
        }
    }
    return newSubviews;
}

@end

@implementation UITableViewCell (ZAElementPath)

- (NSIndexPath *)zalldata_IndexPath {
    UITableView *tableView = (UITableView *)[self superview];
    do {
        if ([tableView isKindOfClass:UITableView.class]) {
            NSIndexPath *indexPath = [tableView indexPathForCell:self];
            return indexPath;
        }
    } while ((tableView = (UITableView *)[tableView superview]));
    return nil;
}

#pragma mark ZAAutoTrackViewPathProperty

- (NSString *)zalldata_itemPath {
    NSIndexPath *indexPath = self.zalldata_IndexPath;
    if (indexPath) {
        return [self zalldata_itemPathWithIndexPath:indexPath];
    }
    return [super zalldata_itemPath];
}

- (NSString *)zalldata_similarPath {
    NSIndexPath *indexPath = self.zalldata_IndexPath;
    if (indexPath) {
        return [self zalldata_similarPathWithIndexPath:indexPath];
    }
    return self.zalldata_itemPath;
}

- (NSString *)zalldata_heatMapPath {
    NSIndexPath *indexPath = self.zalldata_IndexPath;
    if (indexPath) {
        return [self zalldata_itemPathWithIndexPath:indexPath];
    }
    return [super zalldata_heatMapPath];
}

- (NSString *)zalldata_itemPathWithIndexPath:(NSIndexPath *)indexPath {
    return [NSString stringWithFormat:@"%@[%ld][%ld]", NSStringFromClass(self.class), (long)indexPath.section, (long)indexPath.row];
}

- (NSString *)zalldata_similarPathWithIndexPath:(NSIndexPath *)indexPath {
    return [NSString stringWithFormat:@"%@[%ld][-]", NSStringFromClass(self.class), (long)indexPath.section];
}

#pragma mark ZAAutoTrackViewProperty
- (NSString *)zalldata_elementPosition {
    NSIndexPath *indexPath = self.zalldata_IndexPath;
    if (indexPath) {
        return [NSString stringWithFormat:@"%ld:%ld", (long)indexPath.section, (long)indexPath.row];
    }
    return nil;
}

- (BOOL)zalldata_isListView {
    return self.zalldata_elementPosition != nil;
}
@end


@implementation UICollectionViewCell (ZAElementPath)

- (NSIndexPath *)zalldata_IndexPath {
    UICollectionView *collectionView = (UICollectionView *)[self superview];
    if ([collectionView isKindOfClass:UICollectionView.class]) {
        NSIndexPath *indexPath = [collectionView indexPathForCell:self];
        return indexPath;
    }
    return nil;
}

#pragma mark ZAAutoTrackViewPathProperty
- (NSString *)zalldata_itemPath {
    NSIndexPath *indexPath = self.zalldata_IndexPath;
    if (indexPath) {
        return [self zalldata_itemPathWithIndexPath:indexPath];
    }
    return [super zalldata_itemPath];
}

- (NSString *)zalldata_similarPath {
    NSIndexPath *indexPath = self.zalldata_IndexPath;
    if (indexPath) {
        return [self zalldata_similarPathWithIndexPath:indexPath];
    } else {
        return super.zalldata_similarPath;
    }
}

- (NSString *)zalldata_heatMapPath {
    NSIndexPath *indexPath = self.zalldata_IndexPath;
    if (indexPath) {
        return [self zalldata_itemPathWithIndexPath:indexPath];
    }
    return [super zalldata_heatMapPath];
}

- (NSString *)zalldata_itemPathWithIndexPath:(NSIndexPath *)indexPath {
    return [NSString stringWithFormat:@"%@[%ld][%ld]", NSStringFromClass(self.class), (long)indexPath.section, (long)indexPath.item];
}

- (NSString *)zalldata_similarPathWithIndexPath:(NSIndexPath *)indexPath {
    ZAViewElementInfo *elementInfo = [ZAViewElementInfoFactory elementInfoWithView:self];
    if (!elementInfo.isSupportElementPosition) {
        return [self zalldata_itemPathWithIndexPath:indexPath];
    }
    return [NSString stringWithFormat:@"%@[%ld][-]", NSStringFromClass(self.class), (long)indexPath.section];
}

#pragma mark ZAAutoTrackViewProperty
- (NSString *)zalldata_elementPosition {
    ZAViewElementInfo *elementInfo = [ZAViewElementInfoFactory elementInfoWithView:self];
    if (!elementInfo.isSupportElementPosition) {
        return nil;
    }
    
    NSIndexPath *indexPath = self.zalldata_IndexPath;
    if (indexPath) {
        return [NSString stringWithFormat:@"%ld:%ld", (long)indexPath.section, (long)indexPath.item];
    }
    return nil;
}

- (BOOL)zalldata_isListView {
    return self.zalldata_elementPosition != nil;
}

@end
