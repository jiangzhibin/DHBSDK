//
//  NetworkManager.h
//  DHBDemo
//
//  Created by 蒋兵兵 on 16/8/16.
//  Copyright © 2016年 蒋兵兵. All rights reserved.
//

#import <Foundation/Foundation.h>

/// 网络状态发改变时 发送通知的key
extern NSString *const kDHBSDKNotifReachabilityStatusChanged;

typedef NS_ENUM(NSInteger,DHBSDKNetworkType) {
    DHBSDKNetworkTypeNotReachable,      // 没有网络
    DHBSDKNetworkTypeViaWiFi,           // WiFi
    DHBSDKNetworkTypeViaWWAN            // 数据流量
};

@interface DHBSDKNetworkManager : NSObject

+ (DHBSDKNetworkType)networkType;

@end
