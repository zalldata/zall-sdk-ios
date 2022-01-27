//
// ZAUtilCheck.h
// ZallDataSDK
//
// Created by guo on 2021/12/28.
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/// 校验错误码
typedef NS_ENUM(NSUInteger, ZACheckdatorError) {
    /// 为nil
    ZACheckdatorErrorNil = 20001,
    /// 非字符串
    ZACheckdatorErrorNotString,
    /// 为空
    ZACheckdatorErrorEmpty,
    /// 匹配失败
    ZACheckdatorErrorRegexInit,
    /// 无效
    ZACheckdatorErrorInvalid,
    /// 溢出
    ZACheckdatorErrorOverflow,
};


/// 验证对象是否为空
/// @param object id 类型
bool za_check_empty(id object);

/// 校验Block
/// 校验block并调用
void za_check_block(void (^blcok)(void));

/// 空对象校验or子类校验
/// @param object 子类对象or校验对象
/// @param aName 父类类型
bool za_check_empty_class(id object,Class aName);

/// 验证Data是否为空
/// @param object 目标Data
bool za_check_empty_data(id object);
 

/// 验证NSString是否为空
/// @param object 目标字符
bool za_check_empty_string(id object);

/// 验证dict
/// @param dict 目标字典
bool za_check_empty_dict(id dict);

/// 验证数组是否为空
/// @param array 目标数组
bool za_check_empty_array(id array);



/// 检验工具
@interface ZAUtilCheck : NSObject

/// 校验事件名或参数名是否有效
/// @param key key
+ (NSError *)zaCheckKey:(NSString *)key;

/// 校验Properties
/// @param properties 需要验证的propertie
+ (id)zaCheckProperties:(id)properties;

/// 验证协议方法是否包含
/// @param target 目标对象
/// @param protocols 协议组
/// @param selector 方法组
+ (BOOL)zaCheckWithTarget:(id)target withProtocols:(NSArray <Protocol *>*)protocols withSelector:(SEL)selector, ...;

/// 验证协议方法是否包含
/// @param target 目标对象
/// @param protocols 协议组
/// @param args 方法组
+ (BOOL)zaCheckWithTarget:(id)target withProtocols:(NSArray <Protocol *>*)protocols withVA_list:(va_list)args withSelector:(SEL)selector;

/// 验证协议方法是否包含 是否属于子类
/// @param target 目标对象
/// @param protocols 协议组
/// @param aClass 父类组
/// @param selector 方法组
+ (BOOL)zaCheckWithTarget:(id)target withProtocols:(NSArray <Protocol *>*)protocols withClass:(NSArray <Class>*)aClass withSelector:(SEL)selector, ...;




@end

NS_ASSUME_NONNULL_END
