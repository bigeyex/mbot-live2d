/**
 *
 *  You can modify and use this source freely
 *  only for the development of application related Live2D.
 *
 *  (c) Live2D Inc. All rights reserved.
 */

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "iflyMSC/iflyMSC.h"

@interface ViewController : GLKViewController

@property (nonatomic,strong) NSObject *voiceRecognizer;
@property (nonatomic,strong) NSObject *voiceRSynthesizer;
@property (nonatomic,strong) NSObject *simSimiRequestDelegate;

@end
