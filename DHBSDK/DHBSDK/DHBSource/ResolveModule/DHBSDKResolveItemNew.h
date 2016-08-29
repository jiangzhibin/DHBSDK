//
//  ResolveItem.h
//  TestMuti1
//
//  Created by Zhang Heyin on 15/3/10.
//  Copyright (c) 2015年 Yulore. All rights reserved.
//

#import <Foundation/Foundation.h>

/// 号码查询结果中 标签类型
typedef NS_ENUM(NSInteger, DHBSDKMarkNumberType) {
    DHBSDKMarkNumberTypeUnMark         =-1,//未能反查
    DHBSDKMarkNumberTypeAdvertising        = 0,//广告推销
    DHBSDKMarkNumberTypeHarassing          = 1,//骚扰电话
    DHBSDKMarkNumberTypeSuspectedFraud     = 2,//疑似诈骗
    DHBSDKMarkNumberTypeExpress            = 3,//快递送餐
    DHBSDKMarkNumberTypeIntermediary       = 4,//房产中介
    DHBSDKMarkNumberTypeRoomService        = 5,//外卖送餐
    DHBSDKMarkNumberTypeInsuranceMarketing = 6,//保险推销
    DHBSDKMarkNumberTypeUserDefine         = 7,//保险推销
    
};

@interface DHBSDKResolveItemNew : NSObject <NSCoding>
/// 商户坐标 (号码归属地)
@property (nonatomic, copy) NSString *location;

/// 商户等级 (商户等级1=认证，2=普通标记数据为null)
@property (nonatomic, copy) NSString *rank;

/// 电话描述 (电话号码的用途，如总机、客服等)
@property (nonatomic, copy) NSString *rDescription;

/// 商户名称 (识别到的商户名称)
@property (nonatomic, copy) NSString *name;

/// 商户背景图链接 (1080x1080尺寸的大图，可用作背景图展示。可为空)
@property (nonatomic, copy) NSString *imageLink;

@property (nonatomic, copy) NSString *rID;

@property (nonatomic, copy) NSString *rType;

/// 识别号码 (当前识别的号码（规则化后）)
@property (nonatomic, copy) NSString *teleNumber;

/// LOGO图片链接 (LOGO的链接，200x200，可为空)
@property (nonatomic, copy) NSString *logoImageLink;

/// 是否需要高危提示 (号码识别结果来自于网络，如遇到转账汇款等要求，请核实对方身份)
@property (nonatomic, copy) NSString *highrisk;

/// 用户标记次数 (号码被标记的次数)
@property (nonatomic, copy) NSString *flagNumber;

/// 用户标记类型 (号码被标记的类型)
@property (nonatomic, copy) NSString *flagType;

/// 用户标记时间 (号码被标记日期)
@property (nonatomic, copy) NSString *flagDate;

/// 显示名称 (TodayWidget的展示文字第1行)
@property (nonatomic, copy) NSString *displayTitle;

/// 用户标记信息 (TodayWidget的展示文字第2行)
@property (nonatomic, copy) NSString *flagInfo;

/// 商户ID (商户唯一编号)
@property (nonatomic, copy) NSString *shopID;

/// 其它号码 (该商户的其它号码及描述)
@property (nonatomic, copy) NSMutableArray *teleNumbers;

/// 官方网址
@property (nonatomic, copy) NSString *webURL;

/// 宣传语图片链接
@property (nonatomic, copy) NSString *sloganImageURL;

/// 宣传语文字
@property (nonatomic, copy) NSString *sloganContent;

/// 用户标记内容 （本机用户对该号码的标记内容）
@property (nonatomic, copy) NSString *userFlagContent;

/// 用户标记类型 (本机用户对该号码的标记类型)
@property (nonatomic, assign) DHBSDKMarkNumberType userTaggedType;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
@end
