//
//  ZAVisualizedDebugLogTracker.h
//  Pods-ZallData
//
//  Created by guo on 2021/3/3.
//

#import <Foundation/Foundation.h>
#import "ZAEventIdentifier.h"
NS_ASSUME_NONNULL_BEGIN

/// 诊断日志
@interface ZAVisualizedDebugLogTracker : NSObject

/// 所有日志信息
@property (atomic, strong, readonly) NSMutableArray<NSMutableDictionary *> *debugLogInfos;

/// 元素点击事件信息
- (void)addTrackEventWithView:(UIView *)view withConfig:(NSDictionary *)config;

@end

NS_ASSUME_NONNULL_END
