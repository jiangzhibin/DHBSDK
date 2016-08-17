//
//  DHBSDKDownloadConfig.h
//  DHBDemo
//
//  Created by 蒋兵兵 on 16/8/16.
//  Copyright © 2016年 蒋兵兵. All rights reserved.
//

#ifndef DHBSDKDownloadConfig_h
#define DHBSDKDownloadConfig_h

/// 允许执行下载操作的网络类型
typedef NS_ENUM(NSInteger,DHBSDKDownloadNetworkType) {
    DHBSDKDownloadNetworkTypeWifiOnly,      // 仅wifi网络
    DHBSDKDownloadNetworkTypeAllAllow,      // 所有网络
    DHBSDKDownloadNetworkTypeNotAllow       // 禁止联网
};

/// 下载的数据类型
typedef NS_ENUM(NSInteger, DHBDownloadPackageType) {
    DHBDownloadPackageTypeDelta,    // 增量包
    DHBDownloadPackageTypeFull      // 全量包
};


// 下载流程所用到的errorCode
typedef NS_ENUM(NSInteger,DHBSDKDownloadErrorCode) {
    DHBSDKDownloadErrorCodeUnknow = 0,              // 默认未知
    DHBSDKDownloadErrorCodeNetworkNotReachable,     // 网络不支持
    DHBSDKDownloadErrorCodeNotAllow,                // 不允许下载
    DHBSDKDownloadErrorCodeWWANDownloadNotAllow,    // 未开启3G/4G下载
    DHBSDKDownloadErrorCodeBatteryLevelTooLow,      // 电量过低
    DHBSDKDownloadErrorCodeMD5CheckInvalidError,    // 文件校验失败
    DHBSDKDownloadErrorCodeResponseCodeNot200,      // 响应错误（状态码不为200）
};

static NSString * const DHBSDKDownloadErrorDomain                   =   @"com.dhbsdk.download";
static NSString * const DHBSDKNotReachableErrorDomain               =   @"com.dhbsdk.network.notReachable";
static NSString * const DHBSDKBSPatchErrorDomain                    =   @"com.dhbsdk.callerid.bspatch";
static NSString * const DHBSDKMD5ValidErrorDomain                   =   @"com.dhbsdk.callerid.md5invalid";
static NSString * const DHBSDKEnvironmentErrorDomain                =   @"com.dhbsdk.callerid.environment";

#endif /* DHBSDKDownloadConfig_h */
