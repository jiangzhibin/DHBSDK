//
//  DHBSDKFilePaths.h
//  DHBDemo
//
//  Created by 蒋兵兵 on 16/8/17.
//  Copyright © 2016年 蒋兵兵. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DHBSDKFilePaths : NSObject

+ (NSString *)pathForOfflineDataDirectory;
+ (NSString *)pathForOriginalCategoryDataFile;
+ (NSString *)pathForCategoryDataFileWithCityID:(NSString *)cityID;
+ (NSString *)pathForOfflineLOGOWithShopID:(NSString *)shopID;
+ (NSString *)pathForFullOfflineFilePath;
+ (NSString *)pathForDeltaOfflineFilePath;
+ (NSString *)pathForPreOfflineFilePath;
+ (NSString *)pathForBackupTempOfflineFilePath;
+ (NSString *)pathForBridgeOfflineFilePath;


@end
