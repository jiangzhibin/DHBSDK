//
//  YuloreAPIClient.h
//  TestMuti1
//
//  Created by Zhang Heyin on 15/2/8.
//  Copyright (c) 2015年 Yulore. All rights reserved.
//

#import "DHBSDKAPIDotDianHuaDotCNClient.h"
#import "DHBSDKResolveItemNew.h"
@interface DHBSDKYuloreAPIClient : DHBSDKAPIDotDianHuaDotCNClient
//- (NSURLSessionDataTask *)categoriesWithCityID:(NSString *)cityID completionHandler:( void (^)(NSArray *results, NSError *error) )completionHandler;
//- (NSURLSessionDataTask *)listWithParameters:(NSDictionary *)parameters completionHandler:( void (^)(NSArray *results, NSError *error) )completionHandler;
+ (DHBSDKYuloreAPIClient *)sharedClient;
- (void)listWithParameters:(NSDictionary *)parameters completionHandler:( void (^)(NSMutableDictionary *results, NSError *error) )completionHandler;
- (void)categoriesWithCityID:(NSString *)cityID completionHandler:( void (^)(NSMutableDictionary *results, NSError *error) )completionHandler;
- (void)resolveTelenumberWithParameters:(NSDictionary *)parameters completionHandler:( void (^)(DHBSDKResolveItemNew *resolveItem, NSError *error) )completionHandler;
@end
