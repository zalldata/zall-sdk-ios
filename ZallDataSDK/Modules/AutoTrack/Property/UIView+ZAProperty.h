//
// UIView+ZAModel.h
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
@protocol ZAUIViewPropertyDelegate <NSObject>

//UITableView
@optional
- (NSDictionary *)za_tableView:(UITableView *)tableView autoTrackPropertiesAtIndexPath:(NSIndexPath *)indexPath;

//UICollectionView
@optional
- (NSDictionary *)za_collectionView:(UICollectionView *)collectionView autoTrackPropertiesAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface UIView (ZAProperty)

@property (nonatomic, copy) NSString* za_viewPropertyID;

/// AutoTrack 时，是否忽略该 View
@property (nonatomic, assign) BOOL za_viewPropertyIgnore;

/// AutoTrack 发生在 SendAction 之前还是之后，默认是 SendAction 之前
@property (nonatomic, assign) BOOL za_viewPropertyAutoTrackAfterSendAction;

/// AutoTrack 时，View 的扩展属性
@property (nonatomic, strong) NSDictionary* za_viewProperties;

@property (nonatomic, weak, nullable) id<ZAUIViewPropertyDelegate> za_viewPropertyDelegate;

@end


@interface UIImage (ZAProperty)
@property (nonatomic, copy) NSString* za_imageName;
@end


NS_ASSUME_NONNULL_END
