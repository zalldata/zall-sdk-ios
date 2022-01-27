//
// ZAUtilCheck.m
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

#import "ZAUtilCheck.h"
#import "ZAConstantsDefin.h"
#import "ZALog.h"

/// Foundation Class Type
typedef NS_ENUM (NSUInteger, ZAEncodingNSType) {
    ZAEncodingNSTypeNSUnknown = 0,
    ZAEncodingNSTypeNSString,
    ZAEncodingNSTypeNSMutableString,
    ZAEncodingNSTypeNSValue,
    ZAEncodingNSTypeNSNumber,
    ZAEncodingNSTypeNSDecimalNumber,
    ZAEncodingNSTypeNSData,
    ZAEncodingNSTypeNSMutableData,
    ZAEncodingNSTypeNSDate,
    ZAEncodingNSTypeNSURL,
    ZAEncodingNSTypeNSArray,
    ZAEncodingNSTypeNSMutableArray,
    ZAEncodingNSTypeNSDictionary,
    ZAEncodingNSTypeNSMutableDictionary,
    ZAEncodingNSTypeNSSet,
    ZAEncodingNSTypeNSMutableSet,
    ZAEncodingNSTypeNSNull,
};

/// Get the Foundation class type from property info.
static inline ZAEncodingNSType ZAClassGetNSType(id cls) {
    if (!cls) return ZAEncodingNSTypeNSUnknown;
    if ([cls isKindOfClass:[NSMutableString class]]) return ZAEncodingNSTypeNSMutableString;
    if ([cls isKindOfClass:[NSString class]]) return ZAEncodingNSTypeNSString;
    if ([cls isKindOfClass:[NSDecimalNumber class]]) return ZAEncodingNSTypeNSDecimalNumber;
    if ([cls isKindOfClass:[NSNumber class]]) return ZAEncodingNSTypeNSNumber;
    if ([cls isKindOfClass:[NSValue class]]) return ZAEncodingNSTypeNSValue;
    if ([cls isKindOfClass:[NSMutableData class]]) return ZAEncodingNSTypeNSMutableData;
    if ([cls isKindOfClass:[NSData class]]) return ZAEncodingNSTypeNSData;
    if ([cls isKindOfClass:[NSDate class]]) return ZAEncodingNSTypeNSDate;
    if ([cls isKindOfClass:[NSURL class]]) return ZAEncodingNSTypeNSURL;
    if ([cls isKindOfClass:[NSMutableArray class]]) return ZAEncodingNSTypeNSMutableArray;
    if ([cls isKindOfClass:[NSArray class]]) return ZAEncodingNSTypeNSArray;
    if ([cls isKindOfClass:[NSMutableDictionary class]]) return ZAEncodingNSTypeNSMutableDictionary;
    if ([cls isKindOfClass:[NSDictionary class]]) return ZAEncodingNSTypeNSDictionary;
    if ([cls isKindOfClass:[NSMutableSet class]]) return ZAEncodingNSTypeNSMutableSet;
    if ([cls isKindOfClass:[NSSet class]]) return ZAEncodingNSTypeNSSet;
    if ([cls isKindOfClass:[NSNull class]]) return ZAEncodingNSTypeNSNull;

    return ZAEncodingNSTypeNSUnknown;
}

bool za_check_empty(id object){
    if (!object) {
        return true;
    }
    if ([object isKindOfClass:NSObject.class]) {
        return false;
    }
    return true;
}
void za_check_block(void (^blcok)(void)){
    if (blcok) {
        blcok();
    }
}
bool za_check_empty_class(id object,Class aName){
    if (!object) {
        return true;
    }
    if (!aName && ![object isKindOfClass:aName]) {
        return true;
    }
    if ([object isKindOfClass:NSData.class] || [object isKindOfClass:NSString.class]) {
        return [object length] == 0;
    }
    if ([object isKindOfClass:NSDictionary.class] || [object isKindOfClass:NSArray.class]) {
        return [object count] == 0;
    }
    
    return false;
}
bool za_check_empty_data(id object){
    
    return za_check_empty_class(object, NSData.class);
}
bool za_check_empty_string(id object){
    
    return za_check_empty_class(object, NSString.class);
}
bool za_check_empty_dict(id dict){
    
    return za_check_empty_class(dict, NSDictionary.class);
}
bool za_check_empty_array(id array){
    return za_check_empty_class(array, NSArray.class);
}

 

@implementation ZAUtilCheck


+ (NSError * )zaCheckKey:(NSString *)key{
    NSError *error = nil;
    if (za_check_empty_string(key)) {
        error = ZAPropertyError(ZACheckdatorErrorEmpty, @"属性键或事件名称为空或者类型不匹配");
        return error;
    }
     
    error = [self reservedKeywordCheckForObject:key];
    if (error) {
        return error;
    }
    
    
    if (key.length > kZAEventNameMaxLength) {
        error = ZAPropertyError(ZACheckdatorErrorOverflow, @"属性键或事件名称 %@ 长度大于 %ld", key, kZAEventNameMaxLength);
        return error;
    }
    return error;
}

+ (NSError *)reservedKeywordCheckForObject:(NSString *)object{
    static NSRegularExpression *regexForValidKey;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regexForValidKey = [NSRegularExpression regularExpressionWithPattern:kZAProperNameValidateRegularExpression options:NSRegularExpressionCaseInsensitive error:nil];
    });
    NSError * error;
    if (!regexForValidKey) {
        error = ZAPropertyError(ZACheckdatorErrorRegexInit, @"属性键验证正则表达式初始化失败，请检查正则表达式的语法");
        return error;
    }

    // 属性名通过正则表达式匹配，比使用谓词效率更高
    NSRange range = NSMakeRange(0, object.length);
    if ([regexForValidKey numberOfMatchesInString:object options:0 range:range] < 1) {
        error = ZAPropertyError(ZACheckdatorErrorInvalid, @"属性键或事件名称: [%@] 验证失败 ", object);
        return error;
    }
    return error;
}

+ (id)zaCheckProperties:(id)properties{
    NSError *error= nil;
   
    switch (ZAClassGetNSType(properties)) {
        case ZAEncodingNSTypeNSString:
        case ZAEncodingNSTypeNSMutableString:{
            error = [self zaCheckKey:properties];
        }
            break;
        case ZAEncodingNSTypeNSNumber:
        case ZAEncodingNSTypeNSDecimalNumber:{
            if ([properties isEqualToNumber:NSDecimalNumber.notANumber] || [properties isEqualToNumber:@(INFINITY)]) {
                error = ZAPropertyError(ZACheckdatorErrorInvalid, @"无效类型");
            }
             
        }
            break;
        case ZAEncodingNSTypeNSSet:
        case ZAEncodingNSTypeNSMutableSet:
        case ZAEncodingNSTypeNSArray:
        case ZAEncodingNSTypeNSMutableArray:
        case ZAEncodingNSTypeNSDictionary:
        case ZAEncodingNSTypeNSMutableDictionary:{
            for (id element in properties) {
                error = [self zaCheckKey:element];
                if (error) {
                    return properties;
                }
            }
        }
            break;
        case ZAEncodingNSTypeNSDate:
        case ZAEncodingNSTypeNSNull:
            break;
        default:
            error = ZAPropertyError(ZACheckdatorErrorInvalid, @"无效类型");
            break;
    }
    if (!error) {
        return properties;
    }
    return nil;
}


+ (BOOL)zaCheckWithTarget:(id)target withProtocols:(NSArray <Protocol *>*)protocols withSelector:(SEL)selector, ...{
    if (!target) {
        return NO;
    }
    BOOL isVerify = NO;
    va_list args;
    va_start(args, selector);
    isVerify = [self zaCheckWithTarget:target withProtocols:protocols withVA_list:args withSelector:selector];
    va_end(args);
    
    return isVerify;
}
+ (BOOL)zaCheckWithTarget:(id)target withProtocols:(NSArray <Protocol *>*)protocols withVA_list:(va_list)args withSelector:(SEL)selector{
    if (!target || za_check_empty_array(protocols) || !args) {
        return NO;
    }
     
    for (Protocol *protocol in protocols) {
        if (![target conformsToProtocol:protocol]) {
            return NO;
        }
    }
    SEL arg = selector;
    do {
        if (![target respondsToSelector:arg]) {
            return NO;
        }
    } while ((arg = va_arg(args, SEL)));
  
    return YES;
}

+ (BOOL)zaCheckWithTarget:(id)target withProtocols:(NSArray <Protocol *>*)protocols withClass:(NSArray <Class>*)aClass withSelector:(SEL)selector, ...{
    BOOL isVerify = NO;
    for (Class cls in aClass) {
        if (![target isKindOfClass:cls]) {
            return isVerify;
        }
    }
    va_list args;
    va_start(args, selector);
    isVerify = [self zaCheckWithTarget:target withProtocols:protocols withVA_list:args withSelector:selector];
    va_end(args);
    
    return isVerify;
}




@end
