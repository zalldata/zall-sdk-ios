//
// UIView+ZAModel.m
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

#import "UIView+ZAProperty.h"
#import <objc/message.h>
#import "ZAWeakDelegate.h"


@implementation UIView (ZAProperty)

- (NSString *)za_viewPropertyID{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setZa_viewPropertyID:(NSString *)za_viewID{
    objc_setAssociatedObject(self, @selector(za_viewPropertyID), za_viewID, OBJC_ASSOCIATION_COPY);
}

- (BOOL)za_viewPropertyIgnore{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

-(void)setZa_viewPropertyIgnore:(BOOL)za_ignoreView{
    objc_setAssociatedObject(self, @selector(za_viewPropertyIgnore), @(za_ignoreView), OBJC_ASSOCIATION_ASSIGN);
}
- (BOOL)za_viewPropertyAutoTrackAfterSendAction{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}
-(void)setZa_viewPropertyAutoTrackAfterSendAction:(BOOL)za_autoTrackAfterSendAction{
    objc_setAssociatedObject(self, @selector(za_viewPropertyAutoTrackAfterSendAction), @(za_autoTrackAfterSendAction), OBJC_ASSOCIATION_ASSIGN);
}
-(NSDictionary *)za_viewProperties{
    return objc_getAssociatedObject(self, _cmd);

}
-(void)setZa_viewProperties:(NSDictionary *)za_viewProperties{
    objc_setAssociatedObject(self, @selector(za_viewProperties), za_viewProperties, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

}

-(id<ZAUIViewPropertyDelegate>)za_viewPropertyDelegate{
    ZAWeakDelegate * delegate = objc_getAssociatedObject(self, _cmd);
    return delegate.weakDelegate;
}
-(void)setZa_viewPropertyDelegate:(id<ZAUIViewPropertyDelegate>)za_autoTrackDelegate{
    ZAWeakDelegate * delegate = [ZAWeakDelegate containerWithWeakDelegate:za_autoTrackDelegate];
    objc_setAssociatedObject(self, @selector(za_viewPropertyDelegate), delegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


@end
@implementation UIImage (ZAProperty)

-(NSString *)za_imageName{
    return objc_getAssociatedObject(self, _cmd);
}
-(void)setZa_imageName:(NSString *)za_imageName{
    objc_setAssociatedObject(self, @selector(za_imageName), za_imageName, OBJC_ASSOCIATION_COPY);
}
@end

