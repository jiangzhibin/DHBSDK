//
//  CustomItem.h
//  superyellowpagesdk
//
//  Created by Zhang Heyin on 14-5-27.
//  Copyright (c) 2014年 Yulore. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DHBSDKTuanGouItem;
@interface DHBSDKCustomItem : NSObject
- (instancetype)initWithDictionary:(NSDictionary *)item ;
@property (nonatomic, copy) DHBSDKTuanGouItem *tuangouItem;
@property (nonatomic, copy) NSURL *iconURL;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subTitle;
@property (nonatomic, copy) NSURL *URL;
@property (nonatomic, copy) NSString *service;
@property (nonatomic, copy) NSString *website;
@property (nonatomic, copy) NSString *shopID;
@property (nonatomic, copy) NSString *action;
@property (nonatomic, copy) NSString *actionType;
@property (nonatomic, copy) NSMutableArray *telenumberItems;
@end
