//
//  ResolveFecher.m
//  TestMuti1
//
//  Created by Zhang Heyin on 15/3/10.
//  Copyright (c) 2015年 Yulore. All rights reserved.
//

#import "DHBSDKResolveFecherNew.h"
#import "DHBSDKOpenUDID.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#import "DHBSDKSignatureHelper.h"
#import "DHBSDKYuloreAPIClient.h"
#import "DHBSDKApiManager.h"
@interface DHBSDKResolveFecherNew ()
@property (nonatomic, strong) NSMutableDictionary *parameters;

@property (nonatomic, copy) NSString *telephoneNumber;


@end
@implementation DHBSDKResolveFecherNew

+ (DHBSDKResolveFecherNew *)sharedResolveFecherNew {
  static DHBSDKResolveFecherNew *_sharedResolveFecher = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedResolveFecher = [[DHBSDKResolveFecherNew alloc] init];
  });
  
  return _sharedResolveFecher;
}

- (NSString *)getIPAddress {
  NSString *address = @"error";
  struct ifaddrs *interfaces = NULL;
  struct ifaddrs *temp_addr = NULL;
  int success = 0;
  // retrieve the current interfaces - returns 0 on success
  success = getifaddrs(&interfaces);
  if (success == 0) {
    // Loop through linked list of interfaces
    temp_addr = interfaces;
    while(temp_addr != NULL) {
      if(temp_addr->ifa_addr->sa_family == AF_INET) {
        // Check if interface is en0 which is the wifi connection on the iPhone
        if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"] ||
           [[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"pdp_ip0"]) {
          // Get NSString from C String
          address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
        }
      }
      temp_addr = temp_addr->ifa_next;
    }
  }
  // Free memory
  freeifaddrs(interfaces);
  return address;
  
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _parameters = [NSMutableDictionary dictionary];
    _parameters[@"uid"] = [DHBSDKOpenUDID value];//@"99000567710378";
    _parameters[@"uip"] = [self getIPAddress];
    _parameters[@"tel"] = @"";
    _parameters[@"apikey"] = [DHBSDKApiManager shareManager].apiKey;//@"mgBkfHsubhpahKfZpxcPi7HMWr0nsahd";
    _parameters[@"sig"] = @"";

  }
  
  return self;
}




- (void)resolveFectcherWithTelephoneNumber:(NSString *)telephoneNumber completionHandler:(void (^)( DHBSDKResolveItemNew *resolveItem, NSError *error) )completionHandler {
    NSError *error = nil;
    if (![DHBSDKResolveFecherNew canResolveNumber:telephoneNumber error:&error]) {
        if (completionHandler) {
            completionHandler(nil, error);
        }
    }
    else {
        self.telephoneNumber = telephoneNumber;
        _parameters[@"ver"] = [NSString stringWithFormat:@"%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)@"CFBundleShortVersionString"]];
        [[DHBSDKYuloreAPIClient sharedClient] resolveTelenumberWithParameters:_parameters completionHandler:^(DHBSDKResolveItemNew *resolveItem, NSError *error) {
            if (resolveItem ) {
                
                if ( [resolveItem.location length] > 0 || [resolveItem.flagInfo length] > 0 || [resolveItem.teleNumber length] > 0) {
                    if (completionHandler) {
                        completionHandler(resolveItem, error);
                    }
                }
                else {
                    
                    NSError *error = [[NSError alloc] initWithDomain:@"resolve null" code:10003 userInfo:nil];
                    if (completionHandler) {
                        completionHandler(nil, error);
                    }
                }
            }
            else {
                if (completionHandler) {
                    completionHandler(resolveItem,error);
                }
            }
        }];
    }
}



- (void)setTelephoneNumber:(NSString *)telephoneNumber {
  _telephoneNumber =  telephoneNumber;
  
  _parameters[@"tel"] = telephoneNumber;
  _parameters[@"sig"] = [DHBSDKSignatureHelper resolveSignature:telephoneNumber];

}

+ (BOOL)canResolveNumber:(NSString *)telenumber error:(NSError **)error {
    
    NSMutableCharacterSet *set = [[[NSMutableCharacterSet decimalDigitCharacterSet] invertedSet] mutableCopy];
    
    telenumber = [[telenumber componentsSeparatedByCharactersInSet:set] componentsJoinedByString: @""];
    telenumber = [NSString stringWithFormat:@"%@",telenumber];
    telenumber = [self telenumberWithBefore:telenumber];
    
    if ([telenumber length] >= 13) {
        *error = [NSError errorWithDomain:@"Number Length >= 13" code:10001 userInfo:nil];
        return NO;
    }
    
    return telenumber.length == 0 ? NO : YES;
}


+ (NSString *)telenumberWithBefore:(NSString *)tel {
    if ([tel length] == 13 && [tel rangeOfString:@"86"].location == 0) {
        tel =  [tel stringByReplacingCharactersInRange:NSMakeRange(0, 2) withString:@""];
    }
    
    return tel;
}

@end
