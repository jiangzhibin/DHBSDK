//
//  PromotionItem.h
//  SuperYellowPageSDK
//
//  Created by Zhang Heyin on 15/6/10.
//  Copyright (c) 2015年 Yulore. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, DHBSDKPromotionType) {
  DHBSDKPromotionCategoryType          = 0,
  DHBSDKPromotionLinkType     = 1,
  DHBSDKPromotionService     = 2,
};

@interface DHBSDKPromotionItem : NSObject
@property (nonatomic, copy) NSString *promotionName;
@property (nonatomic, copy) NSString *promotionSubTitle;
@property (nonatomic, copy) NSString *promotionID;
@property (nonatomic, assign) NSInteger linkType; //0 默认 1 外部浏览器
@property (nonatomic, readonly) DHBSDKPromotionType promotionType;



@property (nonatomic, copy) NSString *promotionAction;
@property (nonatomic, copy) NSString *iconURLString;

- (instancetype)initWithDictionary:(NSDictionary *)item ;
@end
