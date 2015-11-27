//
//  MBTTSDelegate.h
//  mbot-live2d
//
//  Created by Wang Yu on 11/27/15.
//  Copyright © 2015 Makeblock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iflyMSC/IFlySpeechConstant.h"
#import "iflyMSC/IFlySpeechSynthesizer.h"
#import "iflyMSC/IFlySpeechSynthesizerDelegate.h"

@interface MBTTSDelegate : NSObject<IFlySpeechSynthesizerDelegate>{
    IFlySpeechSynthesizer * _iFlySpeechSynthesizer;
}

@end
