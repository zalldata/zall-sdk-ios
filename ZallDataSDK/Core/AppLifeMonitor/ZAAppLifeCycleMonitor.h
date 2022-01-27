//
// ZAAppLifeMonitor.h
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
typedef void (^LifeCycleBlcok)(void);
/**
 ZAAppLifeCycleState APP生命周期监测
 */
typedef NS_ENUM(NSUInteger, ZAAppLifeCycleMonitorState) {
    /// 进入程序首次启动
    ZAAppLifeCycleMonitorStateInitiativeStart = 1,
    /// APP 启动
    ZAAppLifeCycleMonitorStateStart,
    /// APP 被启动
    ZAAppLifeCycleMonitorStatePassiveStart,
    /// APP 结束
    ZAAppLifeCycleMonitorStateEnd,
    /// APP 退出
    ZAAppLifeCycleMonitorStateQuit
};


/// App 启动生命周期监测类 APP内置状态无法满足现有需求
@interface ZAAppLifeCycleMonitor : NSObject

/// 生命周期
@property(nonatomic, assign,readonly) ZAAppLifeCycleMonitorState state;

+(instancetype)sharedInstance;
/// 禁用 init 初始化
- (instancetype)init NS_UNAVAILABLE;

/// 禁用 new 初始化
+ (instancetype)new NS_UNAVAILABLE;


///开始监听
-(void)beginMonitor;


/// 即将开始热启动回调
@property(nonatomic, copy) LifeCycleBlcok lifeCycleWillStart;
/// 即将开始退出回调
@property(nonatomic, copy) LifeCycleBlcok lifeCycleWillEnd;
/// 已经冷热启动开始启动回调
@property(nonatomic, copy) LifeCycleBlcok lifeCycleDidStart;
/// 已经退出回调
@property(nonatomic, copy) LifeCycleBlcok lifeCycleDidEnd;
/// 应用终止
@property(nonatomic, copy) LifeCycleBlcok lifeCycleDidQuit;
 

@end

NS_ASSUME_NONNULL_END
