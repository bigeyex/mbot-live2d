//
//  DeviceBean.h
//  Demo_bt3
//
//  Created by liuming on 14-8-28.
//  Copyright (c) 2014年 liuming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface LMPeripheralBean : NSObject

/**
 *  别名(用户重命名)，默认是peripheral.name
 */
@property(strong,nonatomic) NSString *alias;

@property(strong,nonatomic) NSNumber *RSSI;

@property(strong,nonatomic) CBPeripheral * peripheral;

/**
 *  返回物理距离：根据RSSI计算得到
 *
 *  @return 手机和mBot之间的物理距离
 */
-(float)distanceByRSSI;

@end
