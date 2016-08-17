//
//  DHBBSpatchOC.h
//  TestiOSBSPatch
//
//  Created by Zhang Heyin on 15/8/6.
//  Copyright (c) 2015年 Yulore. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 *  <#Description#>
 */
@interface DHBbspatchOC : NSObject
/**
 *  <#Description#>
 *
 *  @param oldFile           <#oldFile description#>
 *  @param newFile           <#newFile description#>
 *  @param patchFile         <#patchFile description#>
 *  @param completionHandler <#completionHandler description#>
 */
+ (void)DHBbspatchWithOldFile:(NSString *)oldFile
                      newFile:(NSString *)newFile
                    patchFile:(NSString *)patchFile
            completionHandler:(void (^)(NSError *error))completionHandler;
@end
