//
// ZAQuickUtil.h
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

#pragma mark - NSNotificationCenter
/// 快速创建通知
NS_INLINE NSNotificationCenter * za_quick_notification_center(void);

/// 添加通知
/// @param observer 消息服务着
/// @param aSelector 实现
/// @param aName 通知名称
/// @param anObject 数据传递
FOUNDATION_EXPORT void za_quick_add_observer(id observer,SEL aSelector,NSNotificationName __nullable aName,id __nullable anObject);

/// 发送通知
/// @param aName 通知名称
/// @param observer 消息服务着
/// @param anObject 数据传递
FOUNDATION_EXPORT void za_quick_post_observer(NSNotificationName aName,id __nullable observer, id __nullable anObject);

/// 主线程发送通知
/// @param aName 通知名称
/// @param observer 消息服务着
/// @param anObject 数据传递
FOUNDATION_EXPORT void za_quick_post_observer_mai_thread(NSNotificationName aName,id __nullable observer, id __nullable anObject);



#pragma mark - Queue
/// 是否在主队列/线程中。
inline bool dispatch_is_main_queue(void);

/// 构造方法调用
/// @param aClassName 类名
/// @param aSelector 方法名
id __nullable za_quick_get_method(NSString * aClassName,NSString * aSelector) OBJC_SWIFT_UNAVAILABLE("");
/// 构造方法调用
/// @param aObject 类
/// @param aSelector 方法名
id __nullable za_quick_get_class_method(id aObject,NSString * aSelector) OBJC_SWIFT_UNAVAILABLE("");

/// 主队列同步操作
/// @param dispatch_block 实现
void za_quick_dispatch_sync_on_main_queue(dispatch_block_t dispatch_block);

/// 主队列异步步操作
/// @param dispatch_block 实现
void za_quick_dispatch_async_on_main_queue(dispatch_block_t dispatch_block);


/// 异步自定义队列
/// @param queue 需要执行的队列
/// @param dispatch_block 执行代码块
void za_quick_dispatch_async_queue(dispatch_queue_t queue, dispatch_block_t dispatch_block);

/// 同步步自定义队列
/// @param queue 需要执行的队列
/// @param dispatch_block 执行代码块
void za_quick_dispatch_sync_safe_queue(dispatch_queue_t queue, dispatch_block_t dispatch_block);

/// 创建串行队列
/// @param queueName 队列名称
dispatch_queue_t za_quick_queue_serial_create(NSString * queueName);

/// 创建串行队列
/// @param queueName 队列名称
dispatch_queue_t za_quick_queue_serial_create_char(const char * queueName);

/// 当前队列校验,是否是同一个队列
/// @param queue 队列名称
bool za_quick_queue_current_serial(dispatch_queue_t queue);


#pragma mark - NSUserDefaults

NS_INLINE NSUserDefaults * za_quick_user_defaults(void){
    return [NSUserDefaults standardUserDefaults];
}

#pragma mark - Application
/// 获取到Application
id __nullable za_quick_shared_application(void);

/// SceneDelegate 是否存在.是否大于iOS13
bool za_quick_sceneDelegate(void);

/// 获取到App的版本
id za_quick_app_version(void);

/// 是否是扩展App
bool za_quick_app_extension(void);

/// 当前系统时间
long long za_current_system_time(void);
/// 当前时间
long long za_current_time(void);
/// 是否开启加密
bool za_quick_enableEncrypt(void);
/// 安全字典
id za_quick_safe_dict(id dict);
/// 保留的属性
NSSet* zalldata_reserved_properties(void);


/// 生成hashcode
/// @param aName 字符串
/// @return 返回hashCode
int za_string_generate_hashcode(NSString * aName);



@interface ZAQuickUtil : NSObject

#pragma mark - dateFormatter
/// 设置dateFormatter 默认:yyyy-MM-dd HH:mm:ss.SSS
+ (NSDateFormatter *)zaDateFormatterFromString:(NSString  * _Nullable  )string;

/// 返回yyyy-MM-dd
+ (NSDateFormatter *)zaDateFormatter;

#pragma mark - Data
/// 返回压缩数据
+ (NSData *)gzipDeflateWith:(NSData *)data;
/// 返回字符串hash
+ (NSString *)hashStringWithData:(NSData *)data;

#pragma mark - BundlePlist
+ (NSString*)zaJsonPathBundleWithName:(NSString *)aName;

/// 返回对应文件数据
+ (NSDictionary *)zaBudleWithJsonName:(NSString *)aName;

#pragma mark - Modules
/// 是否实现了所有列出来的函数
+ (BOOL)zaGetIsProtocolWithObject:(id)object withMethods:(NSArray<NSString *>*)methods;
/// 获取Modules
+ (NSDictionary *)zaGetModulesClassWithProtocols;
/// 返回ModulManager
+ (nullable id)zaGenerateModulManagerWithName:(NSString *)aName;
/// 返回UserAgent
+ (nullable id)zaGetUserAgent;
/// 保存UserAgent
+ (void)zaSaveUserAgent:(NSString *)userAgent;


#pragma mark - AppInfo
/// 获取AppName
+ (NSString *)zaGetAppName;
/// Identifier
+ (NSString *)zaGetAppIdentifier;
/// ShortVersion
+ (NSString *)zaGetAppShortVersion;
/// 获取电信公司名称
+ (NSString *)zaGetTelecomCompanyName;
/// 获取设备架构
+ (NSString *)zaGetDeviceModelArchitecture;
#pragma mark - Identifier
+ (NSString *)idfa;
+ (NSString *)idfv;
+ (NSString *)hardwareID;





@end

NS_ASSUME_NONNULL_END
