//
//  CategoryItem.h
//  DianHuaBang
//
//  Created by Zhang Heyin on 13-7-16.
//  Copyright (c) 2013年 Yulore. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DHBSDKNearbyItem : NSObject
@property (nonatomic, copy) NSString *nearbyItemName;
@property (nonatomic, copy) NSString *nearbyItemSubTitle;
@property (nonatomic, copy) NSString *nearbyItemID;

@property (nonatomic, copy) NSString *nearbyAction;
//@property (nonatomic, copy) NSString *parentID;
//@property (nonatomic) BOOL location;
@property (nonatomic, copy) NSString *iconURLString;
//@property (nonatomic) BOOL hot;
//+ (void)globalCategoryItemsWithBlock:(void (^)( NSMutableArray *categorys, NSError *error))block
//                          withCityID:(NSString *)cityID;
//+ (UIView *)viewWithCategory:(CategoryItem *)category addTarget:(id)target action:(SEL)action;
//- (id)initWithName:(NSString *)name  type:(LISTICONType)type;
- (instancetype)initWithDictionary:(NSDictionary *)item ;
//+ (CategoryItem *)categoryItemWithID:(NSString *)categoryID;
//+ (void)globalCategoryItemsWithBlock:(void (^)(NSMutableArray *categorys, NSError *error))block;

//+ (NSString *)titleWithCategory:(CategoryItem *)category;

@end
