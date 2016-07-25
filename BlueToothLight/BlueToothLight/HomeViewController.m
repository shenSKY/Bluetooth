//
//  HomeViewController.m
//  BlueToothLight
//
//  Created by whunf on 16/4/28.
//  Copyright © 2016年 sk. All rights reserved.
//

#import "HomeViewController.h"

@interface HomeViewController ()<CBPeripheralManagerDelegate>
#pragma mark 背景图片
@property (strong, nonatomic) IBOutlet UIView *backGroundView;
#pragma mark 亮度调节滑块
@property (weak, nonatomic) IBOutlet UISlider *brightnessSlider;
#pragma mark 红色调节滑块
@property (weak, nonatomic) IBOutlet UISlider *redSlider;
#pragma mark 绿色调节滑块
@property (weak, nonatomic) IBOutlet UISlider *greenSlider;
#pragma mark 蓝色调节滑块
@property (weak, nonatomic) IBOutlet UISlider *blueSlider;
#pragma mark 灯
@property (weak, nonatomic) IBOutlet UIButton *light;
#pragma mark 蓝牙开关
@property (weak, nonatomic) IBOutlet UIButton *bluetooth;
#pragma mark 中心设备
@property (strong, nonatomic) CBCentralManager *manager;
#pragma mark 外设
@property (strong, nonatomic) CBPeripheralManager *peripheral;

@end

@implementation HomeViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self refreshColorValue];
    self.manager = [[CBCentralManager alloc]initWithDelegate:nil queue:nil];
    // Do any additional setup after loading the view.
}
#pragma mark 收到内存警告
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
#pragma mark 亮度滑块调整亮度
- (IBAction)brightnessSlider:(id)sender {
    [self refreshColorValue];
}
#pragma mark 红色滑块调整颜色
- (IBAction)redSlider:(id)sender {
    [self refreshColorValue];
}
#pragma mark 绿色滑块调整颜色
- (IBAction)greenSlider:(id)sender {
    [self refreshColorValue];
}
#pragma mark 蓝色滑块调整颜色
- (IBAction)blueSlider:(id)sender {
    [self refreshColorValue];
}

#pragma mark 背景的颜色
- (void)refreshColorValue{
    float brightness = self.brightnessSlider.value* 0.8 + 0.3;
    float red = self.redSlider.value;
    float green = self.greenSlider.value;
    float blue = self.blueSlider.value;
    self.backGroundView.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:brightness];
    self.light.tintColor = [UIColor colorWithRed:red green:green blue:blue alpha:brightness];
    //发送颜色指令给蓝牙灯
    [kBLUETOOTH ble07_red:red*255 blue:green*255 green:blue*255 AndBright:brightness*255];
}
- (IBAction)Open {
    NSLog(@"开灯");
    [self refreshColorValue];
}
- (IBAction)Close {
    NSLog(@"关灯");
    [kBLUETOOTH ble07_red:0 blue:0 green:0 AndBright:0];
}
#pragma mark 判断自身蓝牙是否开启
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral{
        switch (peripheral.state) {
            case CBCentralManagerStateUnsupported:
                NSLog(@"外设蓝牙不支持");
                break;
            case CBCentralManagerStateUnauthorized:
                NSLog(@"应用没有权限");
                break;
            case CBCentralManagerStatePoweredOff:
                NSLog(@"手机蓝牙已经关闭");
                break;
            case CBCentralManagerStatePoweredOn:
                [_manager scanForPeripheralsWithServices:nil options:nil];
                NSLog(@"电源开了");
            case CBCentralManagerStateUnknown:
                NSLog(@"未知设备");
            default:
                break;

    }
}
#pragma mark 连接蓝牙
- (IBAction)OpenOrCloseBlueTooth {
//    self.peripheral = [[CBPeripheralManager alloc]initWithDelegate:nil queue:nil];
//    [self peripheralManagerDidUpdateState:self.peripheral];
    [kBLUETOOTH startScan];
    UIAlertController *alert = [[UIAlertController alloc]init];
    if (self.manager.state == 5) {
        alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"连接成功" preferredStyle:UIAlertControllerStyleAlert];
    }else
    {
        alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"蓝牙未连接" preferredStyle:UIAlertControllerStyleAlert];
    }
    [alert addAction:[UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleCancel handler:nil]];
    //显示
    [self presentViewController:alert animated:YES completion:nil];
}
@end
