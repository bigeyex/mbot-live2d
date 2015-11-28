//
//  MB_CmdUtils.h
//  mBot_enterprise
//
//  Created by liuming on 15/11/20.
//  Copyright © 2015年 makeblock. All rights reserved.
//

#import <Foundation/Foundation.h>

//设备类型
#define DEV_VERSION        0
#define DEV_ULTRASOINIC    1  //超声波
#define DEV_TEMPERATURE    2
#define DEV_LIGHTSENSOR    3
#define DEV_POTENTIALMETER 4
#define DEV_GYRO           6
#define DEV_SOUNDSENSOR    7
#define DEV_RGBLED         8
#define DEV_SEVSEG         9
#define DEV_DCMOTOR        10
#define DEV_SERVO          11
#define DEV_ENCODER        12
#define DEV_JOYSTICK       13
#define DEV_PIRMOTION      15
#define DEV_INFRADRED      16
#define DEV_LINEFOLLOWER   17
#define DEV_BUTTON         18
#define DEV_LIMITSWITCH    19
#define DEV_PINDIGITAL     30
#define DEV_PINANALOG      31
#define DEV_PINPWM         32
#define DEV_PINANGLE       33
#define TONE               34

#define SLOT_1 1 //0
#define SLOT_2 2 //1

#define READMODULE  1
#define WRITEMODULE 2

#define VERSION_INDEX 0xFA  //查询固件版本号

//端口：1，2，3，4对应四个大的端口
//5，6，7，8需要看下位机的固件代码
//M1，M2白色的端口，上面有文字
#define PORT_NULL 0
#define PORT_1    1
#define PORT_2    2
#define PORT_3    3
#define PORT_4    4
#define PORT_5    5
#define PORT_6    6
#define PORT_7    7
#define PORT_8    8
#define PORT_M1   9
#define PORT_M2   10

#define FIRMWARE_VERSION_NEW (@"06.01.030")
#define FIRMWARE_VERSION_OLD (@"1.2.103")

union{
    Byte  byteVal[2];
    short shortVal;
} valShort;

@interface MB_CmdUtils : NSObject

+ (NSData *)buildModuleWriteShortWithDevice:(int)device andPort:(int)port andSlot:(int)slot andValue:(short)value;

+ (NSData *)buildModuleReadWithDevice:(int)device andPort:(int)port andSlot:(int)slot andIndex:(int)index;

/**
 *  构建控制LED的命令
 *
 *  @param firmwareVersion 固件版本，默认返回老版固件协议的命令，可为nil
 *  @param device          传感器
 *  @param port            端口
 *  @param slot            新固件：必须slot=2。老固件不需要此参数
 *  @param index           控制的Led的index: 0.all  1.right  2.left
 *  @param r               red
 *  @param g               green
 *  @param b               blue
 *
 *  @return 控制LED的命令
 */
+ (NSData *)buildModuleWriteLedWithFirmwareVersion:(NSString *)firmwareVersion andDevice:(int)device andPort:(int)port andSlot:(int)slot andIndex:(int)index andR:(int)r andG:(int)g andB:(int)b;

+ (NSData *)buildModuleWriteBuzzerWithFirmwareVersion:(NSString *)firmwareVersion andHzLow:(int)hzLow andHzHigh:(int)hzHigh;

+ (NSData *)buildModuleQueryFirmwareVersion;

@end
