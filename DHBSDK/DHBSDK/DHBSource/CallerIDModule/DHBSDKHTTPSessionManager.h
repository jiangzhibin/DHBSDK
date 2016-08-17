//
//  DHBHTTPSessionManager.h
//  CallerID
//
//  Created by Zhang Heyin on 15/8/18.
//  Copyright (c) 2015年 Yulore Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DHBSDKAFHTTPSessionManager.h"

@interface DHBSDKHTTPSessionManager : DHBSDKAFHTTPSessionManager
+ (DHBSDKHTTPSessionManager *)sharedManager;
- (NSURLSessionDataTask *)dataWithParameters:(NSDictionary *)parameters URLString:(NSString *)URLString completionHandler:(void (^)(id , NSError *))completionHandler;

@end
