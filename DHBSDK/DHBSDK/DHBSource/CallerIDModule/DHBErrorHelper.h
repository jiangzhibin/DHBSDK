//
//  DHBErrorHelper.h
//  SuperYellowPageSDK
//
//  Created by Zhang Heyin on 15/8/11.
//  Copyright (c) 2015年 Yulore. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, DHBCallerIDErrorCode) {
  DHBCallerIDErrorCodeMD5CheckInvalidError = 9000,
  DHBCallerIDErrorCodeBSPatchError,
  DHBCallerIDErrorCodeBatteryLevelError,
  DHBCallerIDErrorCodeNetworkNotWiFiError,
};

@interface DHBErrorHelper : NSObject
//  
+ (NSError *)errorResponse:(NSInteger)statusCode;

+ (NSError *)errorMD5ValidWithUserInfo:(NSDictionary *)userInfo;
+ (NSError *)errorWithBSPatchFailed;
+ (NSError *)errorWithBatteryLevel;
+ (NSError *)errorWithNetworkNotWiFi;

@end
