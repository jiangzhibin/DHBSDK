//
//  PromotionItem.m
//  SuperYellowPageSDK
//
//  Created by Zhang Heyin on 15/6/10.
//  Copyright (c) 2015年 Yulore. All rights reserved.
//

#import "DHBSDKPromotionItem.h"

@implementation DHBSDKPromotionItem


- (instancetype)initWithDictionary:(NSDictionary *)item {
  self = [super init];
  
  if (self) {
    NSString *url = nil;
    if (!(url = [item valueForKey:@"image"])) {
      url = [item valueForKey:@"icon"];
    }
    
    _iconURLString = [[NSString alloc] initWithFormat:@"%@",url];
    _promotionID = [[NSString alloc] initWithFormat:@"%@",[item valueForKey:@"id"]];//(NSString *)[item valueForKey:@"id"];
    _promotionName =[[NSString alloc] initWithFormat:@"%@",[item valueForKey:@"title"]];// (NSString *)[item valueForKey:@"name"];
    _promotionAction =[[NSString alloc] initWithFormat:@"%@",[item valueForKeyPath:@"act.data"]];
    _promotionSubTitle = [[NSString alloc] initWithFormat:@"%@",[item valueForKey:@"subtitle"]];// (NSString *)[item valueForKey:@"pid"];
    
    
    _linkType = [[item valueForKey:@"link_type"] integerValue]; // (NSString *)[item valueForKey:@"pid"];
    
    
    
    
    NSString *type = [[NSString alloc] initWithFormat:@"%@",[item valueForKeyPath:@"act.type"]];
    if ([type rangeOfString:@"/service"].location != NSNotFound) {
      _promotionType = DHBSDKPromotionService;
    }
    else if ([type rangeOfString:@"/categorylist"].location != NSNotFound) {
      _promotionType = DHBSDKPromotionCategoryType;
    }
    else if ([type rangeOfString:@"/localservice"].location != NSNotFound) {
      _promotionType = DHBSDKPromotionLinkType;
    }
    
    
    
    //        _hot = (BOOL)[item valueForKey:@"hot"];
    //        _location = ([[item valueForKey:@"loc"] intValue] == 1) ? YES : NO;
  }
  
  return self;
}
@end

