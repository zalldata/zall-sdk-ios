//
//  ZARootViewController.m
//  ZallData
//
//  Created by guo on 2022/1/24.
//  Copyright © 2022 Zall Data Co., Ltd. All rights reserved.
//

#import "ZARootViewController.h"
#import "ZASDKAction.h"


@interface ZARootViewController ()

@property (nonatomic, strong) ZASDKAction *actionModel;


@end

@implementation ZARootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}
- (ZASDKAction *)actionModel{
    if (!_actionModel) {
        _actionModel = [[ZASDKAction alloc] init];
    }
    return _actionModel;
}
 
#pragma mark - TableViewDataSource
 

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.actionModel.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell =[tableView dequeueReusableCellWithIdentifier:@"cellid" forIndexPath:indexPath];
    cell.textLabel.text = [self.actionModel cellForWithRow:indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    __weak __typeof(self)weakSelf = self;
    [self.actionModel cellForSelecttWithRow:indexPath.row withBlcok:^(ZASDKAction * _Nonnull action) {
        ZARootViewController * vc = (ZARootViewController *)rootViewController();
        vc.actionModel = action;
        vc.title = [weakSelf.actionModel cellForWithRow:indexPath.row];
        [weakSelf.navigationController showViewController:vc sender:nil];
    }];
}

@end


