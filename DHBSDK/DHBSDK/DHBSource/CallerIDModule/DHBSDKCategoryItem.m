//
//  CategoryItem.m
//  DianHuaBang
//
//  Created by Zhang Heyin on 13-7-16.
//  Copyright (c) 2013年 Yulore. All rights reserved.
//

#import "DHBSDKCategoryItem.h"

@implementation DHBSDKCategoryItem


- (instancetype)initWithDictionary:(NSDictionary *)item {
    self = [super init];
    
    if (self) {
      _iconURLString = [[NSString alloc] initWithFormat:@"%@",[item valueForKey:@"icon"]];
        _categoryID = [[NSString alloc] initWithFormat:@"%@",[item valueForKey:@"id"]];//(NSString *)[item valueForKey:@"id"];
        _categoryItem =[[NSString alloc] initWithFormat:@"%@",[item valueForKey:@"name"]];// (NSString *)[item valueForKey:@"name"];
        _parentID = [[NSString alloc] initWithFormat:@"%@",[item valueForKey:@"pid"]];// (NSString *)[item valueForKey:@"pid"];
        _hot = (BOOL)[item valueForKey:@"hot"];
    
        _location = ([[item valueForKey:@"loc"] intValue] == 1) ? YES : NO;
      
      
      NSString *string = [item valueForKey:@"subtitle"] ? [[NSString alloc] initWithFormat:@"%@",[item valueForKey:@"subtitle"]] : nil;
      if (string || [string length]) {
        
//           string=   [string stringByReplacingOccurrencesOfString:@" " withString:@""];
                   string=   [string stringByReplacingOccurrencesOfString:@"u" withString:@"\\u"];
        string = [self replaceUnicode:string];
         _categorySubName =  string;// (NSString *)[item
//        DHBSDKDLog(@"%@", _categorySubName);
      }
      else {
        _categorySubName = @"";
      }

    }
    
    return self;
}

- (NSString *)replaceUnicode:(NSString *)unicodeStr {
  NSString *tempStr1 = [unicodeStr stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
  NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
  NSString *tempStr3 = [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
  NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
  NSString* returnStr = [NSPropertyListSerialization propertyListFromData:tempData
                                                         mutabilityOption:NSPropertyListImmutable
                                                                   format:NULL
                                                         errorDescription:NULL];
//  
  return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n" withString:@""];
}
@end
