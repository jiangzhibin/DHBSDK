//
//  TuanGouItem.h
//  superyellowpagesdk
//
//  Created by Zhang Heyin on 14/8/6.
//  Copyright (c) 2014年 Yulore. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DHBSDKTuanGouItem : NSObject
@property (nonatomic, assign) NSInteger bought;
@property (nonatomic, copy) NSString *category;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *detail;
@property (nonatomic, copy) NSDate *endTime;
@property (nonatomic, copy) NSString *tuangouID;
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSURL *imageURL;
@property (nonatomic, copy) NSURL *loc;
@property (nonatomic, copy) NSString * price;
@property (nonatomic, assign) double rebate;
@property (nonatomic, assign) BOOL refund;
@property (nonatomic, assign) BOOL reservation;
@property (nonatomic, copy) NSString *shortTitle;
@property (nonatomic, copy) NSURL *siteurl;
@property (nonatomic, assign) BOOL soldOut;
@property (nonatomic, copy) NSDate *startTime;
@property (nonatomic, copy) NSString *subcategory;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *value;
@property (nonatomic, copy) NSURL *wap;
@property (nonatomic, copy) NSURL *website;
- (instancetype) initWithDictionary:(NSDictionary *)dictionary;
@end
