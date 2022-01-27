//
//  ZAAutoTrackUtilsTest.m
//  ZallDataTests
//
//  Created by guo on 2020/4/16.
//  Copyright © 2019-2020 Zall Data Co., Ltd. All rights reserved.
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
    

#import <XCTest/XCTest.h>
#import <UIKit/UIKit.h>
#import "ZallDataSDK.h"
#import "ZAAutoTrackUtils.h"
#import "ElementViewController.h"
#import "UIView+AutoTrack.h"
#import "UIViewController+AutoTrack.h"

@interface ZAAutoTrackUtilsTest : XCTestCase
@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) ElementViewController *viewController;
@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, strong) UITabBarController *tabBarController;
@end

@implementation ZAAutoTrackUtilsTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.window.backgroundColor = [UIColor whiteColor];

    self.viewController = [[ElementViewController alloc] init];

    self.tabBarController = [[UITabBarController alloc] init];

    self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.viewController];
    self.navigationController.tabBarItem.title = @"Element";

    UITableViewController *firstViewController = [[UITableViewController alloc] init];
    UINavigationController *firstNavigationController = [[UINavigationController alloc] initWithRootViewController:firstViewController];

    self.tabBarController.viewControllers = @[firstNavigationController, self.navigationController];
    self.window.rootViewController = self.tabBarController;

    [self.viewController view];
    [self.viewController viewWillAppear:NO];
    [self.viewController viewDidAppear:NO];

    ZAConfigOptions *options = [[ZAConfigOptions alloc] initWithServerURL:@"" launchOptions:nil];
    options.autoTrackEventType = ZallDataEventTypeAppStart | ZallDataEventTypeAppEnd | ZallDataEventTypeAppClick | ZallDataEventTypeAppViewScreen;
    /// 需要显示select
    options.enableHeatMap = YES;
    [ZallDataSDK startWithConfigOptions:options];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.

    [self.tabBarController viewWillDisappear:NO];
    [self.tabBarController viewDidDisappear:NO];

    self.window.rootViewController = nil;
    self.tabBarController = nil;
    self.navigationController = nil;
    self.viewController = nil;

    self.window.hidden = YES;
    self.window = nil;
}

- (void)testFindNextViewControllerByResponder {
    UIViewController *vc = [ZAAutoTrackUtils findNextViewControllerByResponder:self.viewController.label];
    XCTAssertEqualObjects(self.viewController, vc);
}

- (void)testAutoTrackPropertiesWithButton {
    NSDictionary *dic = [ZAAutoTrackUtils propertiesWithAutoTrackObject:self.viewController.firstButton viewController:self.viewController];

    XCTAssertTrue([dic[@"$title"] isEqualToString:@"Element"]);
    XCTAssertTrue([dic[@"$screen_name"] isEqualToString:@"ElementViewController"]);

    XCTAssertTrue([dic[@"$element_id"] isEqualToString:@"FirstButtonViewId"]);
    XCTAssertTrue([dic[@"$element_type"] isEqualToString:@"UIButton"]);
    XCTAssertTrue([dic[@"$element_content"] isEqualToString:@"FirstButton"]);

    // version 1.11.0
    NSString *selector = @"UITabBarController/UINavigationController[1]/ElementViewController/UIView/UIScrollView/UIButton[(jjf_varE='48e2c5881d79d256751ad1ca00f1ca7b18db2f5e' AND jjf_varB='069e4bf7483d2ce72b7d96ab25df3ee25ccc7725' AND jjf_varA='ae5af528697005b4df798827f1eb559f9f9ffc6e')]";
    XCTAssertTrue([dic[@"$element_selector"] isEqualToString:selector]);
     
}

- (void)testAutoTrackPropertiesWithCustomButton {
    NSDictionary *dic = [ZAAutoTrackUtils propertiesWithAutoTrackObject:self.viewController.secondButton viewController:self.viewController];

    XCTAssertTrue([dic[@"$title"] isEqualToString:@"Element"]);
    XCTAssertTrue([dic[@"$screen_name"] isEqualToString:@"ElementViewController"]);

    XCTAssertNil(dic[@"$element_id"]);
    XCTAssertNil(dic[@"$element_position"]);
    XCTAssertTrue([dic[@"$element_type"] isEqualToString:@"CustomButton"]);
    XCTAssertTrue([dic[@"$element_content"] isEqualToString:@"SecondButton"]);

    // version 1.11.0
    NSString *selector = @"UITabBarController/UINavigationController[1]/ElementViewController/UIView/UIScrollView/CustomButton[(jjf_varE='714cdf49ea3239903c52fa1b730832c08b81ef3a' AND jjf_varB='2eda4e1895ef39a601c41da8062d821019d4d99c')]";
    XCTAssertTrue([dic[@"$element_selector"] isEqualToString:selector]);
     
}

- (void)testAutoTrackPropertiesWithSlider {
    self.viewController.slider.value = 0.5555;
    NSDictionary *dic = [ZAAutoTrackUtils propertiesWithAutoTrackObject:self.viewController.slider viewController:self.viewController];

    XCTAssertTrue([dic[@"$title"] isEqualToString:@"Element"]);
    XCTAssertTrue([dic[@"$screen_name"] isEqualToString:@"ElementViewController"]);

    XCTAssertNil(dic[@"$element_id"]);
    XCTAssertNil(dic[@"$element_position"]);
    XCTAssertTrue([dic[@"$element_type"] isEqualToString:@"UISlider"]);
    XCTAssertTrue([dic[@"$element_content"] doubleValue] == 0.5555);

    // version 1.11.0
    NSString *selector = @"UITabBarController/UINavigationController[1]/ElementViewController/UIView/UIScrollView/UISlider[(jjf_varB='40be71691d75278c3b4ad73edc118a00f073c31d')]";
    XCTAssertTrue([dic[@"$element_selector"] isEqualToString:selector]);
}

- (void)testAutoTrackPropertiesWithStepper {
    self.viewController.stepper.value = 99;

    NSDictionary *dic = [ZAAutoTrackUtils propertiesWithAutoTrackObject:self.viewController.stepper viewController:self.viewController];

    XCTAssertTrue([dic[@"$title"] isEqualToString:@"Element"]);
    XCTAssertTrue([dic[@"$screen_name"] isEqualToString:@"ElementViewController"]);

    XCTAssertNil(dic[@"$element_id"]);
    XCTAssertNil(dic[@"$element_position"]);
    XCTAssertTrue([dic[@"$element_type"] isEqualToString:@"UIStepper"]);
    XCTAssertTrue([dic[@"$element_content"] doubleValue] == 99);

    // version 1.11.0
    NSString *selector = @"UITabBarController/UINavigationController[1]/ElementViewController/UIView/UIScrollView/UIStepper[(jjf_varB='eeb8a2dd9a9743ccf6065c39df3bbdca99059f0c')]";
    XCTAssertTrue([dic[@"$element_selector"] isEqualToString:selector]);
}

- (void)testAutoTrackPropertiesWithSwitch {
    self.viewController.uiswitch.on = YES;

    NSDictionary *dic = [ZAAutoTrackUtils propertiesWithAutoTrackObject:self.viewController.uiswitch viewController:self.viewController];

    XCTAssertTrue([dic[@"$title"] isEqualToString:@"Element"]);
    XCTAssertTrue([dic[@"$screen_name"] isEqualToString:@"ElementViewController"]);

    XCTAssertNil(dic[@"$element_id"]);
    XCTAssertNil(dic[@"$element_position"]);
    XCTAssertTrue([dic[@"$element_type"] isEqualToString:@"UISwitch"]);
    XCTAssertTrue([dic[@"$element_content"] isEqualToString:@"checked"]);

    // version 1.11.0
    NSString *selector = @"UITabBarController/UINavigationController[1]/ElementViewController/UIView/UIScrollView/UISwitch[(jjf_varB='e6e184158358b42cfc78bcc3b19011afc9417547')]";
    XCTAssertTrue([dic[@"$element_selector"] isEqualToString:selector]);
}

- (void)testAutoTrackPropertiesWithSegmentedControl {
    self.viewController.segmentedControl.selectedSegmentIndex = 1;

    NSDictionary *dic = [ZAAutoTrackUtils propertiesWithAutoTrackObject:self.viewController.segmentedControl viewController:self.viewController];

    XCTAssertTrue([dic[@"$title"] isEqualToString:@"Element"]);
    XCTAssertTrue([dic[@"$screen_name"] isEqualToString:@"ElementViewController"]);

    XCTAssertNil(dic[@"$element_id"]);
    XCTAssertTrue([dic[@"$element_type"] isEqualToString:@"UISegmentedControl"]);
    XCTAssertTrue([dic[@"$element_content"] isEqualToString:@"第二个"]);
    XCTAssertTrue([dic[@"$element_position"] isEqualToString:@"1"]);

    // version 1.11.0
    NSString *selector = @"UITabBarController/UINavigationController[1]/ElementViewController/UIView/UIScrollView/UISegmentedControl[(jjf_varB='fac459bd36d8326d9140192c7900decaf3744f5e')]/UISegment[1]";
    XCTAssertTrue([dic[@"$element_selector"] isEqualToString:selector]);
}

- (void)testAutoTrackPropertiesWithTapLabel {
    NSDictionary *dic = [ZAAutoTrackUtils propertiesWithAutoTrackObject:self.viewController.label viewController:self.viewController];

    XCTAssertTrue([dic[@"$title"] isEqualToString:@"Element"]);
    XCTAssertTrue([dic[@"$screen_name"] isEqualToString:@"ElementViewController"]);

    XCTAssertNil(dic[@"$element_id"]);
    XCTAssertTrue([dic[@"$element_type"] isEqualToString:@"UILabel"]);
    XCTAssertTrue([dic[@"$element_content"] isEqualToString:@"这是一个可以点击的 Label"]);
    XCTAssertNil(dic[@"$element_position"]);

    // version 1.11.0
    NSString *selector = @"UITabBarController/UINavigationController[1]/ElementViewController/UIView/UIScrollView/UILabel[(jjf_varE='7ac9e0fb66ba5d819b14c5520322a6f2f0f2b64e')]";
    XCTAssertTrue([dic[@"$element_selector"] isEqualToString:selector]);
}

- (void)testAutoTrackPropertiesWithTapImageView {
    NSDictionary *dic = [ZAAutoTrackUtils propertiesWithAutoTrackObject:self.viewController.imageView viewController:self.viewController];

    XCTAssertTrue([dic[@"$title"] isEqualToString:@"Element"]);
    XCTAssertTrue([dic[@"$screen_name"] isEqualToString:@"ElementViewController"]);

    XCTAssertNil(dic[@"$element_id"]);
    XCTAssertTrue([dic[@"$element_type"] isEqualToString:@"UIImageView"]);
    XCTAssertNil(dic[@"$element_content"]);
    XCTAssertNil(dic[@"$element_position"]);

    // version 1.11.0
    NSString *selector = @"UITabBarController/UINavigationController[1]/ElementViewController/UIView/UIScrollView/UIImageView";
    XCTAssertTrue([dic[@"$element_selector"] isEqualToString:selector]);
}

- (void)testAutoTrackPropertiesWithTableView {
    // row 太大可能未在屏幕显示，取不到 cell
    NSDictionary *dic = [ZAAutoTrackUtils propertiesWithAutoTrackObject:self.viewController.tableView didSelectedAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];

    XCTAssertTrue([dic[@"$title"] isEqualToString:@"Element"]);
    XCTAssertTrue([dic[@"$screen_name"] isEqualToString:@"ElementViewController"]);

    XCTAssertNil(dic[@"$element_id"]);
    XCTAssertTrue([dic[@"$element_type"] isEqualToString:@"UITableView"]);
    XCTAssertTrue([dic[@"$element_content"] isEqualToString:@"Section: 0, Row: 2"]);
    XCTAssertTrue([dic[@"$element_position"] isEqualToString:@"0:2"]);

    // version 1.11.0
    NSString *selector = nil;
    if (@available(iOS 11.0, *)) {
        selector = @"UITabBarController/UINavigationController[1]/ElementViewController/UIView/UITableView/UITableViewCell[0][2]";
    } else {
        // iOS 11 以下路径中多 UITableViewWrapperView
        selector = @"UITabBarController/UINavigationController[1]/ElementViewController/UIView/UITableView/UITableViewWrapperView/UITableViewCell[0][2]";
    }
    XCTAssertTrue([dic[@"$element_selector"] isEqualToString:selector]);
}

- (void)testCategoryDelegateProperty {
    UIView *view = [[UIView alloc]init];
    NSObject *delegate = [[NSObject alloc]init];
    view.zallDataDelegate = (NSObject<ZAUIViewAutoTrackDelegate>*) delegate;
    delegate = nil;
    XCTAssertNil(view.zallDataDelegate);
}

- (void)testViewTypeIgnoredOfSubClass {
    [[ZallDataSDK sharedInstance] ignoreViewType:[UIControl class]];
    BOOL buttonIgnored = [[ZallDataSDK sharedInstance] isViewTypeIgnored:[UIButton class]];
    XCTAssertTrue(buttonIgnored);

    BOOL segmentedControlIgnored = [[ZallDataSDK sharedInstance] isViewTypeIgnored:[UISegmentedControl class]];
    XCTAssertTrue(segmentedControlIgnored);
}

- (void)testViewTypeIgnoredOfCurrentClass {
    [[ZallDataSDK sharedInstance] ignoreViewType:[UIControl class]];
    BOOL controlIgnored = [[ZallDataSDK sharedInstance] isViewTypeIgnored:[UIControl class]];
    XCTAssertTrue(controlIgnored);
}

- (void)testViewTypeIgnoredOfSuperClass {
    [[ZallDataSDK sharedInstance] ignoreViewType:[UIControl class]];
    BOOL viewIgnored = [[ZallDataSDK sharedInstance] isViewTypeIgnored:[UIView class]];
    XCTAssertFalse(viewIgnored);
}

- (void)testViewTypeIgnoredOfOtherClass {
    [[ZallDataSDK sharedInstance] ignoreViewType:[UIControl class]];
    BOOL itemIgnored = [[ZallDataSDK sharedInstance] isViewTypeIgnored:[UIBarButtonItem class]];
    XCTAssertFalse(itemIgnored);
}

- (void)testPerformanceExample {
    [self measureBlock:^{
        [ZAAutoTrackUtils propertiesWithAutoTrackObject:self.viewController.firstButton viewController:self.viewController];
        [ZAAutoTrackUtils propertiesWithAutoTrackObject:self.viewController.secondButton viewController:self.viewController];
        [ZAAutoTrackUtils propertiesWithAutoTrackObject:self.viewController.slider viewController:self.viewController];
        [ZAAutoTrackUtils propertiesWithAutoTrackObject:self.viewController.stepper viewController:self.viewController];
        [ZAAutoTrackUtils propertiesWithAutoTrackObject:self.viewController.uiswitch viewController:self.viewController];
        [ZAAutoTrackUtils propertiesWithAutoTrackObject:self.viewController.segmentedControl viewController:self.viewController];
        [ZAAutoTrackUtils propertiesWithAutoTrackObject:self.viewController.label viewController:self.viewController];
        [ZAAutoTrackUtils propertiesWithAutoTrackObject:self.viewController.imageView viewController:self.viewController];
    }];
}

@end
