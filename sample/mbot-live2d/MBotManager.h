//
//  MBotManager.h
//  mBot_enterprise
//
//  Created by liuming on 15/11/20.
//  Copyright © 2015年 makeblock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MB_CmdUtils.h"
#import "BLECentralManager.h"

//小车的工作模式
#define MODE_DISCONNECTED      (0)
#define MODE_AUTO      (1)
#define MODE_MANUAL    (2)
#define MODE_CRUISE    (3)
#define MODE_GYRO      (4)
#define MODE_SPEED_MAX (5)
#define MODE_SHAKE     (6)

//说明书上:超声波4，巡线2
#define PORT_ULTRASOINIC  3  //超声波port
#define PORT_LINEFOLLOWER 2  //巡线port

@protocol MBotManagerDelegate <NSObject>

@optional
//操控模式变化
-(void)controlModeChanged:(int)currentControlMode;
-(void)speedChangedWithLeft:(int)left andRight:(int)right;

@end




@interface MBotManager : NSObject <BLEControllerDelegate>

@property (assign, nonatomic) id<MBotManagerDelegate> delegate;

+(MBotManager *)sharedManager;

+ (int)currentControlMode;

#pragma mark ------------查询固件版本------------
+ (void)queryFirmwareVersion;

#pragma mark ------------控制硬件------------
+ (void)setLedToNextColor;
//+ (void)setLedToOff;

/**
 *  老固件:buzzer会一直响，需要timer去stop
 *  新固件:cmd中包含响的时间
 */
+ (void)setBuzzerToNextHz;

+ (void)setBuzzerToOff;

+ (void)setSpeedWithLeft:(int)leftSpeed andRight:(int)rightSpeed;

#pragma mark ------------七种模式------------
+ (void)setMode2FollowLine;
+ (void)setMode2Auto;
+ (void)setMode2Manual;
+ (void)setMode2Disconnected;
+ (void)setMode2Gravity;
+ (void)setMode2SpeedMax;
+ (void)setMode2Shake;

@end
