//
//  NSDictionary+DHBSignature.m
//  CallerID
//
//  Created by Zhang Heyin on 15/8/18.
//  Copyright (c) 2015年 Yulore Inc. All rights reserved.
//

#import "NSDictionary+DHBSDKSignature.h"

#define kPassword @"nsFwF52FnwvbdjynaqmfKlyb7Tq8eqAlqKhyXoWBvkvag0H1zKFFETY6Ez4saafzTxsqpuRnm4SQaqdKj4khxFAkbaxppCJidgQw2ojFpm4WpUutqcpNuPoFad0xcpZwrgxizszkthcmxq1brXtozwCpDm5xcoTCygLdu"
#import <CommonCrypto/CommonCrypto.h>
@implementation NSDictionary (DHBSDKSignature)
- (NSString *)signature {

  NSString *dataVersion = [self objectForKey:@"data_ver"];
  NSString *uid = [self objectForKey:@"uid"];
  NSString *appName = [self objectForKey:@"app"];
  NSString *apiVersion = [self objectForKey:@"v"];
  NSString *version = [self objectForKey:@"ver"];
  NSString *OSversion = @"";
  
  NSMutableArray *subArray = [self arrayWithSubPassword];
  
  //substr($pwd,53,2).
  //$data_ver.
  //substr($pwd,55,4).
  //$uid.
  //substr($pwd,59,3).
  //$app.
  //substr($pwd,62,1).
  //$ver.
  //substr($pwd,63,3).
  //$api_ver.
  //substr($pwd,66,3).
  //$os_ver.
  //substr($pwd,69,2)

  NSString *sig = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@", subArray[0], dataVersion, subArray[1], uid, subArray[2], appName, subArray[3], version, subArray[4], apiVersion, subArray[5], OSversion, subArray[6]];
  
  NSString *sha1String = sha1(sig.UTF8String); //

  return [sha1String substringWithRange:NSMakeRange(1, 32)];
}
- (NSMutableArray *)arrayWithSubPassword {
  NSRange range[7];
  range[0] = NSMakeRange(53, 2);
  range[1] = NSMakeRange(55, 4);
  range[2] = NSMakeRange(59, 3);
  range[3] = NSMakeRange(62, 1);
  range[4] = NSMakeRange(63, 3);
  range[5] = NSMakeRange(66, 3);
  range[6] = NSMakeRange(69, 2);
  
  NSMutableArray *array = [[NSMutableArray alloc] init];
  for (int i = 0; i < 7; i++) {
    NSString *sub = [kPassword substringWithRange:range[i]];
    [array addObject:sub];
  }
  
  
  return array;
}



NSString * sha1(const char *string) {
  static const NSUInteger LENGTH = 20;
  unsigned char result[LENGTH];
  CC_SHA1(string, (CC_LONG)strlen(string), result);
  
  char hexResult[2 * LENGTH + 1];
  hexString(result, hexResult, LENGTH);
  
  return [NSString stringWithUTF8String:hexResult];
}

static inline char hexChar(unsigned char c) {
  return c < 10 ? '0' + c : 'a' + c - 10;
}

static inline void hexString(unsigned char *from, char *to, NSUInteger length) {
  for (NSUInteger i = 0; i < length; ++i) {
    unsigned char c = from[i];
    unsigned char cHigh = c >> 4;
    unsigned char cLow = c & 0xf;
    to[2 * i] = hexChar(cHigh);
    to[2 * i + 1] = hexChar(cLow);
  }
  to[2 * length] = '\0';
}

@end
