//
//  NSDictionary+Offset.h
//  DianHuaBang
//
//  Created by Zhang Heyin on 13-8-1.
//  Copyright (c) 2013年 Yulore. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (DHBSDKOffset)
+ (NSDictionary *)dictionaryWithOffset:(NSUInteger) offset
                              filePath:(NSString *)filePath;
+ (NSDictionary *)categorysWithOffset:(NSUInteger) offset
                             filePath:(NSString *)filePath;
@end
