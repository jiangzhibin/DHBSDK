//
//  NSString+MD5Check.m
//  Downloading
//
//  Created by Zhang Heyin on 15/8/10.
//  Copyright (c) 2015年 Yulore. All rights reserved.
//

#import "NSString+DHBSDKMD5Check.h"
#import "DHBSDKFilePaths.h"
#import "DHBSDKbspatchOC.h"
#import "DHBErrorHelper.h"
#import "DHBSDKFileHash.h"
#import "DHBSDKCommonType.h"

@implementation NSString (DHBSDKMD5Check)

- (BOOL)fileValidMD5WithMD5String:(NSString *)MD5String error:(NSError **)error {
  BOOL result = NO;
  NSString *deltaFileMD5 = [DHBSDKFileHash md5HashOfFileAtPath:self];
  
  if (deltaFileMD5 == nil) {
      NSString *info = [NSString stringWithFormat:@"File path %@ MD5 maybe not exist.", self];
      *error = [[NSError alloc] initWithDomain:DHBSDKMD5ValidErrorDomain
                                          code:DHBSDKDownloadErrorCodeMD5CheckInvalidError
                                      userInfo:@{@"description":info}];
  }
  else {
    if ([MD5String isEqualToString:deltaFileMD5]) {
      
      result = YES;
    }
    else {
      NSString *info = [NSString stringWithFormat:@"File path %@ MD5 invalid failed. %@ %@", self,MD5String,deltaFileMD5];
        *error = [[NSError alloc] initWithDomain:DHBSDKMD5ValidErrorDomain
                                            code:DHBSDKDownloadErrorCodeMD5CheckInvalidError
                                        userInfo:@{@"description":info}];
      
      result = NO;
    }
  }
  
  return result;
}

@end
