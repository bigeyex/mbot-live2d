//
//  MBotAutoConnector.m
//  mbot-live2d
//
//  Created by Wang Yu on 11/28/15.
//  Copyright © 2015 Makeblock. All rights reserved.
//

#import "MBotAutoConnector.h"
#import <Foundation/NSException.h>

@implementation MBotAutoConnector{
    bool _isConnected;
}

- (instancetype)init{
    self = [super init];
    
    if(self){
        _isConnected = false;
        [[BLECentralManager sharedManager] addDelegate:self];
        [[BLECentralManager sharedManager] startScanning];
//        [self performSelector:@selector(allowBLEToConnect) withObject:self afterDelay:6.0];
    }
    
    return self;
}

- (void)allowBLEToConnect{
    _isConnected = false;
}

- (void)bleConnected{
    NSLog(@"BLE Connected");
    _isConnected = true;
    [[BLECentralManager sharedManager] stopScanning];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TTSSpeak" object:@"机器人准备好了"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MBotConnected" object:nil];
}

- (void)bleDisconnected{
    [[BLECentralManager sharedManager] startScanning];
    _isConnected = false;
}

- (void)bleStateChanged{
    NSMutableArray<LMPeripheralBean*> *beanArray = [BLECentralManager sharedManager].lmPeripheralBeanMutArray;

    for(int i=0;i<beanArray.count;i++){
        if([beanArray[i].alias hasPrefix:@"Makeblock"]){        // 如果是跟mb有关的设备
            @try {
                if(!_isConnected){
                    [[BLECentralManager sharedManager] connectPeripheral:beanArray[i].peripheral];
                    _isConnected = true;
                }
            }
            @catch (NSException *exception){
                NSLog(@"connection failed");
            }
            return;
        }
    }
}

@end
