//
//  KCBPeripheral.m
//  BlueToothLight
//
//  Created by whunf on 16/5/3.
//  Copyright © 2016年 sk. All rights reserved.
//

#import "KCBPeripheral.h"

@implementation KCBPeripheral
- (instancetype)initWithPeripheral:(CBPeripheral *)aPeripheral
{
    if (self == [super init]) {
        self.peripheral = aPeripheral;
        self.name = aPeripheral.name;
        if (iOS7) {
            self.UUIDString = [[aPeripheral identifier]UUIDString];
        }
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.peripheral forKey:@"Peripheral"];
    [aCoder encodeObject:self.name forKey:@"Name"];
    [aCoder encodeObject:self.UUIDString forKey:@"UUID"];
}
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self == [super init]) {
        self.peripheral = [aDecoder decodeObjectForKey:@"Peripheral"];
        self.name = [aDecoder decodeObjectForKey:@"Name"];
        self.UUIDString = [aDecoder decodeObjectForKey:@"UUID"];
    }
    return self;
}
@end
