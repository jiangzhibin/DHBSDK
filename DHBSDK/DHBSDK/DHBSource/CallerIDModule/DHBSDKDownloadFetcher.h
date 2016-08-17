//
//  DHBDownloadFetcher.h
//  Downloading
//
//  Created by Zhang Heyin on 15/8/10.
//  Copyright © 2015年 Yulore. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DHBSDKUpdateItem.h"
#import "DHBSDKCommonType.h"

@interface DHBSDKDownloadFetcher : NSObject
+ (instancetype)sharedInstance;

/**
 *  下载操作
 *
 *  @param packageType       更新包类型
 *  @param progressBlock     进度block
 *  @param completionHandler 任务完成回调
 */
- (void)baseDownloadingWithType:(DHBDownloadPackageType)packageType
                     updateItem:(DHBSDKUpdateItem *)updateItem
                  progressBlock:(void (^)(double progress, long long totalBytes))progressBlock
              completionHandler:(void (^)(BOOL retry, NSError *error))completionHandler;

@end
