//
//  YuloreAPIClient.m
//  TestMuti1
//
//  Created by Zhang Heyin on 15/2/8.
//  Copyright (c) 2015年 Yulore. All rights reserved.
//
#import "CommonTmp.h"
#import "Commondef.h"
#import "DHBSDKYuloreAPIClient.h"

@implementation DHBSDKYuloreAPIClient
+ (DHBSDKYuloreAPIClient *)sharedClient {
  static DHBSDKYuloreAPIClient *_sharedClient = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    NSURL *baseURL = [NSURL URLWithString:[DHBSDKApiManager shareManager].host];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    //  [config setHTTPAdditionalHeaders:@{ @"User-Agent" : @"TuneStore iOS 1.0"}];
    
    NSURLCache *cache = [[NSURLCache alloc] initWithMemoryCapacity:10 * 1024 * 1024
                                                      diskCapacity:50 * 1024 * 1024
                                                          diskPath:nil];
    
    [config setURLCache:cache];
    [_sharedClient.requestSerializer setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    
    _sharedClient = [[DHBSDKYuloreAPIClient alloc] initWithBaseURL:baseURL
                                              sessionConfiguration:config];
    _sharedClient.responseSerializer = [DHBSDKAFJSONResponseSerializer serializer];
  });
  
  return _sharedClient;
}





- (id)initWithBaseURL:(NSURL *)url {
  self = [super initWithBaseURL:url];
  if (!self) {
    return nil;
  }
  return self;
  
}
//  [self res]
//  [self registerHTTPOperationClass:[YuloreAFJSONRequestOperation class]];
//  
//  // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
//  [self setDefaultHeader:@"Accept" value:@"application/json"];
//  
//  // By default, the example ships with SSL pinning enabled for the app.net API pinned against the public key of adn.cer file included with the example. In order to make it easier for developers who are new to AFNetworking, SSL pinning is automatically disabled if the base URL has been changed. This will allow developers to hack around with the example, without getting tripped up by SSL pinning.
//  //    if ([[url scheme] isEqualToString:@"https"] && [[url host] isEqualToString:@"alpha-api.app.net"]) {
//  //        self.defaultSSLPinningMode = AFSSLPinningModePublicKey;
//  //    } else {
//  //        self.defaultSSLPinningMode = AFSSLPinningModeNone;
//  //    }
//  
//  return self;
//}

- (void)listWithParameters:(NSDictionary *)parameters completionHandler:( void (^)(NSMutableDictionary *results, NSError *error) )completionHandler  {
  
//  NSMutableDictionary *para = [parameters mutableCopy];
//  
//  para[@"ver"] = [NSString stringWithFormat:@"%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)@"CFBundleShortVersionString"]];
  
  [self GET:@"list/" parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        DHBSDKDLog(@"%@", task.response.URL);
    if (httpResponse.statusCode == 200 && [responseObject[@"status"] integerValue] == 0) {
      dispatch_async(dispatch_get_main_queue(), ^{
        completionHandler(responseObject, nil);
        //DHBSDKDLog(@"%@", responseObject);
      });
    } else {
      dispatch_async(dispatch_get_main_queue(), ^{
        NSError *error = [NSError errorWithDomain:@"DIAN HUA BANG ERROR" code:[responseObject[@"status"] integerValue] userInfo:responseObject];
        completionHandler(nil, error);
        DHBSDKDLog(@"%@", responseObject);
      });
      //  DLog(@"Received: %@", responseObject);
      DHBSDKDLog(@"Received HTTP %ld", (long)httpResponse.statusCode);
    }

  } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
    dispatch_async(dispatch_get_main_queue(), ^{
      //   completion(nil, error);
      DHBSDKDLog(@"%@", error);
    });
  }];

}





- (void)categoriesWithCityID:(NSString *)cityID completionHandler:( void (^)(NSMutableDictionary *results, NSError *error) )completionHandler {
  
  NSString *ver = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)@"CFBundleShortVersionString"];
  NSString * uid = [DHBSDKOpenUDID value];
  NSString *apiKey = [DHBSDKApiManager shareManager].apiKey;
  NSDictionary *parameters = @{ @"city_id" : cityID,
                         @"ver" : ver,
                         @"uid" : uid,
                         @"apikey" : apiKey};

  [self GET:@"category/" parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
    if (httpResponse.statusCode == 200 && [responseObject[@"status"] integerValue] == 0) {
      dispatch_async(dispatch_get_main_queue(), ^{
        completionHandler(responseObject, nil);
        //DHBSDKDLog(@"%@", responseObject);
      });
    } else {
      dispatch_async(dispatch_get_main_queue(), ^{
        NSError *error = [NSError errorWithDomain:@"DIAN HUA BANG ERROR" code:[responseObject[@"status"] integerValue] userInfo:responseObject];
        completionHandler(nil, error);
        DHBSDKDLog(@"%@", responseObject);
      });
      //  DHBSDKDLog(@"Received: %@", responseObject);
      DHBSDKDLog(@"Received HTTP %ld", (long)httpResponse.statusCode);
    }
    
  } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
    dispatch_async(dispatch_get_main_queue(), ^{
      completionHandler(nil, error);
      DHBSDKDLog(@"%@", error);
    });
  }];
}



- (NSString *)formatDateString {
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
  dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT+0000"];
  [dateFormatter setDateFormat:@"yyyy-MM-dd"];
  
  return [dateFormatter stringFromDate:[NSDate date]];
}
- (void)resolveTelenumberWithParameters:(NSDictionary *)parameters completionHandler:( void (^)(DHBSDKResolveItemNew *resolveItem, NSError *error) )completionHandler {
  
  [self GET:@"resolvetel/" parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
    if (httpResponse.statusCode == 200 && [responseObject[@"status"] integerValue] == 0) {
      dispatch_async(dispatch_get_main_queue(), ^{
        DHBSDKResolveItemNew *item = [[DHBSDKResolveItemNew alloc] initWithDictionary:responseObject];
        item.flagDate = [self formatDateString];
          if (completionHandler) {
              completionHandler(item, nil);
          }
      });
    } else {
      dispatch_async(dispatch_get_main_queue(), ^{
          if (completionHandler) {
              completionHandler(nil,nil);
          }
      });
    }
  } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (completionHandler) {
            completionHandler(nil, error);
        }
    });
  }];

    
}




@end
