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

- (void)placeSimSimiRequest:(NSString*)question{
    NSString *urlString = [NSString stringWithFormat:@"http://www.tuling123.com/openapi/api?key=12dd0fc44298389dbc3b38faec8fd1a6&info=%@", [question stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSString *textResponse = [jsonDict objectForKey:@"text"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReceiveSimSimiResult" object:textResponse];
        
        busy = false;
    }];
    [task resume];
    busy = true;
}

@end
