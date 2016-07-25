//
//  ImazeBT.h
//  Imaze
//
//  Created by 王sen俊 on 16/4/15.
//  Copyright © 2016年 lzm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#define kBLUETOOTH [ImazeBT sharedManager]
/**
 * 声明蓝牙发送指令所需要用到的属性和方法
 */
@interface ImazeBT : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>
#pragma mark -  属性
//中心设备
@property (strong, nonatomic) CBCentralManager *manager;
//外设
@property (strong, nonatomic) CBPeripheral *peripheral;
//蓝牙是否连接成功
@property (nonatomic) BOOL BluetoothTURE;
//是否自动连接
@property (nonatomic) BOOL autoConnect;
//时间间隔
@property (nonatomic) NSTimeInterval lastData;
//新定义一个连接状态
@property (atomic,assign) BOOL connectStatu;
//所有外设的数组
@property (weak, nonatomic) NSArray *peripherals;
//连接过的Peripherals
@property (strong, nonatomic) NSMutableArray *connectedPeripherals;
//定时扫描器
@property(nonatomic,strong)NSTimer * ScanTimer;

#pragma mark -  方法
+ (ImazeBT *)sharedManager;
- (void) startScan;
- (void) stopScan;
//发送颜色
- (void)ble07_red:(int)red blue:(int)blue green:(int)green;
//发送亮度
- (void)ble07_red:(int)red blue:(int)blue green:(int)green AndBright:(int)bright;
//断开与外设的连接
-(void)disconnectPeripheral:(CBPeripheral*)per;
//连接设备
- (void)connectDevice:(CBPeripheral *)aper;

@end
