//
//  UIScrollView+AutoTrack.m
//  ZallDataSDK
//
//  Created by guo on 2019/6/19.
//  Copyright © 2019 ZallData. All rights reserved.
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

#import "UIScrollView+AutoTrack.h"
#import "ZAScrollViewProxy.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "ZAAutoTrackManager.h"

#import "ZAHookMethodHeader.h"

@implementation UITableView (AutoTrack)

- (void)za_autoTrack_setDelegate:(id)delegate {
    //resolve optional selectors
    [ZAScrollViewProxy resolveOptionalSelectorsForDelegate:delegate];
    
    [self za_autoTrack_setDelegate:delegate];

    if (!delegate || !self.delegate) {
        return;
    }
    
    // 判断是否忽略 $AppClick 事件采集
    if ([ZAAutoTrackManager.defaultManager isAutoTrackEventTypeIgnored:ZAAutoTrackEventTypeAppClick]) {
        return;
    }
    
    // 使用委托类去 hook 点击事件方法
    [ZAScrollViewProxy proxyDelegate:self.delegate selectors:[NSSet setWithArray:@[@"tableView:didSelectRowAtIndexPath:"]]];
}


@end


@implementation UICollectionView (AutoTrack)

- (void)za_autoTrack_setDelegate:(id <UICollectionViewDelegate>)delegate {
    //resolve optional selectors
    [ZAScrollViewProxy resolveOptionalSelectorsForDelegate:delegate];
    
    [self za_autoTrack_setDelegate:delegate];
    
    if (!delegate || !self.delegate) {
        return;
    }
    
    // 判断是否忽略 $AppClick 事件采集
    if ([ZAAutoTrackManager.defaultManager isAutoTrackEventTypeIgnored:ZAAutoTrackEventTypeAppClick]) {
        return;
    }
    
    // 使用委托类去 hook 点击事件方法
    [ZAScrollViewProxy proxyDelegate:self.delegate selectors:[NSSet setWithArray:@[@"collectionView:didSelectItemAtIndexPath:"]]];
}

@end
