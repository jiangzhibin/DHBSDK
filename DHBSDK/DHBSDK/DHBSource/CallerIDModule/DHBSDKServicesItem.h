//
//  ServicesItem.h
//  yellopage
//
//  Created by Zhang Heyin on 14-3-26.
//  Copyright (c) 2014年 Yulore. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DHBSDKServicesItem : NSObject
@property (nonatomic, copy) NSString *iconURLString;
@property (nonatomic, copy) NSString *servicesID;
@property (nonatomic, copy) NSString *subTitle;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *link;
@property (nonatomic, copy) NSString *actionType;
- (id)initWithDictionary:(NSDictionary *)aDictionary;
@end
