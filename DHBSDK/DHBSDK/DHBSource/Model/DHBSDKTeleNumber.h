//
//  TeleNumber.h
//  DianHuaBang
//
//  Created by Zhang Heyin on 13-7-11.
//  Copyright (c) 2013年 Yulore. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DHBSDKTeleNumber : NSObject <NSCoding>
@property (nonatomic, copy) NSString *teleDescription;
@property (nonatomic, copy) NSString *teleType;
@property (nonatomic, copy) NSString *teleNumber;
- (id)initWithBlank;
- (id)initWithDictionary:(NSDictionary *)detailsDictionary;
@end
