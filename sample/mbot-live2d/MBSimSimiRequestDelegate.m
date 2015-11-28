//
//  MBSimSimiRequestDelegate.m
//  mbot-live2d
//
//  Created by Wang Yu on 11/27/15.
//  Copyright © 2015 Makeblock. All rights reserved.
//

#import "MBSimSimiRequestDelegate.h"

@implementation MBSimSimiRequestDelegate{
    bool busy;
}


- (instancetype)init{
    self = [super init];
    if(self){
        busy = false;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveRecognitionResult:) name:@"ReceiveRecognitionResult" object:nil];
    }
    
    return self;
}

- (void)onReceiveRecognitionResult:(NSNotification*)notification{
    [self placeSimSimiRequest:[notification object]];
}

/**
 *  send a HTTP request for AI dialog response from services like SimSimi or Tuling.
 *
 *  @param question the question for AI to answer
 */
- (void)placeSimSimiRequest:(NSString*)question{
    NSString *urlString = [NSString stringWithFormat:@"http://www.tuling123.com/openapi/api?key=12dd0fc44298389dbc3b38faec8fd1a6&info=%@", [question stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
//    NSString *urlString = [NSString stringWithFormat:@"http://sandbox.api.simsimi.com/request.p?key=61490294-924d-4e15-81d8-a06573accb0b&lc=zh&ft=1.0&text=%@", [question stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSString *textResponse = [jsonDict objectForKey:@"text"];                   // for tuling
//        NSString *textResponse = [jsonDict objectForKey:@"response"];             // for simsimi
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReceiveSimSimiResult" object:textResponse];
        
        busy = false;
    }];
    [task resume];
    busy = true;
}

@end
