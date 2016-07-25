//
//  TimeViewController.m
//  BlueToothLight
//
//  Created by whunf on 16/4/28.
//  Copyright © 2016年 sk. All rights reserved.
//

#import "TimeViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "ImazeBT.h"
#import "HomeViewController.h"
@interface TimeViewController ()
#pragma mark 定时开灯按钮
@property (weak, nonatomic) IBOutlet UIButton *OnBtn;
#pragma mark 定时关灯按钮
@property (weak, nonatomic) IBOutlet UIButton *OFFBtn;
#pragma mark 时间选择器一
@property (weak, nonatomic) IBOutlet UIDatePicker *timeSelectionOne;
#pragma mark 时间选择器二
@property (weak, nonatomic) IBOutlet UIDatePicker *timeSelectionTwo;
#pragma mark 外设
@property (strong, nonatomic) CBPeripheralManager *peripheral;
#pragma mark 中心设备
@property (strong, nonatomic) CBCentralManager *manager;
@end

@implementation TimeViewController
{
    NSUserDefaults *userDefaults;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.timeSelectionOne.datePickerMode = UIDatePickerModeTime;
    self.timeSelectionTwo.datePickerMode = UIDatePickerModeTime;
    userDefaults = [NSUserDefaults standardUserDefaults];
    self.manager = [[CBCentralManager alloc]initWithDelegate:nil queue:nil];
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
#pragma mark 定时开灯方法
- (IBAction)openLightsOfTime {
    [self touchButtonOne];
//    [self compareTimeFromOne];
}
#pragma mark 定时关灯灯方法
- (IBAction)clossLightsOfTime {
    [self touchButtonTwo];
//    [self compareTimeFromtwo];
}
#pragma mark 弹框One
- (void)touchButtonOne{
    UIAlertController *alert = [[UIAlertController alloc]init];
    NSLog(@"%d",(int)self.manager.state);
    NSLog(@"%d",(int)self.peripheral.state);
    if (self.manager.state == 5) {
        alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"设置成功" preferredStyle:UIAlertControllerStyleAlert];
    }else
    {
        alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"蓝牙未连接" preferredStyle:UIAlertControllerStyleAlert];
    }
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
            [self compareTimeFromOne];
    }]];
    //显示
    [self presentViewController:alert animated:YES completion:nil];
}
#pragma mark 弹框Two
- (void)touchButtonTwo{
    UIAlertController *alert = [[UIAlertController alloc]init];
    NSLog(@"%d",(int)self.manager.state);
    NSLog(@"%d",(int)self.peripheral.state);
    if (self.manager.state == 5) {
        alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"设置成功" preferredStyle:UIAlertControllerStyleAlert];
    }else
    {
        alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"蓝牙未连接" preferredStyle:UIAlertControllerStyleAlert];
    }
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        [self compareTimeFromtwo];
    }]];
    //显示
    [self presentViewController:alert animated:YES completion:nil];
}
#pragma mark 获取第一个时间选择器的时间
- (IBAction)datePickOne{
    NSDate *select = [self.timeSelectionOne date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    NSString *dateAndTime = [dateFormatter stringFromDate:select];
    [userDefaults setObject:dateAndTime forKey:@"time"];
    [userDefaults synchronize];
    NSLog(@"%@",dateAndTime);
}
#pragma mark 获取第二个时间选择器的时间
- (IBAction)datePickTwo{
    NSDate *select = [self.timeSelectionTwo date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    NSString *dateAndTime = [dateFormatter stringFromDate:select];
    [userDefaults setObject:dateAndTime forKey:@"time"];
    [userDefaults synchronize];
    NSLog(@"%@",dateAndTime);
}
#pragma mark 开灯方法
- (void)compareTimeFromOne
{
    [self.timeSelectionOne addTarget:self action:@selector(datePickOne) forControlEvents:UIControlEventTouchUpInside];
    [self compareTime:1];
}
#pragma mark 关灯方法
- (void)compareTimeFromtwo
{
    [self.timeSelectionTwo addTarget:self action:@selector(datePickTwo) forControlEvents:UIControlEventTouchUpInside];
    [self compareTime:2];
}
#pragma mark 获取时间差
- (void)compareTime:(int)i
{
    NSDateFormatter *formater = [[NSDateFormatter alloc]init];
    formater.dateFormat = @"HH:mm:ss";
    NSString *dateTime = [formater stringFromDate:[NSDate date]];
    NSString *date = [userDefaults objectForKey:@"time"];
    
    NSString *strTime = dateTime;
    NSArray *array = [strTime componentsSeparatedByString:@":"]; //从字符A中分隔成2个元素的数组
    NSString *HH = array[0];
    NSString *mm= array[1];
    NSString *ss = array[2];
    NSInteger h = [HH integerValue];
    NSInteger m = [mm integerValue];
    NSInteger s = [ss integerValue];
    NSInteger zonghms = h*3600 + m*60 +s;
    
    NSString *strTime1 = date;
    NSArray *array1 = [strTime1 componentsSeparatedByString:@":"]; //从字符A中分隔成2个元素的数组
    NSString *HH1 = array1[0];
    NSString *mm1= array1[1];
    NSString *ss1 = array1[2];
    NSInteger h1 = [HH1 integerValue];
    NSInteger m1 = [mm1 integerValue];
    NSInteger s1 = [ss1 integerValue];
    NSInteger zonghms1 = h1*3600 + m1*60 +s1;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
         [NSThread sleepForTimeInterval:zonghms1-zonghms];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (i == 1) {
                 [kBLUETOOTH ble07_red:1*255 blue:1*255 green:1*255 AndBright:1*255];
            }else
                [kBLUETOOTH ble07_red:0 blue:0 green:0 AndBright:0];
        });
    });
}
@end
