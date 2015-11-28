//
//  MBTTSDelegate.m
//  mbot-live2d
//
//  Created by Wang Yu on 11/27/15.
//  Copyright © 2015 Makeblock. All rights reserved.
//

#import "MBTTSDelegate.h"

@implementation MBTTSDelegate{
    bool busy;
}

- (instancetype)init{
    self = [super init];
    if(self){
        _iFlySpeechSynthesizer = [IFlySpeechSynthesizer sharedInstance]; _iFlySpeechSynthesizer.delegate = self;
        [_iFlySpeechSynthesizer setParameter:[IFlySpeechConstant TYPE_CLOUD]
                                      forKey:[IFlySpeechConstant ENGINE_TYPE]];
        [_iFlySpeechSynthesizer setParameter:@"50" forKey: [IFlySpeechConstant VOLUME]];
        [_iFlySpeechSynthesizer setParameter:@"xiaokun" forKey: [IFlySpeechConstant VOICE_NAME]];
        [_iFlySpeechSynthesizer setParameter:@"tts.pcm" forKey: [IFlySpeechConstant TTS_AUDIO_PATH]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveSimSimiResult:) name:@"ReceiveSimSimiResult" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveSimSimiResult:) name:@"TTSSpeak" object:nil];
    }
    
    return self;
}

- (void)onReceiveSimSimiResult:(NSNotification*)note{
    [_iFlySpeechSynthesizer startSpeaking: note.object];
    busy = true;
}

- (void)onCompleted:(IFlySpeechError *)error{
    busy = false;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TTSSpeakFinished" object:nil];
}

- (void)onSpeakBegin{
    NSLog(@"===== start speaking ==-===");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TTSSpeakStarted" object:nil];
}

- (void)onBufferProgress:(int)progress message:(NSString *)msg{
    
}

- (void)onSpeakProgress:(int)progress{
    
}

@end
