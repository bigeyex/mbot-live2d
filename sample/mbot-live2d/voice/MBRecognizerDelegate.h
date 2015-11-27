//
//  MBRecognizerDelegate.h
//  mbot-live2d
//
//  Created by Wang Yu on 11/27/15.
//  Copyright © 2015 Makeblock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iflyMSC/IFlyDataUploader.h"
#import "iflyMSC/IFlySpeechConstant.h"
#import "iflyMSC/IFlySpeechRecognizer.h"
#import "iflyMSC/IFlySpeechRecognizerDelegate.h"

@interface MBRecognizerDelegate : NSObject<IFlySpeechRecognizerDelegate>

@property (nonatomic, strong) NSString *pcmFilePath;//音频文件路径
@property (nonatomic, strong) IFlySpeechRecognizer *iFlySpeechRecognizer;//不带界面的识别对象
@property (nonatomic, strong) IFlyDataUploader *uploader;//数据上传对象

@property (nonatomic, strong) NSString * result;
@property (nonatomic, assign) BOOL isCanceled;

@end
