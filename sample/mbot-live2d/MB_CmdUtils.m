//
//  MB_CmdUtils.m
//  mBot_enterprise
//
//  Created by liuming on 15/11/20.
//  Copyright © 2015年 makeblock. All rights reserved.
//  基于通信协议层的命令工具类

#import "MB_CmdUtils.h"

@implementation MB_CmdUtils

/* 发送命令
 ff  55  len  idx action device port  slot  data  a
 0   1    2    3    4      5     6     7     8
 */

+ (NSData *)buildModuleWriteShortWithDevice:(int)device andPort:(int)port andSlot:(int)slot andValue:(short)value {
    unsigned char a[10]={0xff,0x55,0,0,0,0,0,0,0,0};
    a[2] = 0x6;
    a[3] = 0;
    a[4] = WRITEMODULE;
    a[5] = device;
    a[6] = port;
    a[7] = value&0xff;  //low
    a[8] = (value>>8)&0xff;  //high
    NSData *data = [NSData dataWithBytes:a length:10];
    return data;
}

+ (NSData *)buildModuleReadWithDevice:(int)device andPort:(int)port andSlot:(int)slot andIndex:(int)index {
    unsigned char a[9]={0xff,0x55,0,0,0,0,0,0,'\n'};
    a[2] = 0x5;
    a[3] = index;
    a[4] = READMODULE;
    a[5] = device;
    a[6] = port;
    a[7] = slot;
    NSData *data = [NSData dataWithBytes:a length:9];
    return data;
}
+ (NSData *)buildModuleWriteLedWithFirmwareVersion:(NSString *)firmwareVersion andDevice:(int)device andPort:(int)port andSlot:(int)slot andIndex:(int)index andR:(int)r andG:(int)g andB:(int)b {
    //06.01.030  1.2.103
    if ([FIRMWARE_VERSION_NEW isEqualToString:firmwareVersion]) {
        NSLog(@"新固件");
        unsigned char cmd[13]={0xff,0x55,0,0,0,0,0,0,0,0,0,'\n'};
        cmd[2] = 0x9;
        cmd[3] = 0;
        cmd[4] = WRITEMODULE;
        cmd[5] = device;
        cmd[6] = port;
        cmd[7] = slot;  //slot: mBot指定slot=2
        cmd[8] = index; //index: 0.all  1.right  2.left
        cmd[9] = r;
        cmd[10] = g;
        cmd[11] = b;
        NSData *dataNew = [NSData dataWithBytes:cmd length:12];
        return dataNew;
    }
    //老固件
    NSLog(@"老固件");
    unsigned char a[12]={0xff,0x55,0,0,0,0,0,0,0,0,0,'\n'};
    a[2] = 0x8;
    a[3] = 0;
    a[4] = WRITEMODULE;
    a[5] = device;
    a[6] = port;
    a[7] = index; //index: 0.all  1.right  2.left
    a[8] = r;
    a[9] = g;
    a[10] = b;
    NSData *data = [NSData dataWithBytes:a length:12];
    return data;
}

+ (NSData *)buildModuleWriteBuzzerWithFirmwareVersion:(NSString *)firmwareVersion andHz:(int)hz {
    if ([FIRMWARE_VERSION_NEW isEqualToString:firmwareVersion]) {
        NSLog(@"新固件");
         unsigned char cmd[10]={0xff,0x55,0,0,0,0,0,0,0,0,0,'\n'};
        cmd[2] = 0x7;
        cmd[3] = 0;
        cmd[4] = WRITEMODULE;
        cmd[5] = TONE;
        valShort.shortVal = hz;
        cmd[6] = valShort.byteVal[0];
        cmd[7] = valShort.byteVal[1];
//        cmd[8] = 0xf4;
//        cmd[9] = 1;
        cmd[8] = 0xfa;
        cmd[9] = 0;
        NSData *dataNew = [NSData dataWithBytes:cmd length:10];
        return dataNew;
    }
    NSLog(@"老固件");
    unsigned char a[10]={0xff,0x55,0,0,0,0,0,0,0,'\n'};
    a[2] = 0x5;  //后面的数据长度
    a[3] = 0;
    a[4] = WRITEMODULE;
    a[5] = TONE;
    valShort.shortVal = hz;
    a[6] = valShort.byteVal[0];
    a[7] = valShort.byteVal[1];
    NSData *data = [NSData dataWithBytes:a length:8];
    return data;
}


+ (NSData *)buildModuleWriteBuzzerWithFirmwareVersion:(NSString *)firmwareVersion andHzLow:(int)hzLow andHzHigh:(int)hzHigh{
    if ([FIRMWARE_VERSION_NEW isEqualToString:firmwareVersion]) {
        NSLog(@"新固件");
        unsigned char cmd[10]={0xff,0x55,0,0,0,0,0,0,0,0,0,'\n'};
        cmd[2] = 0x7;
        cmd[3] = 0;
        cmd[4] = WRITEMODULE;
        cmd[5] = TONE;
        cmd[6] = hzLow;
        cmd[7] = hzHigh;
        //        cmd[8] = 0xf4;
        //        cmd[9] = 1;
        cmd[8] = 0xfa;
        cmd[9] = 0;
        
        NSLog(@"cmd[6]=%x cmd[7]=%x ",cmd[6],cmd[7]);
        NSData *dataNew = [NSData dataWithBytes:cmd length:10];
        return dataNew;
    }
    NSLog(@"老固件");
    unsigned char a[10]={0xff,0x55,0,0,0,0,0,0,0,'\n'};
    a[2] = 0x5;  //后面的数据长度
    a[3] = 0;
    a[4] = WRITEMODULE;
    a[5] = TONE;
    a[6] = hzLow;
    a[7] = hzHigh;
    NSData *data = [NSData dataWithBytes:a length:8];
    return data;
}


+ (NSData *)buildModuleQueryFirmwareVersion {
    unsigned char a[7]={0xff,0x55,3,VERSION_INDEX,READMODULE,0,'\n'};
    NSData *cmd = [NSData dataWithBytes:a length:7];
    return cmd;
}

@end
