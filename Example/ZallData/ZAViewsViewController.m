//
//  ZAViewsViewController.m
//  ZallData
//
//  Created by guo on 2022/1/26.
//  Copyright © 2022 Zall Data Co., Ltd. All rights reserved.
//

#import "ZAViewsViewController.h"

@interface ZAViewsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *myLabel;
@property (weak, nonatomic) IBOutlet UIButton *myButton;
@property (weak, nonatomic) IBOutlet UIButton *myButtonItem;
@property (weak, nonatomic) IBOutlet UISegmentedControl *mySecond;
@property (weak, nonatomic) IBOutlet UITextField *myTextField;
@property (weak, nonatomic) IBOutlet UISlider *mySlider;
@property (weak, nonatomic) IBOutlet UISwitch *mySwitch;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *myActivityIndicator;
@property (weak, nonatomic) IBOutlet UIProgressView *myProgressView;
@property (weak, nonatomic) IBOutlet UIPageControl *myPageControl;
@property (weak, nonatomic) IBOutlet UIStepper *myStepper;
@property (weak, nonatomic) IBOutlet UIImageView *myImageView;
@property (weak, nonatomic) IBOutlet UITextView *myTextView;
@property (weak, nonatomic) IBOutlet UIDatePicker *myDataPicker;

@end

@implementation ZAViewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UITapGestureRecognizer *imageViewTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageViewTouchUpInside:)];
    self.myImageView.userInteractionEnabled = YES;
    [self.myImageView addGestureRecognizer:imageViewTapGestureRecognizer];
}

#pragma mark - Action
-(void)imageViewTouchUpInside:(id)sender{
    
}
- (IBAction)mybuttonAction:(id)sender {
    
}
- (IBAction)myButtonItemAction:(id)sender {
    
}
- (IBAction)mySecondAction:(id)sender {
    
}
- (IBAction)myTextFieldAction:(id)sender {
    
}

- (IBAction)mySliderAction:(UISlider *)sender {
    self.myProgressView.progress = sender.value;
}
- (IBAction)mySwitchAction:(UISwitch *)sender {
    if (sender.isOn) {
        [self.myActivityIndicator startAnimating];
    }else{
        [self.myActivityIndicator stopAnimating];
    }
    
}
- (IBAction)myPageAction:(id)sender {
    
}
- (IBAction)myStepper:(id)sender {
    
}

- (IBAction)myDataPicker:(id)sender {
    
}
 


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
