//
//  DHBErrorHelper.m
//  SuperYellowPageSDK
//
//  Created by Zhang Heyin on 15/8/11.
//  Copyright (c) 2015年 Yulore. All rights reserved.
//

#import "DHBErrorHelper.h"
#import <UIKit/UIKit.h>

static NSString * const DHBCallerIDBSPatchErrorDomain = @"com.dhbsdk.callerid.bspatch";
static NSString * const DHBCallerIDMD5ValidErrorDomain = @"com.dhbsdk.callerid.md5invalid";
static NSString * const DHBCallerIDEnvironmentErrorDomain = @"com.dhbsdk.callerid.environment";


@implementation DHBErrorHelper

+ (NSError *)errorResponse:(NSInteger)statusCode {
  
  NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
  [errorDetail setValue:[NSString stringWithFormat:@"Response statusCode: %ld", statusCode] forKey:NSLocalizedDescriptionKey];
  
  
  
  NSError *error = [[NSError alloc] initWithDomain:NSURLErrorDomain
                                              code:statusCode
                                          userInfo:errorDetail];
  return error;
//  DHBSDKDLog(@"Response statusCode: %i", response.statusCode);
}

+ (NSError *)errorMD5ValidWithUserInfo:(NSDictionary *)userInfo {
  
  NSError *error = [[NSError alloc] initWithDomain:DHBCallerIDMD5ValidErrorDomain
                                              code:DHBCallerIDErrorCodeMD5CheckInvalidError
                                          userInfo:userInfo];

  return error;
}




+ (NSError *)errorWithBSPatchFailed {
  
  
  NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
  [errorDetail setValue:@"bspatch opeation failed." forKey:NSLocalizedDescriptionKey];
  
  
  NSError *error = [[NSError alloc] initWithDomain:DHBCallerIDBSPatchErrorDomain
                                              code:DHBCallerIDErrorCodeBSPatchError
                                          userInfo:errorDetail];
  
  return error;
}


+ (NSError *)errorWithBatteryLevel {
  
  
  NSError *error = nil;
  
  UIDevice *device = [UIDevice currentDevice];
  
  if ([[device model] isEqualToString:@"iPhone Simulator"]) {
    return nil;
  }
  
  
  
  [UIDevice currentDevice].batteryMonitoringEnabled = YES;
  float batteryLevel = [[UIDevice currentDevice] batteryLevel];
  if (batteryLevel > .1) {
    
  }
  else if (batteryLevel > 0) {
    NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
    [errorDetail setValue:@"Battery level check failed." forKey:NSLocalizedDescriptionKey];
    
    error = [[NSError alloc] initWithDomain:DHBCallerIDEnvironmentErrorDomain
                                       code:DHBCallerIDErrorCodeBatteryLevelError
                                   userInfo:errorDetail];
  }

  
  return error;
}
+ (NSError *)errorWithNetworkNotWiFi {
  NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
  [errorDetail setValue:@"Network not WiFi." forKey:NSLocalizedDescriptionKey];
  
  
  NSError *error = [[NSError alloc] initWithDomain:DHBCallerIDEnvironmentErrorDomain
                                              code:DHBCallerIDErrorCodeNetworkNotWiFiError
                                          userInfo:errorDetail];
  
  return error;
}

@end
