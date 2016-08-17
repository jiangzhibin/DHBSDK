//
//  DHBBSpatchOC.m
//  TestiOSBSPatch
//
//  Created by Zhang Heyin on 15/8/6.
//  Copyright (c) 2015年 Yulore. All rights reserved.
//

#import "DHBSDKbspatchOC.h"
#import  "DHBSDKBSpatch.h"
#import "DHBErrorHelper.h"
#import "Commondef.h"
@implementation DHBbspatchOC


+ (void)DHBbspatchWithOldFile:(NSString *)oldFile
                      newFile:(NSString *)newFile
                    patchFile:(NSString *)patchFile
            completionHandler:(void (^)(NSError *error))completionHandler {
  __block int returnValue = -1;
  
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{ // 1
    clock_t start, finish;
    double  duration;
    /* 测量一个事件持续的时间*/
    start = clock();

    returnValue = bspatch([oldFile UTF8String], [newFile UTF8String], [patchFile UTF8String]);

    finish = clock();
    duration = (double)(finish - start) / CLOCKS_PER_SEC;
    DHBSDKDLog( @"bspatch %f seconds\n", duration );
    dispatch_async(dispatch_get_main_queue(), ^{ // 2
      NSError *error = nil;
      
      
      /**
       *  returnValue == 0 suc
       */
      if (returnValue != 0) {
        error = [DHBErrorHelper errorWithBSPatchFailed];
      }

     completionHandler(error);
      
    });
    
  });
}

@end
