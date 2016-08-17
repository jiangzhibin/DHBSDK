//
//  NSString+Crypto.m
//  SuperYellowPageSDK
//
//  Created by Chope on 15/9/19.
//  Copyright (c) 2015年 Yulore. All rights reserved.
//

#import "NSString+DHBSDKCrypto.h"
#import <CommonCrypto/CommonCrypto.h>


@implementation NSString (DHBSDKCrypto)


- (NSString *)sha1String {

  uint8_t digest[CC_SHA1_DIGEST_LENGTH];
  
  CC_SHA1([self UTF8String], (CC_LONG)strlen([self UTF8String]), digest);
  
  NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
  
  for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
    [output appendFormat:@"%02x", digest[i]];
  
  return output;
  
}

@end
