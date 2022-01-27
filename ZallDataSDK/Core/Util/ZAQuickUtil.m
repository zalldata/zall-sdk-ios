//
// ZAQuickUtil.m
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

#import "ZAQuickUtil.h"
#include <pthread.h>
#import <objc/message.h>
#import "ZAUtilCheck.h"
#include <CommonCrypto/CommonCrypto.h>
#include <zlib.h>
#import <UIKit/UIKit.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#include <sys/sysctl.h>
#include <sys/utsname.h>
#import "ZAConstantsDefin.h"
#import "ZAJSONUtil.h"
#import "ZALog.h"
#include <dlfcn.h>
#include <mach-o/loader.h>
#include <mach-o/getsect.h>

#define retWithType(classType) (classType (*)(id, SEL))

NS_INLINE NSNotificationCenter * za_quick_notification_center(void){
    return [NSNotificationCenter defaultCenter];
}


FOUNDATION_EXPORT void za_quick_add_observer(id observer,SEL aSelector,NSNotificationName __nullable aName,id __nullable anObject){
    [za_quick_notification_center() addObserver:observer selector:aSelector name:aName object:anObject];
}
void za_quick_post_observer(NSNotificationName aName,id __nullable observer, id __nullable anObject){
    [za_quick_notification_center() postNotificationName:aName object:observer userInfo:anObject];
}
FOUNDATION_EXPORT void za_quick_post_observer_mai_thread(NSNotificationName aName,id __nullable observer, id __nullable anObject){
    za_quick_dispatch_async_on_main_queue(^{
        [za_quick_notification_center() postNotificationName:aName object:observer userInfo:anObject];
    });
    
    
}

id za_quick_get_method(NSString * aClassName,NSString * aSelector){
    Class class = NSClassFromString(aClassName);
    if (!class) {
        return nil;
    }
    return za_quick_get_class_method(class, aSelector);
}
id za_quick_get_class_method(id aObject,NSString * aSelector){
    if (!aObject) {
        return nil;
    }
    SEL sel = NSSelectorFromString(aSelector);
    if (!sel) {
        return nil;
    }
    
    if (![aObject respondsToSelector:sel]) {
        return nil;
    }
    
    NSMethodSignature* methodSig = [aObject methodSignatureForSelector:sel];
    if(methodSig == nil) {
        return nil;
    }
    const char* retType = [methodSig methodReturnType];
    switch (*retType) {
        case _C_ID:{
            return (retWithType(id)objc_msgSend)(aObject,sel);
        }
            break;
        case _C_CLASS:{
            return (retWithType(Class)objc_msgSend)(aObject,sel);
        }
            break;
        case _C_BOOL:{
            return @((retWithType(bool)objc_msgSend)(aObject,sel));
        }
            break;
        case _C_VOID:{
            (retWithType(void)objc_msgSend)(aObject,sel);
            return nil;
        }
            break;
            
        default:
            ZALogError(@"objc_msgSend error with %@ %@ %s",aObject,aSelector,retType);
            return nil;
            break;
    }
    
}
 
inline bool dispatch_is_main_queue(void){
    return pthread_main_np() != 0;
}

inline void za_quick_dispatch_sync_on_main_queue(dispatch_block_t dispatch_block){
    if (pthread_main_np()) {
        dispatch_block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), dispatch_block);
    }
}
inline void za_quick_dispatch_async_on_main_queue(dispatch_block_t dispatch_block){
    if (pthread_main_np()) {
        dispatch_block();
    } else {
        dispatch_async(dispatch_get_main_queue(), dispatch_block);
    }
}


inline void za_quick_dispatch_async_queue(dispatch_queue_t queue, dispatch_block_t dispatch_block){
    
    if (za_quick_queue_current_serial(queue)) {
        dispatch_block();
    }else{
        dispatch_async(queue, dispatch_block);
    }
}

inline void za_quick_dispatch_sync_safe_queue(dispatch_queue_t queue, dispatch_block_t dispatch_block){
    
    if (za_quick_queue_current_serial(queue)) {
        dispatch_block();
    }else{
        dispatch_sync(queue, dispatch_block);
    }
}

inline dispatch_queue_t za_quick_queue_serial_create(NSString * queueName){
    NSString* _queueName = [NSString stringWithFormat:@"com.zalldata.serial.%@",queueName];
    
    return za_quick_queue_serial_create_char([_queueName UTF8String]);
}
inline dispatch_queue_t za_quick_queue_serial_create_char(const char * queueName){
    return dispatch_queue_create(queueName, DISPATCH_QUEUE_SERIAL);
}

inline bool za_quick_queue_current_serial(dispatch_queue_t queue){
    return dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL) == dispatch_queue_get_label(queue);
}

id za_quick_shared_application(void){
    return za_quick_get_method(@"UIApplication", @"sharedApplication");
}

bool za_quick_sceneDelegate(void){
    Class class = NSClassFromString(@"SceneDelegate");
    BOOL isExistence = class ? true:false;
    if (@available(iOS 13.0, *)) {
        isExistence = true;
    }
    return isExistence;
}

id za_quick_app_version(void){
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

bool za_quick_app_extension(void){
    NSString *bundlePath = [[NSBundle mainBundle] executablePath];
    if (!bundlePath) {
        return NO;
    }
    return [bundlePath containsString:@".appex/"];
}
inline long long za_current_system_time(void){
    return NSProcessInfo.processInfo.systemUptime * 1000;
}

inline long long za_current_time(void){
    return [[NSDate date] timeIntervalSince1970] * 1000;
}
bool za_quick_enableEncrypt(void){
    id config = za_quick_get_method(@"ZAConfigOptions",@"sharedInstance");
    return za_quick_get_class_method(config, @"enableEncrypt");
}

id za_quick_safe_dict(id dict){
    return dict = dict?:@{};
}
NSSet* zalldata_reserved_properties() {
    return [NSSet setWithObjects:@"date", @"datetime", @"distinct_id", @"event", @"events", @"first_id", @"id", @"original_id", @"properties", @"second_id", @"time", @"user_id", @"users", nil];
}

int za_string_generate_hashcode(NSString * aName){
   
    int hash = 0;
    if (!aName) {
        return hash;
    }
    for (int i = 0; i<[aName length]; i++) {
        NSString *s = [aName substringWithRange:NSMakeRange(i, 1)];
        char *unicode = (char *)[s cStringUsingEncoding:NSUnicodeStringEncoding];
        int charactorUnicode = 0;

        size_t length = strnlen(unicode, 4);
        for (int n = 0; n < length; n ++) {
            charactorUnicode += (int)((unicode[n] & 0xff) << (n * sizeof(char) * 8));
        }
        hash = hash * 31 + charactorUnicode;
    }
    
    return hash;
}
NSArray<NSString *>* zaAppLoadReadConfigFromSection(const char *sectionName){
    
    #ifndef __LP64__
        const struct mach_header *mhp = NULL;
    #else
        const struct mach_header_64 *mhp = NULL;
    #endif
        
        NSMutableArray *configs = [NSMutableArray array];
        Dl_info info;
        if (mhp == NULL) {
            dladdr(zaAppLoadReadConfigFromSection, &info);
    #ifndef __LP64__
            mhp = (struct mach_header*)info.dli_fbase;
    #else
            mhp = (struct mach_header_64*)info.dli_fbase;
    #endif
        }
        
    #ifndef __LP64__
        unsigned long size = 0;
        uint32_t *memory = (uint32_t*)getsectiondata(mhp, SEG_DATA, sectionName, & size);
    #else /* defined(__LP64__) */
        unsigned long size = 0;
        uint64_t *memory = (uint64_t*)getsectiondata(mhp, SEG_DATA, sectionName, & size);
    #endif /* defined(__LP64__) */
    
    for(int idx = 0; idx < size/sizeof(void*); ++idx){
        char *string = (char*)memory[idx];
        
        NSString *str = [NSString stringWithUTF8String:string];
        if(!str)continue;
        
        if(str) [configs addObject:str];
    }
    
    return configs;
}
 

/// 扩展工具包
@implementation ZAQuickUtil

+ (NSDateFormatter *)zaDateFormatter{
    return [self zaDateFormatterFromString:@"yyyy-MM-dd"];
}

+ (NSDateFormatter *)zaDateFormatterFromString:(NSString *)string{
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
    });
    if (za_check_empty_string(string)) {
        string = @"yyyy-MM-dd HH:mm:ss.SSS";
    }
    [dateFormatter setDateFormat:string];
    return dateFormatter;
}

+ (NSData *)gzipDeflateWith:(NSData *)data{
    if ([data length] == 0) return data;
    
    z_stream strm;
    
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    strm.opaque = Z_NULL;
    strm.total_out = 0;
    strm.next_in = (Bytef *)[data bytes];
    strm.avail_in = (uInt)[data length];
    
    // Compresssion Levels:
    //   Z_NO_COMPRESSION
    //   Z_BEST_SPEED
    //   Z_BEST_COMPRESSION
    //   Z_DEFAULT_COMPRESSION
    
    if (deflateInit2(&strm, Z_DEFAULT_COMPRESSION, Z_DEFLATED, (15 + 16),
                     8, Z_DEFAULT_STRATEGY) != Z_OK)
        return nil;
    
    // 16K chunks for expansion
    NSMutableData *compressed = [NSMutableData dataWithLength:16384];
    
    do {
        if (strm.total_out >= [compressed length])
            [compressed increaseLengthBy:16384];
        
        strm.next_out = [compressed mutableBytes] + strm.total_out;
        strm.avail_out = (uInt)([compressed length] - strm.total_out);
        
        deflate(&strm, Z_FINISH);
    }
    while (strm.avail_out == 0);
    
    deflateEnd(&strm);
    
    [compressed setLength:strm.total_out];
    return [NSData dataWithData:compressed];
}

+ (NSString *)hashStringWithData:(NSData *)data {
    if (!data) {
        return nil;
    }
    NSString *base64String = [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
    NSUInteger hash = [base64String hash];
    return [NSString stringWithFormat:@"%ld",hash];
}
+ (NSString*)zaJsonPathBundleWithName:(NSString *)aName{
    NSBundle * zallBundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"ZallDataSDK" ofType:@"framework" inDirectory:@"Frameworks"]];
           
   if (!zallBundle) {
       zallBundle = [NSBundle bundleForClass:[self class]];
   }
   zallBundle = [NSBundle bundleWithPath:[zallBundle pathForResource:@"ZallDataSDK" ofType:@"bundle"]];
    return [zallBundle pathForResource:aName ofType:@"json"];
}
+ (NSDictionary *)zaBudleWithJsonName:(NSString *)aName{
    NSString *jsonPath = [self zaJsonPathBundleWithName:aName];
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonPath];
    return [ZAJSONUtil JSONObjectWithData:jsonData];
}

 
+ (id)zaGenerateModulManagerWithName:(NSString *)aName{
    
    return za_quick_get_method(aName, @"defaultManager");
}

+ (nullable id)zaGetUserAgent{
    return [za_quick_user_defaults() objectForKey:@"UserAgent"];
}

+ (void)zaSaveUserAgent:(NSString *)userAgent{
    if (za_check_empty_string(userAgent)) {
        return;
    }
    NSDictionary *dictionnary = [[NSDictionary alloc] initWithObjectsAndKeys:userAgent, @"UserAgent", nil];
    [za_quick_user_defaults() registerDefaults:dictionnary];
    [za_quick_user_defaults() synchronize];
    
}


+ (NSString *)zaGetAppName{
    NSBundle * bundle = [NSBundle mainBundle];
    NSString *displayName = [bundle objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    if (displayName.length > 0) {
        return displayName;
    }
    
    NSString *bundleName = [bundle objectForInfoDictionaryKey:@"CFBundleName"];
    if (bundleName.length > 0) {
        return bundleName;
    }
    
    NSString *executableName = [bundle objectForInfoDictionaryKey:@"CFBundleExecutable"];
    if (executableName) {
        return executableName;
    }
    
    return @"";
}
+(NSString *)zaGetAppIdentifier{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
}

+(NSString *)zaGetAppShortVersion{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

+ (NSString *)zaGetTelecomCompanyName{
    NSString *carrierName = nil;

    @try {
        CTTelephonyNetworkInfo *telephonyInfo = [[CTTelephonyNetworkInfo alloc] init];
        CTCarrier *carrier = nil;

#ifdef __IPHONE_12_0
        if (@available(iOS 12.1, *)) {
            // 排序
            NSArray *carrierKeysArray = [telephonyInfo.serviceSubscriberCellularProviders.allKeys sortedArrayUsingSelector:@selector(compare:)];
            carrier = telephonyInfo.serviceSubscriberCellularProviders[carrierKeysArray.firstObject];
            if (!carrier.mobileNetworkCode) {
                carrier = telephonyInfo.serviceSubscriberCellularProviders[carrierKeysArray.lastObject];
            }
        }
#endif
        if (!carrier) {
            carrier = telephonyInfo.subscriberCellularProvider;
        }
        if (carrier != nil) {
            NSString *networkCode = [carrier mobileNetworkCode];
            NSString *countryCode = [carrier mobileCountryCode];

            //中国运营商
            if (countryCode && [countryCode isEqualToString:ZACarrierChinaMCC] && networkCode) {
                //中国移动
                if ([networkCode isEqualToString:@"00"] || [networkCode isEqualToString:@"02"] || [networkCode isEqualToString:@"07"] || [networkCode isEqualToString:@"08"]) {
                    carrierName = @"中国移动";
                }
                //中国联通
                if ([networkCode isEqualToString:@"01"] || [networkCode isEqualToString:@"06"] || [networkCode isEqualToString:@"09"]) {
                    carrierName = @"中国联通";
                }
                //中国电信
                if ([networkCode isEqualToString:@"03"] || [networkCode isEqualToString:@"05"] || [networkCode isEqualToString:@"11"]) {
                    carrierName = @"中国电信";
                }
                //中国卫通
                if ([networkCode isEqualToString:@"04"]) {
                    carrierName = @"中国卫通";
                }
                //中国铁通
                if ([networkCode isEqualToString:@"20"]) {
                    carrierName = @"中国铁通";
                }
            } else if (countryCode && networkCode) { //国外运营商解析
               
                //文件路径
                NSDictionary *dicAllMcc = [self zaBudleWithJsonName:@"za_mcc_mnc_mini"];
                if (dicAllMcc) {
                    NSString *mccMncKey = [NSString stringWithFormat:@"%@%@", countryCode, networkCode];
                    carrierName = dicAllMcc[mccMncKey];
                }
            }
        }
    } @catch (NSException *exception) {
        ZALogError(@"%@: %@", self, exception);
    }
    return carrierName;
}

+ (NSString *)zaGetDeviceModelArchitecture {
    
    NSString *result = nil;
    @try {
        NSString *hwName = @"hw.machine";
        size_t size;
        sysctlbyname([hwName UTF8String], NULL, &size, NULL, 0);
        char answer[size];
        sysctlbyname([hwName UTF8String], answer, &size, NULL, 0);
        if (size) {
            result = @(answer);
        } else {
            ZALogError(@"Failed fetch %@ from sysctl.", hwName);
        }
    } @catch (NSException *exception) {
        ZALogError(@"%@: %@", self, exception);
    }
    return result;
}

+ (NSString *)idfa{
     
    NSString * (^blockIdfa)(void)= ^NSString *{
        id sharedManager = za_quick_get_method(@"ASIdentifierManager", @"sharedManager");
        NSUUID *uuid = za_quick_get_class_method(sharedManager, @"advertisingIdentifier");
        NSString *idfa = [uuid UUIDString];
        if (!idfa || [idfa hasPrefix:@"00000000"]) {
            return nil;
        }
        return idfa;
        
    };
    
    if (@available(iOS 14, *)) {
        /// source: https://developer.apple.com/documentation/bundleresources/information_property_list/nsusertrackingusagedescription?language=objc
        /// Privacy - Tracking Usage Description. 为空时 (idfaAuthorization) 也不为空
        /// 第一次安装使用有延时问题 有异步调用
        NSString * idfaAuthorization = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSUserTrackingUsageDescription"];
        if (idfaAuthorization) {
            __block NSString *idfa;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            if (NSClassFromString(@"ATTrackingManager")) {
                [NSClassFromString(@"ATTrackingManager") performSelector:NSSelectorFromString(@"requestTrackingAuthorizationWithCompletionHandler:") withObject:^(int state){
                    if (state == 3) {
                        idfa = blockIdfa();
                    }
                }];
            }
#pragma clang diagnostic pop
            
            return idfa;
        }else{
            return nil;
        }
    }
    
    return blockIdfa();
}
+ (NSString *)idfv{
    return [UIDevice currentDevice].identifierForVendor.UUIDString;
}

+ (NSString *)hardwareID{
    NSString *distinctId = nil;
    distinctId = [self idfa];
    // 没有IDFA，则使用IDFV
    if (!distinctId) {
        distinctId = [self idfv];
    }
    // 如果都没取到，则使用UUID
    if (!distinctId) {
        ZALogDebug(@"%@ error getting device identifier: falling back to uuid", self);
        distinctId = [NSUUID UUID].UUIDString;
    }
    return distinctId;
}
 


+ (NSDictionary *)zaGetModulesClassWithProtocols{
    NSArray * array = zaAppLoadReadConfigFromSection("ZASDKModules");

    NSMutableDictionary * protocolMethods = @{}.mutableCopy;
    if (!array) {
        return protocolMethods.copy;
    }
    for (NSString*moduleName in array) {
        id module = [self zaGenerateModulManagerWithName:moduleName];
        NSArray * pros = [self zaGetProtocolsWithObject:object_getClass(module)];
        for (NSString *proName in pros) {
            NSMutableArray * mods = [protocolMethods objectForKey:proName];
            if (!mods) {
                mods = [NSMutableArray array];
            }
            if (![mods containsObject:module]) {
                [mods addObject:module];
                [protocolMethods setObject:mods forKey:proName];
            }
        }
    }
    return protocolMethods.copy;
}
+ (BOOL)zaGetIsProtocolWithObject:(id)object withMethods:(NSArray<NSString *>*)methods{
    if (za_check_empty(object) || za_check_empty_array(methods)) {
        return NO;
    }
    __block BOOL isInstance = NO;
    [methods enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![object respondsToSelector:NSSelectorFromString(obj)]) {
            *stop = isInstance = YES;
        }
    }];
    return !isInstance;
}
+ (NSArray * __nullable)zaGetProtocolsWithObject:(id)object{
    NSMutableArray * array = @[].mutableCopy;
    if (!object) {
        return array;
    }
    unsigned int outCount;
    Protocol * __unsafe_unretained  * protocols = class_copyProtocolList(object,&outCount);
    for (int i = 0; i<outCount; i++) {
        Protocol *pro = protocols[i]; // 4
        NSString * protocolName = NSStringFromProtocol(pro);
        if ([protocolName hasPrefix:@"ZAModule"] && [protocolName hasSuffix:@"Protocol"]) {
            [array addObject:NSStringFromProtocol(pro)];
        }
    }
    free(protocols);
    return array.copy;
}
 
@end
