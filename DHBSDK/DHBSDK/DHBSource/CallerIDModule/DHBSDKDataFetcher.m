//
//  DHBDataFetcher.m
//  CallerID
//
//  Created by Zhang Heyin on 15/8/18.
//  Copyright (c) 2015年 Yulore Inc. All rights reserved.
//

#import "DHBSDKDataFetcher.h"

#import "DHBSDKUpdateItem.h"
#import "DHBSDKOpenUDID.h"
#import "DHBSDKHTTPSessionManager.h"
#import "NSDictionary+DHBSDKSignature.h"
#import "DHBSDKCovertIndexContent.h"
#import "DHBSDKApiManager.h"

@interface DHBSDKDataFetcher()
@property (nonatomic, strong) NSMutableDictionary *parameters;
@property (nonatomic, strong) NSMutableDictionary *parametersFull;
@end
@implementation DHBSDKDataFetcher

+ (instancetype)sharedInstance {
  static DHBSDKDataFetcher *_sharedListFetcher = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedListFetcher = [[DHBSDKDataFetcher alloc] init];
  });
  
  return _sharedListFetcher;
}


/**
 apikey:mtyFwikuZ8ARgmwhljlidzxbevhrWrjL
 ver:1.1
 uid:123
 app:ios
 sig:17cc327af263c792cbf8d983729270cf
 debug:
 */
- (instancetype)init {
  self = [super init];
  if (self) {
    _parameters = [NSMutableDictionary dictionary];
    _parameters[@"apikey"] = [DHBSDKApiManager shareManager].apiKey;
    _parameters[@"ver"] = [self versionString];
    _parameters[@"uid"] = [self uid];
    _parameters[@"app"] = [self appName];
    _parameters[@"v"] = [self apiVersion];
    _parameters[@"flag_ver"] = [self dataVersion];
    _parameters[@"sig"] = [_parameters signature];
    
    
    _parametersFull = [NSMutableDictionary dictionary];
    _parametersFull[@"apikey"] = [DHBSDKApiManager shareManager].apiKey;
    _parametersFull[@"ver"] = [self versionString];
    _parametersFull[@"uid"] = [self uid];
    _parametersFull[@"app"] = [self appName];
    _parametersFull[@"v"] = [self apiVersion];
    _parametersFull[@"flag_ver"] = [self dataVersion];
    _parametersFull[@"sig"] = [_parametersFull signature];

  }
  return self;
  
}

/**
 *  api接口的版本
 *
 *  @return api接口的版本
 */
- (NSString *)apiVersion {
  return @"3";
}

/**
 *  app的版本
 *
 *  @return app的版本
 */
- (NSString *)versionString {
  NSString *ver = [NSString stringWithFormat:@"%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)@"CFBundleShortVersionString"]];
  return ver;
}



/**
 *  app的版本
 *
 *  @return app的版本
 */
- (NSString *)dataVersion {
  return [[NSString alloc] initWithFormat:@"%ld",[[DHBSDKCovertIndexContent sharedInstance] resolveDataFile].currentVersion];
//  return [DHBInitBusiness dateStringSetuped];
}

/**
 *  用户ID
 *
 *  @return 用户ID
 */
- (NSString *)uid {
  
  return [DHBSDKOpenUDID value];
}

/**
 *  app包名
 *
 *  @return com.yulore.callerid
 */
- (NSString *)appName {
  NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)@"CFBundleIdentifier"];
  return appName;
}


- (NSArray *)offlineData {
  NSData *data = [NSData dataWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"init.json" ofType:nil]];
    
    if (data==nil){
        return [[NSArray alloc] init];
    }
  NSError *error = nil;
  id result = [NSJSONSerialization JSONObjectWithData:data
                                              options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves
                                                error:&error];
  NSMutableArray *items = [[NSMutableArray alloc] init];
  NSArray *list = result[@"data"];
  for (id aData in list) {
    
    DHBSDKUpdateItem *aItem = [DHBSDKUpdateItem itemWithDictionary:aData];
    [items addObject:aItem];
    
  }
  
  return items;
}


- (void)dataFetcherCompletionHandler:(void (^)(DHBSDKUpdateItem *updateItem, NSError *error) )completionHandler {
  
  dispatch_queue_t q = dispatch_queue_create("com.dhbsdk.callerid.datafetcher", 0);
  dispatch_async(q, ^{
    _parameters[@"flag_ver"] = [self dataVersion];
    _parameters[@"sig"] = [_parameters signature];
    [[DHBSDKHTTPSessionManager sharedManager] dataWithParameters:_parameters URLString:@"chkdata/" completionHandler:^(NSDictionary *result, NSError *error) {
      
      if (result) {
        dispatch_async(dispatch_get_main_queue(), ^{
          DHBSDKUpdateItem *aItem = nil;
          if (result[@"flag"]) {
            aItem = [DHBSDKUpdateItem itemWithDictionary:result[@"flag"]];
          }
          completionHandler(aItem, error);
        });
      } else {
          completionHandler(nil, error);
      }
    }];
  });
  
  
}



@end


