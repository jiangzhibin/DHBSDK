//
//  DHBHTTPSessionManager.m
//  CallerID
//
//  Created by Zhang Heyin on 15/8/18.
//  Copyright (c) 2015年 Yulore Inc. All rights reserved.
//

#import "DHBSDKHTTPSessionManager.h"
#import "DHBSDKApiManager.h"

@implementation DHBSDKHTTPSessionManager

+ (DHBSDKHTTPSessionManager *)sharedManager {
  static DHBSDKHTTPSessionManager *_sharedClient = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    NSURL *baseURL = [NSURL URLWithString:[DHBSDKApiManager shareManager].host];
    
//    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
//    //  [config setHTTPAdditionalHeaders:@{ @"User-Agent" : @"TuneStore iOS 1.0"}];
//    
//    NSURLCache *cache = [[NSURLCache alloc] initWithMemoryCapacity:10 * 1024 * 1024
//                                                      diskCapacity:50 * 1024 * 1024
//                                                          diskPath:nil];
//    
//    [config setURLCache:cache];
    
    _sharedClient = [[DHBSDKHTTPSessionManager alloc] initWithBaseURL:baseURL
                                              sessionConfiguration:nil];
    _sharedClient.responseSerializer = [DHBSDKAFJSONResponseSerializer serializer];
  });
  
  return _sharedClient;
}


- (NSURLSessionDataTask *)dataWithParameters:(NSDictionary *)parameters URLString:(NSString *)URLString completionHandler:(void (^)(id , NSError *))completionHandler {
  
  NSURLSessionDataTask *task = [self GET:URLString parameters:parameters
                                 success:^(NSURLSessionDataTask *task, id responseObject) {
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
    
    if (httpResponse.statusCode == 200) {
      dispatch_async(dispatch_get_main_queue(), ^{

        completionHandler(responseObject, nil);
        NSLog(@"Received: %@", httpResponse.URL);

        NSLog(@"Received: %@", responseObject);
        NSLog(@"Received HTTP %ld", (long)httpResponse.statusCode);

      });
    }
    else {
      dispatch_async(dispatch_get_main_queue(), ^{
          completionHandler(nil, nil);
        NSLog(@"%@", responseObject);
      });
      NSLog(@"Received: %@", responseObject);
      NSLog(@"Received HTTP %ld", (long)httpResponse.statusCode);
    }
    
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    dispatch_async(dispatch_get_main_queue(), ^{
         completionHandler(nil, error);
      NSLog(@"%@", error);
    });
  }];
  NSLog(@"%@", task);
  return task;
}
@end
