//
//  KCBPeripheral.h
//  BlueToothLight
//
//  Created by whunf on 16/5/3.
//  Copyright © 2016年 sk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
//版本
#define iOS7 (floorf(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1 ? 20 : 0)
#define iOS8 (floorf(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1 ? 20 : 0)
#define iOS9 (floorf(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_8_1 ? 20 : 0)

@interface KCBPeripheral : NSObject<NSCoding>
//外设
@property(nonatomic,readwrite,strong)CBPeripheral *peripheral;
//外设的UUID
@property(nonatomic,readwrite,strong)NSString *UUIDString;
//UUID对应的名字
@property(nonatomic,readwrite,strong)NSString *name;
//构造函数
- (instancetype)initWithPeripheral:(CBPeripheral *)aPeripheral;

@end
