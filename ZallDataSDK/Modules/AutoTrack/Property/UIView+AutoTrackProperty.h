//
//  UIView+za_autoTrack.h
//  ZallDataSDK
//
//  Created by guo on 2018/6/11.
//  Copyright © 2015-2020 Zall Data Co., Ltd. All rights reserved.
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

#import <UIKit/UIKit.h>
#import "ZAAutoTrackProperty.h"

#pragma mark - UIView

@interface UIView (AutoTrackProperty) <ZAAutoTrackViewProperty>
@end

@interface UILabel (AutoTrackProperty) <ZAAutoTrackViewProperty>
@end

@interface UIImageView (AutoTrackProperty) <ZAAutoTrackViewProperty>
@end

@interface UISearchBar (AutoTrackProperty) <ZAAutoTrackViewProperty>
@end

#pragma mark - UIControl

@interface UIControl (AutoTrackProperty) <ZAAutoTrackViewProperty>
@end

@interface UIButton (AutoTrackProperty) <ZAAutoTrackViewProperty>
@end

@interface UISwitch (AutoTrackProperty) <ZAAutoTrackViewProperty>
@end

@interface UIStepper (AutoTrackProperty) <ZAAutoTrackViewProperty>
@end

@interface UISegmentedControl (AutoTrackProperty) <ZAAutoTrackViewProperty>
@end


@interface UIPageControl (AutoTrackProperty) <ZAAutoTrackViewProperty>
@end

#pragma mark - Cell
@interface UITableViewCell (AutoTrackProperty) <ZAAutoTrackItemProperty>

@end

@interface UICollectionViewCell (AutoTrackProperty) <ZAAutoTrackItemProperty>


@end
