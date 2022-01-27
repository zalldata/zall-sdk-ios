//
// ZAScrollViewDelegateProxy.m
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

#import "ZAScrollViewProxy.h"

#import "ZAAutoTrackManager.h"
#import <objc/message.h>

@implementation ZAScrollViewProxy

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SEL methodSelector = @selector(tableView:didSelectRowAtIndexPath:);

    [ZAScrollViewProxy trackEventWithTarget:self scrollView:tableView atIndexPath:indexPath];
    [ZAScrollViewProxy invokeWithTarget:self selector:methodSelector, tableView, indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    SEL methodSelector = @selector(collectionView:didSelectItemAtIndexPath:);

    [ZAScrollViewProxy trackEventWithTarget:self scrollView:collectionView atIndexPath:indexPath];
    [ZAScrollViewProxy invokeWithTarget:self selector:methodSelector, collectionView, indexPath];
}

+ (void)trackEventWithTarget:(NSObject *)target scrollView:(UIScrollView *)scrollView atIndexPath:(NSIndexPath *)indexPath {
    // 当 target 和 delegate 不相等时为消息转发, 此时无需重复采集事件
    if (target != scrollView.delegate) {
        return;
    }

    [ZAAutoTrackManager.defaultManager.trackerAppClick autoTrackEventWithScrollView:scrollView atIndexPath:indexPath];
}

@end
