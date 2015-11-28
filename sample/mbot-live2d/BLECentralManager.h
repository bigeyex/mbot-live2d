//
//  bleCentralManager.h
//  MonitoringCenter
//
//  Created by David ding on 13-1-10.
//
//

#import <CoreBluetooth/CoreBluetooth.h>
#import "BLEPeripheral.h"
#import "BLEControllerDelegate.h"
#import "LMPeripheralBean.h"

//==============================================

@interface BLECentralManager : NSObject
//======================================================
// CBCentralManager
@property(strong, nonatomic)    CBCentralManager        *activeCentralManager;
//======================================================
// NSMutableArray
@property(strong, nonatomic)    NSMutableArray          *peripherals;            // blePeripheral
@property(strong, nonatomic)    NSMutableDictionary     *rssiDict;            // blePeripheral
@property(strong, nonatomic)    BLEPeripheral           *activePeripheral;            // blePeripheral
//======================================================
// Property
@property(readonly)             NSUInteger              currentCentralManagerState;
//======================================================

// method
-(void)startScanning;
-(void)stopScanning;
-(void)resetScanning;

-(void)addDelegate:(id<BLEControllerDelegate>)delegate;
-(void)removeDelegate:(id<BLEControllerDelegate>)delegate;

-(void)connectPeripheral:(CBPeripheral*)peripheral;
-(void)disconnectPeripheral:(CBPeripheral*)peripheral;
+(BLECentralManager*)sharedManager;

/**
 *  搜索到的Peripheral所封装的LMPeripheralBean的数组
 *  add by liuming@15.5.26
 */
@property(strong, nonatomic) NSMutableArray  *lmPeripheralBeanMutArray;

/**
 *  peripheral的identifier和alias的字典  k=identifier  v=alias
 */
@property(strong, nonatomic) NSMutableDictionary *identifierAndAliasDic;

/**
 *  对mBot重命名
 *
 *  @param identifier peripheral的identifier
 *  @param alias      别名
 */
-(void)renameWithIdentifier:(NSString *)identifier andAlias:(NSString *)alias;

/**
 *  获取identifier对应的alias
 *
 *  @param identifier
 *
 *  @return 没有记录，返回nil
 */
-(NSString *)getAliasWithIdentifier:(NSString *)identifier;


@end


