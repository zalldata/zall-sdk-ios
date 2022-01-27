//
// UIView+ZAVisualProperties.m
// ZallDataSDK
//
// Created by guo on 2021/1/6.
// Copyright © 2021 Zall Data Co., Ltd. All rights reserved.
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

#import "UIView+ZAVisualProperties.h"
#import "ZAVisualizedManager.h"
#import <objc/runtime.h>
#import "UIView+ZAAdd.h"
#import "UIView+ZAProperty.h"


static void *const kZAViewNodePropertyName = (void *)&kZAViewNodePropertyName;

#pragma mark -
@implementation UIView (ZAVisualProperties)

- (void)zalldata_visualize_didMoveToSuperview {
    [self zalldata_visualize_didMoveToSuperview];

    [ZAVisualizedManager.defaultManager.visualPropertiesTracker didMoveToSuperviewWithView:self];
}

- (void)zalldata_visualize_didMoveToWindow {
    [self zalldata_visualize_didMoveToWindow];

    [ZAVisualizedManager.defaultManager.visualPropertiesTracker didMoveToWindowWithView:self];
}

- (void)zalldata_visualize_didAddSubview:(UIView *)subview {
    [self zalldata_visualize_didAddSubview:subview];

    [ZAVisualizedManager.defaultManager.visualPropertiesTracker didAddSubview:subview];
}

- (void)zalldata_visualize_bringSubviewToFront:(UIView *)view {
    [self zalldata_visualize_bringSubviewToFront:view];
    if (view.zalldata_viewNode) {
        // 移动节点
        [self.zalldata_viewNode.subNodes removeObject:view.zalldata_viewNode];
        [self.zalldata_viewNode.subNodes addObject:view.zalldata_viewNode];
        
        // 兄弟节点刷新 Index
        [view.zalldata_viewNode refreshBrotherNodeIndex];
    }
}

- (void)zalldata_visualize_sendSubviewToBack:(UIView *)view {
    [self zalldata_visualize_sendSubviewToBack:view];
    if (view.zalldata_viewNode) {
        // 移动节点
        [self.zalldata_viewNode.subNodes removeObject:view.zalldata_viewNode];
        [self.zalldata_viewNode.subNodes insertObject:view.zalldata_viewNode atIndex:0];
        
        // 兄弟节点刷新 Index
        [view.zalldata_viewNode refreshBrotherNodeIndex];
    }
}

- (void)setZalldata_viewNode:(ZAViewNode *)zalldata_viewNode {
    objc_setAssociatedObject(self, kZAViewNodePropertyName, zalldata_viewNode, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (ZAViewNode *)zalldata_viewNode {
    // 自定义属性被关闭，就不再操作 viewNode
    if (!ZAVisualizedManager.defaultManager.visualPropertiesTracker) {
        return nil;
    }
    return objc_getAssociatedObject(self, kZAViewNodePropertyName);
}

/// 刷新节点位置信息
- (void)zalldata_refreshIndex {
    if (self.zalldata_viewNode) {
        [self.zalldata_viewNode refreshIndex];
    }
}

@end

@implementation UITableViewCell(ZAVisualProperties)

- (void)zalldata_visualize_prepareForReuse {
    [self zalldata_visualize_prepareForReuse];

    // 重用后更新 indexPath
    [self zalldata_refreshIndex];
}

@end

@implementation UICollectionViewCell(ZAVisualProperties)

- (void)zalldata_visualize_prepareForReuse {
    [self zalldata_visualize_prepareForReuse];

    // 重用后更新 indexPath
    [self zalldata_refreshIndex];
}

@end


@implementation UITableViewHeaderFooterView(ZAVisualProperties)

- (void)zalldata_visualize_prepareForReuse {
    [self zalldata_visualize_prepareForReuse];

    // 重用后更新 index
    [self zalldata_refreshIndex];
}

@end

@implementation UIWindow(ZAVisualProperties)
- (void)zalldata_visualize_becomeKeyWindow {
    [self zalldata_visualize_becomeKeyWindow];

    [ZAVisualizedManager.defaultManager.visualPropertiesTracker becomeKeyWindow:self];
}

@end


@implementation UITabBar(ZAVisualProperties)
- (void)zalldata_visualize_setSelectedItem:(UITabBarItem *)selectedItem {
    BOOL isSwitchTab = self.selectedItem == selectedItem;
    [self zalldata_visualize_setSelectedItem:selectedItem];

    // 当前已经是选中状态，即未切换 tab 修改页面，不需更新
    if (!isSwitchTab) {
        return;
    }
    if (!ZAVisualizedManager.defaultManager.visualPropertiesTracker) {
        return;
    }

    ZAViewNode *tabBarNode = self.zalldata_viewNode;
    NSString *itemIndex = [NSString stringWithFormat:@"%lu", (unsigned long)[self.items indexOfObject:selectedItem]];
    for (ZAViewNode *node in tabBarNode.subNodes) {
        // 只需更新切换 item 对应 node 页面名称即可
        if ([node isKindOfClass:ZATabBarButtonNode.class] && [node.elementPosition isEqualToString:itemIndex]) {
            // 共用自定义属性查询队列，从而保证更新页面信息后，再进行属性元素遍历
            dispatch_async(ZAVisualizedManager.defaultManager.visualPropertiesTracker.serialQueue, ^{
                [node refreshSubNodeScreenName];
            });
        }
    }
}

@end

#pragma mark -
@implementation UIView (PropertiesContent)

- (NSString *)zalldata_propertyContent {
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
    if ([self za_isKindOfRNView]) { // RN 元素，https://reactnative.dev
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

    if ([[self nextResponder] isKindOfClass:UITextField.class] && ![self isKindOfClass:UIButton.class]) {
        /* 兼容输入框的元素采集
         UITextField 本身是一个容器，包括 UITextField 的元素内容，文字是直接渲染到 view 的
         层级结构如下
         UITextField
            _UITextFieldRoundedRectBackgroundViewNeue
            UIFieldEditor（UIScrollView 的子类，只有编辑状态才包含此层）
                _UITextFieldCanvasView 或 _UISearchTextFieldCanvasView (UIView 的子类)
            _UITextFieldClearButton (可能存在)
         */
        UITextField *textField = (UITextField *)[self nextResponder];
        return [textField zalldata_propertyContent];
    }
    if ([NSStringFromClass(self.class) isEqualToString:@"_UITextFieldCanvasView"] || [NSStringFromClass(self.class) isEqualToString:@"_UISearchTextFieldCanvasView"]) {
        
        UITextField *textField = (UITextField *)[self nextResponder];
        do {
            if ([textField isKindOfClass:UITextField.class]) {
                return [textField zalldata_propertyContent];
            }
        } while ((textField = (UITextField *)[textField nextResponder]));
        
        return nil;
    }

    NSMutableArray<NSString *> *elementContentArray = [NSMutableArray array];
    for (UIView *subview in self.subviews) {
        // 忽略隐藏控件
        if (subview.isHidden || subview.za_viewPropertyIgnore) {
            continue;
        }
        NSString *temp = subview.zalldata_propertyContent;
        if (temp.length > 0) {
            [elementContentArray addObject:temp];
        }
    }
    if (elementContentArray.count > 0) {
        return [elementContentArray componentsJoinedByString:@"-"];
    }
    
    return nil;
}

@end

@implementation UILabel (PropertiesContent)

- (NSString *)zalldata_propertyContent {
    return self.text ?: super.zalldata_propertyContent;
}

@end

@implementation UIImageView (PropertiesContent)

- (NSString *)zalldata_propertyContent {
    NSString *imageName = self.image.za_imageName;
    if (imageName.length > 0) {
        return [NSString stringWithFormat:@"%@", imageName];
    }
    return super.zalldata_propertyContent;
}

@end


@implementation UITextField (PropertiesContent)

- (NSString *)zalldata_propertyContent {
    if (self.text) {
        return self.text;
    } else if (self.placeholder) {
        return self.placeholder;
    }
    return super.zalldata_propertyContent;
}

@end

@implementation UITextView (PropertiesContent)

- (NSString *)zalldata_propertyContent {
    return self.text ?: super.zalldata_propertyContent;
}

@end

@implementation UISearchBar (PropertiesContent)

- (NSString *)zalldata_propertyContent {
    return self.text ?: super.zalldata_propertyContent;
}

@end

#pragma mark - UIControl

@implementation UIButton (PropertiesContent)

- (NSString *)zalldata_propertyContent {
    NSString *text = self.titleLabel.text;
    if (!text) {
        text = super.zalldata_propertyContent;
    }
    return text;
}

@end

@implementation UISwitch (PropertiesContent)

- (NSString *)zalldata_propertyContent {
    return self.on ? @"checked" : @"unchecked";
}

@end

@implementation UIStepper (PropertiesContent)

- (NSString *)zalldata_propertyContent {
    return [NSString stringWithFormat:@"%g", self.value];
}

@end

@implementation UISegmentedControl (PropertiesContent)

- (NSString *)zalldata_propertyContent {
    return  self.selectedSegmentIndex == UISegmentedControlNoSegment ? [super zalldata_propertyContent] : [self titleForSegmentAtIndex:self.selectedSegmentIndex];
}

@end

@implementation UIPageControl (PropertiesContent)

- (NSString *)zalldata_propertyContent {
    return [NSString stringWithFormat:@"%ld", (long)self.currentPage];
}

@end

@implementation UISlider (PropertiesContent)

- (NSString *)zalldata_propertyContent {
    return [NSString stringWithFormat:@"%f", self.value];
}

@end
