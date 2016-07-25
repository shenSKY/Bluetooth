//
//  ProfilesViewController.m
//  BlueToothLight
//
//  Created by whunf on 16/4/28.
//  Copyright © 2016年 sk. All rights reserved.
//

#import "ProfilesViewController.h"
#import "ImazeBT.h"
@interface ProfilesViewController ()
#pragma mark 简约白按钮
@property (weak, nonatomic) IBOutlet UIButton *whiteButton;
#pragma mark 暖心黄按钮
@property (weak, nonatomic) IBOutlet UIButton *yellowButton;
#pragma mark 清新蓝按钮
@property (weak, nonatomic) IBOutlet UIButton *blueButton;
#pragma mark 情景模式背景
@property (strong, nonatomic) IBOutlet UIView *ProfilesBackground;

@end

@implementation ProfilesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark 简约白按钮点击变白色
- (IBAction)WhiteButton{
    self.ProfilesBackground.backgroundColor = [UIColor whiteColor];
    [kBLUETOOTH ble07_red:1*255 blue:1*255 green:1*255 AndBright:1*255];
}
#pragma mark 暖心黄按钮点击变淡黄色
- (IBAction)YellowButton {
    self.ProfilesBackground.backgroundColor = [UIColor colorWithRed:1 green:1 blue:0.94 alpha:1];
    [kBLUETOOTH ble07_red:1*255 blue:0.8*255 green:1*255 AndBright:1*255];
}
#pragma mark 清新蓝按钮点击变淡蓝色
- (IBAction)BlueButton:(id)sender {
    self.ProfilesBackground.backgroundColor = [UIColor colorWithRed:0.53 green:0.81 blue:1 alpha:1];
    [kBLUETOOTH ble07_red:0.53*255 blue:1*255 green:0.81*255 AndBright:1*255];
}

@end
