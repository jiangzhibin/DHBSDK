//
//  DHBSDKURLSessionManager.m
//  DHBDemo
//
//  Created by 蒋兵兵 on 16/8/16.
//  Copyright © 2016年 蒋兵兵. All rights reserved.
//

#import "DHBSDKURLSessionManager.h"

@implementation DHBSDKURLSessionManager

+ (instancetype)shareManager {
    static DHBSDKURLSessionManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *config;
        NSString *identifier = @"com.dhbsdk.dhbsdkurlsessionmanager";
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
            config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:identifier];
        }
        else {
            config = [NSURLSessionConfiguration backgroundSessionConfiguration:identifier];
        }
        manager = [[DHBSDKURLSessionManager alloc] initWithSessionConfiguration:config];
    });
    return manager;
}

@end
