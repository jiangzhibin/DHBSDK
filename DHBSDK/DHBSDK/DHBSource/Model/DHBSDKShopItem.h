//
//  ShopItem.h
//  DianHuaBang
//
//  Created by Zhang Heyin on 13-7-15.
//  Copyright (c) 2013年 Yulore. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>
@class DHBSDKResolveItemNew;
@class DHBSDKTeleNumber;
@class DHBSDKCustomItem;
@interface DHBSDKShopItem : NSObject <NSCoding>
+ (instancetype)shopItemWithDictionary:(NSDictionary *)dictionary;
//- (instancetype)initWithDictionary:(NSDictionary *)item;

+ (instancetype)shopItemWithCustomItem:(DHBSDKCustomItem *)customItem;
+ (instancetype)shopItemWithResolveItem:(DHBSDKResolveItemNew *)aResolveItem;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *sid;
@property (nonatomic, copy) NSArray *categoryIDs;
@property (nonatomic, copy) NSString *subName;
@property (nonatomic, copy) NSString *callTimes;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *distance;
@property (nonatomic, copy) NSString *telenumber;
@property (nonatomic, copy) NSMutableArray *teleNumbers;
@property (nonatomic, copy) NSURL *logoURL;
@property (nonatomic, assign) BOOL tuan;
@property (nonatomic, assign) BOOL coupon;
@property (nonatomic, copy) NSString *website;
@property (nonatomic, copy) NSMutableArray *customs;
@property (nonatomic, copy) NSString *address;




@property (nonatomic, copy) NSURL *imageURL;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString* price;
@property (nonatomic, copy) NSNumber* score;
@end
