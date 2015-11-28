//
//  DeviceBean.m
//  Demo_bt3
//
//  Created by liuming on 14-8-28.
//  Copyright (c) 2014年 liuming. All rights reserved.
//

#import "LMPeripheralBean.h"


@implementation LMPeripheralBean

-(float)distanceByRSSI {
    if (self.RSSI) {
        return powf(10.0,((abs(self.RSSI.intValue)-50.0)/50.0))*0.7;
    }
    return -1.0f;
}
-(NSString *)description {
    return [NSString stringWithFormat:@"alias=%@,name=%@,distance=%.1f",self.alias,self.peripheral.name,[self distanceByRSSI]];
}
@end
