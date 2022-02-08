//
// ZAAlertViewController.h
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

 

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ZAAlertActionStyle) {
    ZAAlertActionStyleDefault,
    ZAAlertActionStyleCancel,
    ZAAlertActionStyleDestructive
};

typedef NS_ENUM(NSUInteger, ZAAlertControllerStyle) {
    ZAAlertControllerStyleActionSheet = 0,
    ZAAlertControllerStyleAlert
};

@interface ZAAlertAction : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic) ZAAlertActionStyle style;
@property (nonatomic, copy) void (^handler)(ZAAlertAction *);

@property (nonatomic, readonly) NSInteger tag;

+ (instancetype)actionWithTitle:(nullable NSString *)title style:(ZAAlertActionStyle)style handler:(void (^ __nullable)(ZAAlertAction *))handler;

@end

@interface ZAAlertViewController : UIViewController
/**
 ZAAlertController 初始化， 

 @param title 标题
 @param message 提示信息
 @param preferredStyle 弹框类型
 @return ZAAlertController
 */
- (instancetype)initWithTitle:(nullable NSString *)title message:(nullable NSString *)message preferredStyle:(ZAAlertControllerStyle)preferredStyle;


/**
 添加一个 Action

 @param title Action 显示的 title
 @param style Action 的类型
 @param handler 回调处理方法，带有这个 Action 本身参数
 */
- (void)addActionWithTitle:(NSString *_Nullable)title style:(ZAAlertActionStyle)style handler:(void (^ __nullable)(ZAAlertAction *))handler;


/**
 显示 ZAAlertController
 */
- (void)show;


@end

NS_ASSUME_NONNULL_END
