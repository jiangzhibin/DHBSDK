//
//  CustomItem.m
//  superyellowpagesdk
//
//  Created by Zhang Heyin on 14-5-27.
//  Copyright (c) 2014年 Yulore. All rights reserved.
//

#import "DHBSDKCustomItem.h"
#import "DHBSDKTeleNumber.h"
#import "DHBSDKTuanGouItem.h"
@implementation DHBSDKCustomItem


- (id)initWithDictionary:(NSDictionary *)item {
  self = [super init];
  if (self) {
    _iconURL = [NSURL URLWithString: [item valueForKey:@"icon"]];
    _URL =  [NSURL URLWithString:[ [item valueForKey:@"url"] stringByReplacingOccurrencesOfString:@" " withString:@""]];
    
    
    id title_id = [item valueForKey:@"title"];
    if ([title_id isKindOfClass:[NSNull class]]) {
      _title = @"";
    } else {
      _title = title_id;
    }
    
    

    _service = [item valueForKey:@"svc"];
    _website = [item valueForKey:@"website"];
    NSString *shopID = [item valueForKeyPath:@"act.data"];
    if ( [shopID rangeOfString:@"yulore://viewDetail?sid="].location != NSNotFound) {
      shopID = [shopID stringByReplacingOccurrencesOfString:@"yulore://viewDetail?sid=" withString:@""];
      
      NSArray *dataArray = [shopID componentsSeparatedByString:@"&"];
      _shopID = dataArray[0];
      
      
    }
    _action = [item valueForKeyPath:@"act.data"];
    _actionType = [item valueForKeyPath:@"act.type"];
    
    id itemData = [item valueForKey:@"data"];
    if (![itemData isKindOfClass:[NSNull class]] && [item valueForKey:@"data"] && ![itemData isKindOfClass:[NSString class]]) {
      id data = [item valueForKey:@"data"];
      
      
      if (![itemData isKindOfClass:[NSArray class]]) {
        if ([[data allKeys] count] > 0) {
          _tuangouItem = [[DHBSDKTuanGouItem alloc] initWithDictionary:data];
        }
      }
      
      

    
    }
    
    
    
    
    id telItems =  [item valueForKey:@"tels"];
    if (telItems) {
      //id telItems =
      if (!_telenumberItems) {
        _telenumberItems = [[NSMutableArray alloc] initWithCapacity:[telItems count]];
      }
      
      
      for (id aTelItem in telItems) {
        [_telenumberItems addObject:[[DHBSDKTeleNumber alloc] initWithDictionary:aTelItem]];
      }
    }
    
    NSString *tel = ((DHBSDKTeleNumber *)[_telenumberItems firstObject]).teleNumber;
    
    _subTitle  = [[item valueForKey:@"subtitle"] isKindOfClass:[NSNull class]] ? tel : [item valueForKey:@"subtitle"];
    
  }
  return self;
}
@end
