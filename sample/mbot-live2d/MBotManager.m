//
//  MBotManager.m
//  mBot_enterprise
//
//  Created by liuming on 15/11/20.
//  Copyright © 2015年 makeblock. All rights reserved.
//  逻辑层Manager

#import "MBotManager.h"

#define INDEX_CMD_CRUISE      (11)
#define INDEX_CMD_ULTRASOINIC (22)
#define LED_BRIGHTNESS_FACTOR (25) //Led亮度系数，越大则亮度越低 >=1


//static int hzArray[7] = {262,294,330,349,392,440,494};//七个音调对应的数据
static int hzArray[8][2] = {
    {0x06,0x01},{0x26,0x01},{0x4a,0x01},{0x5d,0x01},{0x88,0x01},{0xb8,0x01},{0xee,0x01},{0x0b,0x02}
}; //七个音调对应的数据

static int _currentIndex_Led_RGB = 0;
static int _currentIndex_Buzzer_Hz = 0;
static int _currentControlMode = MODE_DISCONNECTED;

static NSTimer *_timer4Cruise;
static NSTimer *_timer4Auto;
static NSTimer *_timer4Buzzer;
static NSTimer *_timer4SpeedMax;
static NSTimer *_timer4QueryFirmwareVersion;
static NSTimer *_timer4Buzzer;

static NSString *_firmwareVersionStr;

@implementation MBotManager {
    Byte buffer[100] ;
    int index4Buffer;
    int flag4Left;
    int flag4Right;
}

+ (void)setSpeedWithLeft:(int)leftSpeed andRight:(int)rightSpeed {
    [_instance.delegate speedChangedWithLeft:leftSpeed andRight:rightSpeed];
    NSData *cmd =[MB_CmdUtils buildModuleWriteShortWithDevice:DEV_DCMOTOR andPort:PORT_M2 andSlot:SLOT_1 andValue:rightSpeed];
    [[BLECentralManager sharedManager].activePeripheral sendDataMandatory:cmd];
    NSData *cmd2 = [MB_CmdUtils buildModuleWriteShortWithDevice:DEV_DCMOTOR andPort:PORT_M1 andSlot:SLOT_1 andValue:leftSpeed];
    [[BLECentralManager sharedManager].activePeripheral sendDataMandatory:cmd2];
}

+ (void)setLedToNextColor{
    int r = 0;
    int g = 0;
    int b = 0;
    switch (_currentIndex_Led_RGB%6) {
        case 0:
            r = 255/LED_BRIGHTNESS_FACTOR;
            g = 255/LED_BRIGHTNESS_FACTOR;
            b = 255/LED_BRIGHTNESS_FACTOR;
            break;
        case 1:
            r = 255/LED_BRIGHTNESS_FACTOR;
            g = 0;
            b = 0;
            break;
        case 2:
            r = 255/LED_BRIGHTNESS_FACTOR;
            g = 255/LED_BRIGHTNESS_FACTOR;
            b = 0;
            break;
        case 3:
            r = 0;
            g = 255/LED_BRIGHTNESS_FACTOR;
            b = 0;
            break;
        case 4:
            r = 0;
            g = 0;
            b = 255/LED_BRIGHTNESS_FACTOR;
            break;
        case 5: //off
            r = 0;
            g = 0;
            b = 0;
            break;
    }
    int device = 8;
    int port = 7;//RGB端口
    int slot = 2;
    int index = 0; //index：0都亮  1一号亮  2二号亮
    NSData * cmd = [MB_CmdUtils buildModuleWriteLedWithFirmwareVersion:_firmwareVersionStr andDevice:device andPort:port andSlot:slot andIndex:index andR:r andG:g andB:b];
    [[BLECentralManager sharedManager].activePeripheral sendDataMandatory:cmd];
    _currentIndex_Led_RGB++;
}

static NSTimeInterval currentTime = 0; //以秒为单位
+ (void)setBuzzerToNextHz{
    //此处需要特别提醒：新固件采用delay方式执行代码，发送命令不能太快
    if([FIRMWARE_VERSION_NEW isEqualToString:_firmwareVersionStr]){
        NSLog(@"[NSDate timeIntervalSinceReferenceDate]=%f",[NSDate timeIntervalSinceReferenceDate]);
        NSLog(@"currentTime=%f",currentTime);
        
        if ([NSDate timeIntervalSinceReferenceDate]-currentTime > 0.5f) {
            NSLog(@"发送buzzer命令");
            currentTime = [NSDate timeIntervalSinceReferenceDate];
            int index = _currentIndex_Buzzer_Hz%8;
            int hzLow = hzArray[index][0];
            int hzHigh = hzArray[index][1];
            _currentIndex_Buzzer_Hz++;
            NSData *cmd = [MB_CmdUtils buildModuleWriteBuzzerWithFirmwareVersion:_firmwareVersionStr andHzLow:hzLow andHzHigh:hzHigh];
            [[BLECentralManager sharedManager].activePeripheral sendDataMandatory:cmd];
        }
        return;
    }
    
    int index = _currentIndex_Buzzer_Hz%8;
    int hzLow = hzArray[index][0];
    int hzHigh = hzArray[index][1];
    _currentIndex_Buzzer_Hz++;
    
    NSData *cmd = [MB_CmdUtils buildModuleWriteBuzzerWithFirmwareVersion:_firmwareVersionStr andHzLow:hzLow andHzHigh:hzHigh];
    [[BLECentralManager sharedManager].activePeripheral sendDataMandatory:cmd];
    //500ms后stop buzzer
    if([_timer4Buzzer isValid]){
        [_timer4Buzzer invalidate];
    }
    _timer4Buzzer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(setBuzzerToOff) userInfo:nil repeats:NO];
}

+ (void)setBuzzerToOff {
    NSLog(@"setBuzzerToOff");
    NSData *cmd = [MB_CmdUtils buildModuleWriteBuzzerWithFirmwareVersion:_firmwareVersionStr andHzLow:0 andHzHigh:0];
    [[BLECentralManager sharedManager].activePeripheral sendDataMandatory:cmd];
}

+ (void)queryFirmwareVersion{
    NSData *cmd = [MB_CmdUtils buildModuleQueryFirmwareVersion];
    [[BLECentralManager sharedManager].activePeripheral sendDataMandatory:cmd];
}

#pragma mark ------------七种模式------------
+ (void)setMode2FollowLine {
    if (_currentControlMode == MODE_CRUISE) {
        NSLog(@"_currentControlMode == MODE_CRUISE return");
        return;
    }
    NSLog(@"_currentControlMode ---> MODE_CRUISE");
    
    //停止其他timer
    [_timer4Auto invalidate];
    [_timer4Buzzer invalidate];
    [_timer4SpeedMax invalidate];
    [_timer4QueryFirmwareVersion invalidate];
    if (!(_timer4Cruise.isValid)) {
        //不可用
        _timer4Cruise = [NSTimer scheduledTimerWithTimeInterval:0.02f target:self selector:@selector(sendData4CruiseMode) userInfo:nil repeats:YES];
        [_timer4Cruise fire];
    }
    
    _currentControlMode = MODE_CRUISE;
    [_instance.delegate controlModeChanged:_currentControlMode];
}

+ (void)setMode2Auto {
    if (_currentControlMode == MODE_AUTO) {
        NSLog(@"_currentControlMode == MODE_AUTO return");
        return;
    }
    NSLog(@"_currentControlMode ---> MODE_AUTO");
    
    //停止其他timer
    [_timer4Cruise invalidate];
    [_timer4Buzzer invalidate];
    [_timer4SpeedMax invalidate];
    [_timer4QueryFirmwareVersion invalidate];
    
    if (!(_timer4Auto.isValid)) {
        //不可用
        _timer4Auto = [NSTimer scheduledTimerWithTimeInterval:0.02f target:self selector:@selector(sendData4AutoMode) userInfo:nil repeats:YES];
        [_timer4Auto fire];
    }
    _currentControlMode = MODE_AUTO;
    [MBotManager setSpeedWithLeft:-75 andRight:75];
    [_instance.delegate controlModeChanged:_currentControlMode];
}

+ (void)setMode2Manual {
    if (_currentControlMode == MODE_MANUAL) {
        NSLog(@"_currentControlMode == MODE_MANUAL return");
        return;
    }
    NSLog(@"_currentControlMode ---> MODE_MANUAL");
    //停止其他timer
    [_timer4Auto invalidate];
    [_timer4Buzzer invalidate];
    [_timer4SpeedMax invalidate];
    [_timer4QueryFirmwareVersion invalidate];
    [_timer4Cruise invalidate];
    
    _currentControlMode = MODE_MANUAL;
    //延时0.3s
    [self performSelector:@selector(sendData4StopMBot) withObject:nil afterDelay:0.3f];
    [_instance.delegate controlModeChanged:_currentControlMode];
}

+ (void)setMode2Disconnected {
    if (_currentControlMode == MODE_DISCONNECTED) {
        NSLog(@"_currentControlMode == MODE_DISCONNECTED return");
        return;
    }
    NSLog(@"_currentControlMode ---> MODE_DISCONNECTED");
    //停止其他timer
    [_timer4Auto invalidate];
    [_timer4Buzzer invalidate];
    [_timer4SpeedMax invalidate];
    [_timer4QueryFirmwareVersion invalidate];
    [_timer4Cruise invalidate];
    
    _currentControlMode = MODE_DISCONNECTED;
    [MBotManager sendData4StopMBot];
    [_instance.delegate controlModeChanged:_currentControlMode];
    _currentIndex_Led_RGB = 0;
    _currentIndex_Buzzer_Hz = 0;
}

+ (void)setMode2Gravity {
    if (_currentControlMode == MODE_GYRO) {
        NSLog(@"_currentControlMode == MODE_GYRO return");
        return;
    }
    NSLog(@"_currentControlMode ---> MODE_GYRO");
    //停止其他timer
    [_timer4Auto invalidate];
    [_timer4Buzzer invalidate];
    [_timer4SpeedMax invalidate];
    [_timer4QueryFirmwareVersion invalidate];
    [_timer4Cruise invalidate];
    
    _currentControlMode = MODE_GYRO;
    [MBotManager sendData4StopMBot];
    [_instance.delegate controlModeChanged:_currentControlMode];
}

+ (void)setMode2SpeedMax {
    if (_currentControlMode == MODE_SPEED_MAX) {
        NSLog(@"_currentControlMode == MODE_SPEED_MAX return");
        return;
    }
    NSLog(@"_currentControlMode ---> MODE_SPEED_MAX");
    //停止其他timer
    [_timer4Auto invalidate];
    [_timer4Buzzer invalidate];
    [_timer4Cruise invalidate];
    [_timer4QueryFirmwareVersion invalidate];
    if (!(_timer4SpeedMax.isValid)) {
        //不可用
        //5s之后停止
        _timer4SpeedMax = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(sendData4StopSpeedMax) userInfo:nil repeats:NO];
    }
    
    _currentControlMode = MODE_SPEED_MAX;
    
    //auto／follow_line 模式切换到speedMax，需要延时
    [self performSelector:@selector(sendData4StartSpeedMax) withObject:nil afterDelay:0.3f];
    
    [_instance.delegate controlModeChanged:_currentControlMode];
}

+ (void)setMode2Shake {
    if (_currentControlMode == MODE_SHAKE) {
        NSLog(@"_currentControlMode == MODE_SHAKE return");
        return;
    }
    NSLog(@"_currentControlMode ---> MODE_SHAKE");
    //停止其他timer
    [_timer4Auto invalidate];
    [_timer4Buzzer invalidate];
    [_timer4SpeedMax invalidate];
    [_timer4QueryFirmwareVersion invalidate];
    [_timer4Cruise invalidate];
    
    [MBotManager sendData4StopMBot];
    _currentControlMode = MODE_SHAKE;
    [_instance.delegate controlModeChanged:_currentControlMode];
}

#pragma mark ------------七种模式的内部方法------------
+(void)sendData4CruiseMode {
    NSLog(@"## 读取巡线数据");
    int device = DEV_LINEFOLLOWER;
    int slot = 0;
    NSData *data = [MB_CmdUtils buildModuleReadWithDevice:device andPort:PORT_LINEFOLLOWER andSlot:slot andIndex:INDEX_CMD_CRUISE];
    [[BLECentralManager sharedManager].activePeripheral sendDataMandatory:data];
}

+(void)sendData4AutoMode {
    NSLog(@"读取超声波距离");
    NSData *data =[MB_CmdUtils buildModuleReadWithDevice:DEV_ULTRASOINIC andPort:PORT_ULTRASOINIC andSlot:0 andIndex:INDEX_CMD_ULTRASOINIC];
    [[BLECentralManager sharedManager].activePeripheral sendDataMandatory:data];
}

+(void)sendData4StartSpeedMax {
    [MBotManager setSpeedWithLeft:-255 andRight:255];
}

+(void)sendData4StopMBot {
    [MBotManager setSpeedWithLeft:0 andRight:0];
}

+(void)sendData4StopSpeedMax {
    //1.停止运动  2.切换到manual模式
    [MBotManager setSpeedWithLeft:0 andRight:0];
    [MBotManager setMode2Manual];
}

+(void)sendData4QueryFirmwareVersion {
    NSLog(@"查询固件版本");
    NSData *data = [MB_CmdUtils buildModuleQueryFirmwareVersion];
    [[BLECentralManager sharedManager].activePeripheral sendDataMandatory:data];
}

#pragma mark ------------BLE代理------------
-(void)bleStateChanged{
    NSLog(@"## MBotManager bleStateChanged");
}
-(void)bleConnected{
    NSLog(@"## MBotManager bleConnected");
    _currentControlMode = MODE_MANUAL;
    [_instance.delegate controlModeChanged:_currentControlMode];
    _timer4QueryFirmwareVersion = [NSTimer scheduledTimerWithTimeInterval:5.0f target:[MBotManager class] selector:@selector(sendData4QueryFirmwareVersion) userInfo:nil repeats:YES];
    [_timer4QueryFirmwareVersion fire];
}
-(void)bleDisconnected{
    NSLog(@"## MBotManager bleDisconnected");
    [MBotManager setMode2Disconnected];
    [_instance.delegate controlModeChanged:_currentControlMode];
}

union conv {
    float   f;
    Byte    b[4];
}   valFloat;

-(void)bleReceivedData:(NSData*)data {
    //    NSLog(@"## MBotManager bleReceivedData");
    Byte *byteData = (Byte*)malloc([data length]);
    memcpy(byteData, [data bytes], [data length]);
    NSLog(@"------------Start:打印数据------------");
    for (int i=0; i<[data length]; i++) {
        NSLog(@"data[%d]=%d",i,byteData[i]);
        
        buffer[index4Buffer] = byteData[i];
        index4Buffer++;
        
        if (byteData[i]==10) {
            NSLog(@"解析数据");
            //buffer中数据为一组，开始解析，然后清空数据
            //            NSLog(@"************Start************");
            //            for (int j=0; j<index4Buffer; j++) {
            //                NSLog(@"buffer[%d]=%d",j,buffer[j]);
            //            }
            //            NSLog(@"************Ends************");
            
            
            //1.OK码，清空数据。OK码:255 85 13 10
            if (index4Buffer==4 && buffer[0]==0xff && buffer[1]==0x55 && buffer[2]==13 && buffer[3]==10) {
                NSLog(@"是OK码 return");
                index4Buffer = 0;//清空缓存
                return;
            }
            
            //2.检验头尾 255 85 13 10  PS:index4Buffer多之行了一次++
            if(buffer[0]!=0xff || buffer[1]!=0x55 || buffer[index4Buffer-2]!=13 || buffer[index4Buffer-1]!=10){
                NSLog(@"检验头尾，无效 return");
                index4Buffer = 0;//清空缓存
                return;
            }
            
            //3.判断返回数据
            //3.1 版本查询
            if (buffer[2] == VERSION_INDEX) {
                //查询固件版本
                if(buffer[3]==4){
                    //06.01.030M  1.2.103
                    int len = buffer[4];
                    NSData  *aData = [[NSData alloc] initWithBytes:buffer+5 length:len];
                    NSString *firmwareVersion = [[NSString alloc] initWithData:aData encoding:NSUTF8StringEncoding];
                    if (firmwareVersion) {
                        _firmwareVersionStr = firmwareVersion;
                        //停止timer
                        [_timer4QueryFirmwareVersion invalidate];
                        NSLog(@"@@ firmwareVersion:%@",firmwareVersion);
                    }else{
                        NSLog(@"@@ Exception:firmwareVersion获取失败");
                    }
                }
                index4Buffer = 0;//清空缓存
                return;
            }
            
            //3.2 超声波sensor
            if (buffer[2] == INDEX_CMD_ULTRASOINIC) {
                valFloat.b[0] = buffer[4];
                valFloat.b[1] = buffer[5];
                valFloat.b[2] = buffer[6];
                valFloat.b[3] = buffer[7];
                if (valFloat.f<1) {
                    return;
                }
                float distance = valFloat.f;
                //                    NSLog(@"dis=%.1f",valFloat.f);
                
                if (distance<1 || distance>10) {
                    //                        NSLog(@"直行 测距:%f cm",distance);
                    [MBotManager setSpeedWithLeft:-205 andRight:205];
                    
                }else if(distance < 10){
                    //                        NSLog(@"原地右转 测距:%f cm",distance);
                    [MBotManager setSpeedWithLeft:-145 andRight:-145];//原地右转
                    //                        [self setSpeedWithLeftWheel:145 andRightWheel:145];//原地左转
                }
                index4Buffer = 0;
                return;
            }
            
            //3.3 巡线sensor
            if (buffer[2] == INDEX_CMD_CRUISE) {
                int sum = buffer[7]+buffer[6];
                if (sum==0) {
                    //                        NSLog(@"直行");
                    flag4Left = 0;
                    flag4Right = 0;
                    [self forward];
                }else if(sum==64){
                    //                        NSLog(@"右拐");
                    flag4Right++;
                    [self turnRightLittle];
                }else if(sum==128){
                    //                        NSLog(@"后退");
                    if (flag4Left==flag4Right) {
                        [self backForward];
                        
                    }else if (flag4Left>flag4Right) {
                        if (flag4Left>1) {
                            flag4Left--;
                        }
                        [self turnLeftExtreme];
                    }else {
                        if (flag4Right>1) {
                            flag4Right--;
                        }
                        [self turnRightExtreme];
                    }
                    
                }else if(sum==(63+128)){
                    //                        NSLog(@"左拐");
                    flag4Left++;
                    [self turnLeftLittle];
                }else{
                    //                        NSLog(@"未知");
                }
                index4Buffer = 0;//清空缓存
                return;
            }
        }
    }
}

#define BASE_SPEED (85)
-(void)turnLeftLittle {
    NSLog(@"turnLeftLittle");
    [MBotManager setSpeedWithLeft:-(BASE_SPEED-30) andRight:BASE_SPEED];
}
-(void)turnRightLittle {
    NSLog(@"turnRightLittle");
    [MBotManager setSpeedWithLeft:-BASE_SPEED andRight:(BASE_SPEED-30)];
}

-(void)turnLeftExtreme {
    NSLog(@"turnRightExtreme");
    [MBotManager setSpeedWithLeft:(BASE_SPEED-20) andRight:(BASE_SPEED-20)];
}
-(void)turnRightExtreme {
    NSLog(@"turnRightExtreme");
    [MBotManager setSpeedWithLeft:-(BASE_SPEED-20) andRight:-(BASE_SPEED-20)];
}
-(void)forward {
    NSLog(@"forward");
    [MBotManager setSpeedWithLeft:-BASE_SPEED andRight:BASE_SPEED];
}
-(void)backForward {
    NSLog(@"backForward");
    [MBotManager setSpeedWithLeft:BASE_SPEED andRight:-BASE_SPEED];
}

static MBotManager*_instance;
+(MBotManager *)sharedManager{
    if(_instance==nil){
        _instance = [[MBotManager alloc] init];
    }
    return _instance;
}

+ (int)currentControlMode {
    return _currentControlMode;
}
@end
