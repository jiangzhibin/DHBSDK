//
//  CategoryItem.m
//  DianHuaBang
//
//  Created by Zhang Heyin on 13-7-16.
//  Copyright (c) 2013年 Yulore. All rights reserved.
//

#import "DHBSDKNearbyItem.h"

@implementation DHBSDKNearbyItem


- (instancetype)initWithDictionary:(NSDictionary *)item {
    self = [super init];
    
    if (self) {
      _iconURLString = [[NSString alloc] initWithFormat:@"%@",[item valueForKey:@"icon"]];
        _nearbyItemID = [[NSString alloc] initWithFormat:@"%@",[item valueForKey:@"id"]];//(NSString *)[item valueForKey:@"id"];
        _nearbyItemName =[[NSString alloc] initWithFormat:@"%@",[item valueForKey:@"title"]];// (NSString *)[item valueForKey:@"name"];
      _nearbyAction =[[NSString alloc] initWithFormat:@"%@",[item valueForKeyPath:@"act.data"]];
        _nearbyItemSubTitle = [[NSString alloc] initWithFormat:@"%@",[item valueForKey:@"subtitle"]];// (NSString *)[item valueForKey:@"pid"];
//        _hot = (BOOL)[item valueForKey:@"hot"];
//        _location = ([[item valueForKey:@"loc"] intValue] == 1) ? YES : NO;
    }
    
    return self;
}
@end
