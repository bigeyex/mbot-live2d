//
//  MBRecognizerDelegate.m
//  mbot-live2d
//
//  Created by Wang Yu on 11/27/15.
//  Copyright © 2015 Makeblock. All rights reserved.
//

#import "MBRecognizerDelegate.h"
#import "ISRDataHelper.h"
#import "IATConfig.h"

@implementation MBRecognizerDelegate
{
    IFlySpeechRecognizer *_iFlySpeechRecognizer;
    bool busy;
}

- (instancetype)init{
    self = [super init];
    if(self){
        busy = false;
        self.uploader = [[IFlyDataUploader alloc] init];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cachePath = [paths objectAtIndex:0];
        _pcmFilePath = [[NSString alloc] initWithFormat:@"%@",[cachePath stringByAppendingPathComponent:@"asr.pcm"]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSpeakFinished:) name:@"TTSSpeakFinished" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSpeakStarted:) name:@"TTSSpeakStarted" object:nil];

        [self initRecognizer];
        
        [self startRecognizing];
    }
    
    return self;
}

- (void)onError:(IFlySpeechError *)errorCode{
    [self startRecognizing];
}

- (void)dealloc{
    [_iFlySpeechRecognizer cancel]; //取消识别
    [_iFlySpeechRecognizer setDelegate:nil];
    [_iFlySpeechRecognizer setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
    
    [super dealloc];
}

- (void)onSpeakFinished:(NSNotification*)notification{
    busy = false;
    [_iFlySpeechRecognizer startListening];
}

- (void)onSpeakStarted:(NSNotification*)notification{
    busy = true;
    [_iFlySpeechRecognizer stopListening];
}

- (void)onResults:(NSArray *)results isLast:(BOOL)isLast{
    if(!busy){
        NSMutableString *resultString = [[NSMutableString alloc] init];
        NSDictionary *dic = results[0];
        for (NSString *key in dic) {
            [resultString appendFormat:@"%@",key];
        }
        _result =[NSString stringWithFormat:@"%@",resultString];
        NSString * resultFromJson =  [ISRDataHelper stringFromJson:resultString];
        
        if (isLast){
            NSLog(@"听写结果(json)：%@测试",  self.result);
        }
        NSLog(@"_result=%@",_result);
        NSLog(@"resultFromJson=%@",resultFromJson);
        busy = true;
        if(![resultFromJson isEqualToString:@""]){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ReceiveRecognitionResult" object:resultFromJson];
        }
    }
}

- (void)onBeginOfSpeech{
    NSLog(@"正在录音");
}

- (void)onEndOfSpeech{
    NSLog(@"停止录音");
}

- (void)startRecognizing{
    self.isCanceled = NO;
    
    if(_iFlySpeechRecognizer == nil)
    {
        [self initRecognizer];
    }
    
    [_iFlySpeechRecognizer cancel];
    
    //设置音频来源为麦克风
    [_iFlySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
    
    //设置听写结果格式为json
    [_iFlySpeechRecognizer setParameter:@"json" forKey:[IFlySpeechConstant RESULT_TYPE]];
    
    //保存录音文件，保存在sdk工作路径中，如未设置工作路径，则默认保存在library/cache下
//    [_iFlySpeechRecognizer setParameter:@"asr.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
    
    [_iFlySpeechRecognizer setDelegate:self];
    
    [_iFlySpeechRecognizer startListening];
    

}

- (void)initRecognizer{
    //单例模式，无UI的实例
    if (_iFlySpeechRecognizer == nil) {
        _iFlySpeechRecognizer = [IFlySpeechRecognizer sharedInstance];
        
        [_iFlySpeechRecognizer setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
        
        //设置听写模式
        [_iFlySpeechRecognizer setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
    }
    _iFlySpeechRecognizer.delegate = self;
    
    if (_iFlySpeechRecognizer != nil) {
        IATConfig *instance = [IATConfig sharedInstance];
        
        //设置最长录音时间
        [_iFlySpeechRecognizer setParameter:@"3000000" forKey:[IFlySpeechConstant SPEECH_TIMEOUT]];
        //设置后端点
        [_iFlySpeechRecognizer setParameter:instance.vadEos forKey:[IFlySpeechConstant VAD_EOS]];
        //设置前端点
        [_iFlySpeechRecognizer setParameter:instance.vadBos forKey:[IFlySpeechConstant VAD_BOS]];
        //网络等待时间
        [_iFlySpeechRecognizer setParameter:@"20000" forKey:[IFlySpeechConstant NET_TIMEOUT]];
        
        //设置采样率，推荐使用16K
        [_iFlySpeechRecognizer setParameter:instance.sampleRate forKey:[IFlySpeechConstant SAMPLE_RATE]];
        
        if ([instance.language isEqualToString:[IATConfig chinese]]) {
            //设置语言
            [_iFlySpeechRecognizer setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
            //设置方言
            [_iFlySpeechRecognizer setParameter:instance.accent forKey:[IFlySpeechConstant ACCENT]];
        }else if ([instance.language isEqualToString:[IATConfig english]]) {
            [_iFlySpeechRecognizer setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
        }
        //设置是否返回标点符号
        [_iFlySpeechRecognizer setParameter:0 forKey:[IFlySpeechConstant ASR_PTT]];
        
    }

}


@end
