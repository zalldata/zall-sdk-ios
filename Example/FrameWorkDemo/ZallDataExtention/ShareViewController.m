//
//  ShareViewController.m
//  share
//
//  Created by guo on 2020/4/27.
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
#if __has_include(<ZallDataSDK/ZallDataSDKExtension.h>)
#import <ZallDataSDK/ZallDataSDKExtension.h>
#endif

#if __has_include(<ZallDataSDKExtension/ZallDataSDKExtension.h>)
#import <ZallDataSDKExtension/ZallDataSDKExtension.h>
#endif

#import "ShareViewController.h"

@interface ShareViewController ()

@end

@implementation ShareViewController

- (BOOL)isContentValid {
    // Do validation of contentText and/or NSExtensionContext attachments here
    return YES;
}

- (void)didSelectPost {
    // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    
    // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
    [[ZAAppExtensionDataManager sharedInstance]writeEvent:@"SharedExtensionPost"
                                               properties:@{@"Action":@"Post",@"content":self.contentText?self.contentText :@""}
                                          groupIdentifier:@"group.cn.com.ZallData.share"];
    [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
}

-(void)didSelectCancel {
    [[ZAAppExtensionDataManager sharedInstance] writeEvent:@"SharedExtensionCancel"
                                               properties:@{@"Action":@"Cancel",@"content":self.contentText?self.contentText :@""}
                                          groupIdentifier:@"group.cn.com.ZallData.share"];
}
- (NSArray *)configurationItems {
    // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
    return @[];
}

@end
