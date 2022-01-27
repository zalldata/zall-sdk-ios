//
//  ZASDKAction.h
//  ZallData
//
//  Created by guo on 2022/1/24.
//  Copyright © 2022 Zall Data Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

NS_INLINE UIViewController * rootViewController(void){
    return [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"rootViewController"];
}

@interface ZASDKAction : NSObject
@property (nonatomic, assign) NSInteger count;

-(NSString *)cellForWithRow:(NSInteger)row;
-(void)cellForSelecttWithRow:(NSInteger)row withBlcok:(void(^)(ZASDKAction *action))block;



@end

NS_ASSUME_NONNULL_END
