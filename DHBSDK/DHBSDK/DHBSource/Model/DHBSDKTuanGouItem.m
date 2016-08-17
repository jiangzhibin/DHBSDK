//
//  TuanGouItem.m
//  superyellowpagesdk
//
//  Created by Zhang Heyin on 14/8/6.
//  Copyright (c) 2014年 Yulore. All rights reserved.
//

#import "DHBSDKTuanGouItem.h"




/*
 @property (nonatomic, copy) NSString *bought         : "271"
 @property (nonatomic, copy) NSString *category       : "生活服务"
 @property (nonatomic, copy) NSString *city           : "南充"
 @property (nonatomic, copy) NSString *detail         : "团购详情↵↵↵定制36张彩边拍立得（1套,价值60元）↵注：制作周期1-3天（不含配送时间）↵ ↵"
 @property (nonatomic, copy) NSString *endTime          : "1411919999"
 @property (nonatomic, copy) NSString *id           : "64"
 @property (nonatomic, copy) NSString *identifier   : "6257708"
 @property (nonatomic, copy) NSString *image        : "http://t3.s1.dpfile.com/pc/mc/d55e0122fae4cad2b4bf78314c8b5100(267x160)/thumb.jpg"
 @property (nonatomic, copy) NSString *loc          : "http://t.dianping.com/deal/6257708"
 @property (nonatomic, copy) NSString *price          : "9.90"
 @property (nonatomic, copy) NSString *rebate         : "1.5"
 @property (nonatomic, copy) NSString *refund       : "0"
 @property (nonatomic, copy) NSString *reservation  : "0"
 @property (nonatomic, copy) NSString *shortTitle   : "世纪开元网上冲印"
 @property (nonatomic, copy) NSString *siteurl        : "http://t.dianping.com"
 @property (nonatomic, copy) NSString *soldOut      : "1"
 @property (nonatomic, copy) NSString *startTime    : "1404144000"
 @property (nonatomic, copy) NSString *subcategory      : "快照冲印"
 @property (nonatomic, copy) NSString *title        : "世纪开元网上冲印!仅售9.9元，价值60元世纪开元定制36张彩边拍立得1套，无需预约，包邮配送！"
 @property (nonatomic, copy) NSString *value        : "60.00"
 @property (nonatomic, copy) NSString *wap          : "http://m.dianping.com/tuan/deal/6257708"
 @property (nonatomic, copy) NSString *website      : "1"*/



@interface DHBSDKTuanGouItem()

@end
@implementation DHBSDKTuanGouItem

- (instancetype) initWithDictionary:(NSDictionary *)dictionary {
  self = [super init];
  if (self) {
    _bought   = [[dictionary valueForKey:@"category"] integerValue];
    _category = [dictionary valueForKey:@"category"];
    _city     = [dictionary valueForKey:@"city"];
    _detail     = [dictionary valueForKey:@"detail"];
    _endTime  = [NSDate dateWithTimeIntervalSince1970:[[dictionary valueForKey:@"endTime"] doubleValue] /1000];
    _tuangouID   = [dictionary valueForKey:@"id"];
    _identifier   = [dictionary valueForKey:@"identifier"];
    _imageURL   = [NSURL URLWithString:[dictionary valueForKey:@"image"]];
    _loc   = [NSURL URLWithString:[dictionary valueForKey:@"loc"]];
    _price   = [NSString stringWithFormat:@"%.1f",[ [dictionary valueForKey:@"price"] doubleValue] ];
    _refund = [[dictionary valueForKey:@"refund"] doubleValue];
    _reservation = [[dictionary valueForKey:@"reservation"] boolValue];
    _reservation = [[dictionary valueForKey:@"reservation"] boolValue];
    _shortTitle = [dictionary valueForKey:@"shortTitle"];
    _siteurl = [NSURL URLWithString:[dictionary valueForKey:@"siteurl"]];
    _soldOut = [[dictionary valueForKey:@"soldOut"] boolValue];
    _startTime  = [NSDate dateWithTimeIntervalSince1970:[[dictionary valueForKey:@"startTime"] doubleValue]/1000];
    _subcategory   = [dictionary valueForKey:@"subcategory"];
    _title   = [dictionary valueForKey:@"title"];
    _value   = [NSString stringWithFormat:@"%@", [dictionary valueForKey:@"value"]];
    _wap   = [dictionary valueForKey:@"wap"] ?  [NSURL URLWithString:[dictionary valueForKey:@"wap"]] : nil;
    _website   = nil;//[dictionary valueForKey:@"website"] ?  [NSURL URLWithString:[dictionary valueForKey:@"website"]] : nil;

    
  }
  
  
  return self;
}
@end
