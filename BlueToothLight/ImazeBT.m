//
//  ImazeBT.m
//  Imaze
//
//  Created by 王sen俊 on 16/4/15.
//  Copyright © 2016年 wsj. All rights reserved.
//

#import "ImazeBT.h"
#import "KCBPeripheral.h"
/**
 *  声明私有属性和实现指令发送的方法
 */
@interface ImazeBT()

//校准的特征
@property (strong, nonatomic) CBCharacteristic *calibrationCharacteristic;
//特征
@property (strong, nonatomic) CBCharacteristic *Characteristic1001;
@property (strong, nonatomic) CBCharacteristic *Characteristic1002;
@property (strong, nonatomic) CBCharacteristic *Characteristic1003;
@property (strong, nonatomic) CBCharacteristic *Characteristic1004;
@property (strong, nonatomic) CBCharacteristic *Characteristic1005;

//发送通知的特征
@property (strong, nonatomic) CBCharacteristic *notiCharacteristic;
@property (strong, nonatomic) CBService *calibrationService;

//记录颜色
@property (nonatomic, assign) int bright;
@property (nonatomic, assign) int red;
@property (nonatomic, assign) int blue;
@property (nonatomic, assign) int green;

@end

@implementation ImazeBT

static ImazeBT *sharedObject;
#pragma mark -  初始化shareObject，实现单例，节省内存空间
+ (ImazeBT *)sharedManager
{
    //如果对象为空，则初始化对象
    if (sharedObject == nil) {
        sharedObject = [[super allocWithZone:NULL] init];
    }
    
    return sharedObject;
}
#pragma mark -  初始化属性
- (instancetype)init
{
    self = [super init];
    _autoConnect = TRUE;
    self.lastData = 0;
    //初始化中心管理器
    _manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    _manager.delegate = self;
    return self;
}

#pragma mark - 开始和停止扫描的方法
//判断硬件是否支持
- (BOOL)isLECapableHardware
{
    NSString * state = nil;
    /**
          外设状态
     CBCentralManagerStateUnknown = 0,
     CBCentralManagerStateResetting,
     CBCentralManagerStateUnsupported,
     CBCentralManagerStateUnauthorized,
     CBCentralManagerStatePoweredOff,
     CBCentralManagerStatePoweredOn
     */
    int iState = (int)[_manager state];
    
    NSLog(@"手机蓝牙的状态: %i", iState);
    
    switch ([_manager state])
    {
        case CBCentralManagerStateUnsupported:
            state = @"外设蓝牙不支持";
            break;
        case CBCentralManagerStateUnauthorized:
            state = @"应用没有权限";
            break;
        case CBCentralManagerStatePoweredOff:
            state = @"手机蓝牙已经关闭";
            break;
        case CBCentralManagerStatePoweredOn:
            [_manager scanForPeripheralsWithServices:nil options:nil];
            NSLog(@"电源开了");
            return TRUE;
        case CBCentralManagerStateUnknown:
            NSLog(@"未知设备");
        default:
            return FALSE;
    }
    
    NSLog(@"手机蓝牙状态: %@", state);
    
    return FALSE;
}

/*
 开始扫描
 可针对性搜索
 */
- (void)startScan
{
    //在满足硬件要求的情况下开始扫描
    if ([self isLECapableHardware]) {
        [_manager scanForPeripheralsWithServices:nil options:nil];
    }
}

/*
 停止扫描
 Request CBCentralManager to stop scanning for peripherals
 */
- (void)stopScan
{
    [_manager stopScan];
}

//懒加载外设数组
-(NSMutableArray *)connectedPeripherals
{
    if (_connectedPeripherals  == nil) {
        NSMutableArray * temp = [NSMutableArray array];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        for (NSUInteger i = 0; i < 1; i++)
        {
            //解档
            NSData* encodedTag = [defaults objectForKey:
                             [NSString stringWithFormat:@"%ld", (unsigned long)i]];
            KCBPeripheral *p=(KCBPeripheral *)[NSKeyedUnarchiver unarchiveObjectWithData:encodedTag];
            //如果解档成功则，将已保存的外设添加到外设数组中
            if (p != nil) {
                [temp addObject:p];
                NSLog(@"加载外设 %@  %@",p.name,p.UUIDString);
            }
        }
        
        _connectedPeripherals = temp;
    }
    return _connectedPeripherals;
}


#pragma mark 保存蓝牙
-(void)SavePeripherals{
    
    //将附近的外设保存到偏好设置plist文件中
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:[self.connectedPeripherals count] forKey:@"ProximityAppTagCount"];
    //将每个外设归档存储
    for (NSUInteger i = 0; i < [self.connectedPeripherals count]; i++)
    {
        KCBPeripheral *per=(KCBPeripheral*) [self.connectedPeripherals objectAtIndex:i];
        NSData *encodedTag = [NSKeyedArchiver archivedDataWithRootObject:per];
        NSLog(@"SavePeripherals UUID = %@  Name = %@ ",per.UUIDString,_peripheral);
        [defaults setObject:encodedTag forKey:[NSString stringWithFormat:@"ProximityAppTag%lu", (unsigned long)i]];
    }
}

//加载外设
-(void)LoadPeripherals{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    for (NSUInteger i = 0; i <1 ; i++)
    {
        NSData* encodedTag = [defaults objectForKey:[NSString stringWithFormat:@"ProximityAppTag%lu", (unsigned long)i]];
        KCBPeripheral *p=(KCBPeripheral *)[NSKeyedUnarchiver unarchiveObjectWithData:encodedTag];
        NSLog(@"加载的外设名字与UUID %@  %@",p.name,p.UUIDString);
        
        if (p != nil) {
            [self.connectedPeripherals addObject:p];
        }
        
        
    }
}

#pragma mark 自动断开
-(void)disconnectBySelf
{
    [_manager cancelPeripheralConnection:self.peripheral];
    _autoConnect = NO;
}

#pragma mark -  断开设备
-(void)disconnectPeripheral:(CBPeripheral*)per
{
    NSLog(@"蓝牙设备已断开");
//     主动断开
        [_manager cancelPeripheralConnection:per];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"disconnect" object:nil];
        [self startScan];
}

#pragma mark  以下为中心设备的代理方法
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    [self isLECapableHardware];
    NSLog(@"手机蓝牙连接状态变更");
}

#pragma mark -  处理扫描到的设备
/*
 扫描到的设备
 调用该方法时扫描,发现周边蓝牙对象CBPeripheral、中心CBCentralManager。对合适的周边对象进行保留来使用它;对于不感兴趣的,将由中心CBCentralManager清理。
 */
- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)aPeripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI
{
    if ([aPeripheral.name isEqualToString:@"KQX-BL1000"]) {
        _peripheral = aPeripheral;
        [_manager connectPeripheral:aPeripheral options:nil];
    }
}

#pragma mark -  自动重连的方法
/*
 自动重连的重要方法
 当中央管理器调用检索列表中已知的外围设备。自动连接到第一个已知的外围
 */
- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals
{
    if([peripherals count] >= 1)
    {
        _peripheral = [peripherals objectAtIndex:0];
        NSLog(@"正在连接外设....%@",_peripheral.name);
        //连接外设
        [_manager connectPeripheral:_peripheral options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
    }
}

#pragma mark - 每当调用是成功创建连接外围。外围发现可用的服务
- (void)centralManager:(CBCentralManager *)central
  didConnectPeripheral:(CBPeripheral *)aPeripheral
{
    NSLog(@"蓝牙连接成功");
    //连接成功后设置代理
    [aPeripheral setDelegate:self];
    //同时开始 查看这个周边对象服务 会在以下的方法回调
    //- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error;
    [aPeripheral discoverServices:nil];
    
    self.connectStatu = YES;
    _autoConnect = YES;
    [self stopScan];
    
}

#pragma mark - 周边对象与中心断开连接的调用方法
- (void)centralManager:(CBCentralManager *)central
didDisconnectPeripheral:(CBPeripheral *)aPeripheral
                 error:(NSError *)error
{
    self.connectStatu = NO;
    NSLog(@"无连接！！");
    if (_autoConnect) {
        [self connectDevice:aPeripheral];
    }
    
    if( _peripheral )
    {
        [_peripheral setDelegate:nil];
        _peripheral = nil;
    }
}

#pragma mark -  中心与周边对象连接失败的回调
- (void)centralManager:(CBCentralManager *)central
didFailToConnectPeripheral:(CBPeripheral *)aPeripheral
                 error:(NSError *)error
{
    NSLog(@"连接外设失败: %@ 错误信息 = %@", aPeripheral, [error localizedDescription]);
    if( _peripheral )
    {
        [_peripheral setDelegate:nil];
        
        _peripheral = nil;
    }
}

#pragma mark - 以下为外设代理方法
/*
 周边对象调用了-[discoverServices:]方法后，会在代理（现在是自身）的以下方法中返回
 */
- (void)peripheral:(CBPeripheral *)aPeripheral
didDiscoverServices:(NSError *)error
{
    //遍历外设的服务
    for (CBService *aService in aPeripheral.services)
    {
        NSLog(@"手机已连接外设的UUID : %@", aService.UUID);
        //连接指定UUID的设备
        if ([aService.UUID isEqual:[CBUUID UUIDWithString:@"1000"]]){
            // 找到了周边对象的服务后 调用 -[discoverCharacteristics]可以查看 服务中的特征
            // 在 -[didDiscoverCharacteristicsForService] 中回调
            [aPeripheral discoverCharacteristics:nil forService:aService];
        }
        
        //连接指定UUID的设备
        if ([aService.UUID isEqual:[CBUUID UUIDWithString:@"FFE0"]]){
                    [aPeripheral discoverCharacteristics:nil forService:aService];
                }
    }
}

/*
 周边对象找到服务后 调用-[discoverCharacteristics:forService:] 查看其中的特征值
 在这个方法中你能拿到连接上的周边对象的服务uuid和 特征UUID ,对于需要发送数据和接受数据特征，要保存起来，同时打开监听
 */
- (void) peripheral:(CBPeripheral *)aPeripheral
didDiscoverCharacteristicsForService:(CBService *)service
              error:(NSError *)error
{
    
    NSLog(@"外设名 : %@", service.UUID);
    NSLog(@"外设的特征信息 :%@",service.characteristics);
    
    if (service.isPrimary) {
        NSLog(@"基础的外设 : %@", service.UUID);
}
    
    if ([service.UUID isEqual: [CBUUID UUIDWithString:@"1000"]])
    {
        for (CBCharacteristic *aChar in service.characteristics)
        {
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"1001"]]) {
                
                NSLog(@"找到了通道特征: %@", aChar.UUID);
                _Characteristic1001 = aChar;
            }
            
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"1002"]]) {
                
                _Characteristic1002 = aChar;
                
                [aPeripheral setNotifyValue:YES forCharacteristic:_Characteristic1002];
                [aPeripheral readValueForCharacteristic:_Characteristic1002];
            }
        }
    }
        [self sendPSW];
//    延迟执行方法,确保数据传输
        [self performSelector:@selector(sendPSW) withObject:nil afterDelay:0.2];
    
        [self performSelector:@selector(sendPSW) withObject:nil afterDelay:0.5];
    
}

#pragma mark 接收到 网桥的返回
- (void)peripheral:(CBPeripheral *)peripheral
didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error
{
    if (error)
    {
        NSLog(@"交互错误: %@", error.localizedDescription);
    }
    
    if (characteristic.isNotifying)
    {
        NSLog(@"手机给外设发送的特征 %@", characteristic);
        [peripheral readValueForCharacteristic:characteristic];
    }

}
//接收到网桥的返回
- (void) peripheral:(CBPeripheral *)aPeripheral
didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
              error:(NSError *)error
{
    if (error)
    {
        NSLog(@"更新特征的错误信息 %@", error.localizedDescription);
    }
    
    NSLog(@"外设更新的值 :%@",characteristic.value);
    NSLog(@" ******* 已更新的通道特征--UUID :%@",characteristic.UUID);
    NSData *data = characteristic.value;
    NSLog(@" 数据长度data.length = %lu %@",(unsigned long)data.length, data);
    
    
}



- (void)peripheral:(CBPeripheral *)_peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"发送成功");
    NSLog(@"有以下特征 :%@",characteristic);
     if (error)
    {
        NSLog(@"写入特征的值失败 %@, reason: %@", characteristic, error);
    }
    else
    {
        NSLog(@"旧的特征值 %@, 新的特征值: %@", characteristic, [characteristic value]);
    }
}

#pragma mark - 自定义
- (void)connectDevice:(CBPeripheral *)aper
{
    if (_peripheral != nil) {
        [self disconnectPeripheral:_peripheral];
    }
}

#pragma mark -  发送密码
- (void)sendPSW
{
    int i = 0;
    char char_array[17] = {0x00};//定义一个字节数组
    char_array[i++] = 0x55;  //16进制
    char_array[i++] = 0xaa;  //10进制
    char_array[i++] = 0x30;  //
    //打包成data
    NSData* data = [NSData dataWithBytes:(const void *)char_array length:sizeof(char) * 17];
    NSLog(@"发送的数据  %@",data);
    //发送数据
    [_peripheral writeValue:data forCharacteristic:_Characteristic1001 type:CBCharacteristicWriteWithResponse];
}

/**
 *  设备状态输出,命令字0x07
 0x55,0xAA,0x07, [R][G][B][W][BRT][IO1] RGBW为四路PWM数据,0-255,分别控制四路灯具,BRT为RGBW的灰度参数,0-255, 正确返回 55 AA 07
 *  颜色
 */
- (void)ble07_red:(int)red blue:(int)blue green:(int)green 
{
    int i = 0;
    char char_array[17] = {0x00};//定义一个字节数组
    char_array[i++] = 0x55;  //16进制
    char_array[i++] = 0xaa;  //10进制
    char_array[i++] = 0x07;  //
    
    char_array[i++] = red;  //r
    char_array[i++] = green;  //g
    char_array[i++] = blue;  //b
    char_array[i++] = 0x00;  //w
    char_array[i++] = 0x1A;  //brt
    //保存颜色
    _red = red;
    _blue = blue;
    _green = green;
    //打包成data
    NSData* data = [NSData dataWithBytes:(const void *)char_array length:sizeof(char) * 17];
    NSLog(@"ble07发送的数据  %@",data);
    //发送数据
    [_peripheral writeValue:data forCharacteristic:_Characteristic1001 type:CBCharacteristicWriteWithResponse];

}

- (void)ble07_red:(int)red blue:(int)blue green:(int)green AndBright:(int)bright
{
    
    int i = 0;
    char char_array[17] = {0x00};//定义一个字节数组
    char_array[i++] = 0x55;  //16进制
    char_array[i++] = 0xaa;  //10进制
    char_array[i++] = 0x07;  //
    
    char_array[i++] = red;  //r
    char_array[i++] = blue;  //g
    char_array[i++] = green;  //b
    char_array[i++] = 0x00;  //w
    char_array[i++] = bright;  //brt
    
    //打包成data
    NSData* data = [NSData dataWithBytes:(const void *)char_array length:sizeof(char) * 17];
    NSLog(@"ble07发送的亮度数据  %@",data);
    
    [_peripheral writeValue:data forCharacteristic:_Characteristic1001 type:CBCharacteristicWriteWithResponse];
    
}

@end
