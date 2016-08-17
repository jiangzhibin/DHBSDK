
//
//  ServicesItem.m
//  yellopage
//
//  Created by Zhang Heyin on 14-3-26.
//  Copyright (c) 2014年 Yulore. All rights reserved.
//

#import "DHBSDKServicesItem.h"

@implementation DHBSDKServicesItem
- (id)initWithDictionary:(NSDictionary *)item {
  self = [super init];
  
  if (self) {
    _servicesID = [[NSString alloc] initWithFormat:@"%@",[item valueForKey:@"id"]];//(NSString *)[item valueForKey:@"id"];
    _iconURLString =[[NSString alloc] initWithFormat:@"%@",[item valueForKey:@"icon"]];// (NSString *)[item valueForKey:@"name"];
    _link =[[NSString alloc] initWithFormat:@"%@",[item valueForKey:@"link"]];
    _subTitle = [[NSString alloc] initWithFormat:@"%@",[item valueForKey:@"subtitle"]];// (NSString *)[item valueForKey:@"pid"];
    _actionType = [[NSString alloc] initWithFormat:@"%@",[item valueForKeyPath:@"act.type"]];
    _title = [item valueForKey:@"title"];
  }
  
  return self;
}
@end


