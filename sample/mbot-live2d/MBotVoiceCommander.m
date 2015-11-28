//
//  MBotVoiceCommander.m
//  mbot-live2d
//
//  Created by Wang Yu on 11/28/15.
//  Copyright © 2015 Makeblock. All rights reserved.
//

#import "MBotVoiceCommander.h"


@implementation MBotVoiceCommander

- (instancetype)init{
    self = [super init];
    
    if(self){
        [[MBotManager sharedManager] setDelegate:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveVoiceCommand:) name:@"ReceiveRecognitionResult" object:nil];
        
    }
    
    return self;
}

- (void)onReceiveVoiceCommand:(NSNotification*)note{
    NSString *text = note.object;
    if([text containsString:@"过来"]){
        [MBotManager setSpeedWithLeft:-120 andRight:120];
        [self performSelector:@selector(stopMoving) withObject:self afterDelay:1];
    }
    else if([text containsString:@"回去"]){
        [MBotManager setSpeedWithLeft:120 andRight:-120];
        [self performSelector:@selector(stopMoving) withObject:self afterDelay:1];
    }
    else if([text containsString:@"拐弯"]){
        [MBotManager setSpeedWithLeft:120 andRight:120];
        [self performSelector:@selector(stopMoving) withObject:self afterDelay:1];
    }
    else if([text containsString:@"停"]){
        [MBotManager setSpeedWithLeft:0 andRight:0];
    }
}

- (void)stopMoving{
    [MBotManager setSpeedWithLeft:0 andRight:0];
}

- (void)controlModeChanged:(int)currentControlMode{
    
}

- (void)speedChangedWithLeft:(int)left andRight:(int)right{
    
}

@end
