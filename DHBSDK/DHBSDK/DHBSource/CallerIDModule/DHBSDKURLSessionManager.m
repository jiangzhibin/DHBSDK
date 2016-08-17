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
        manager = [DHBSDKURLSessionManager new];
    });
    return manager;
}

@end
