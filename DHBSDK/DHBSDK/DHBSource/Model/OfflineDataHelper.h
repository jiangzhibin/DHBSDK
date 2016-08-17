//
//  OfflineDataHelper.h
//  DianHuaBang
//
//  Created by Zhang Heyin on 13-7-23.
//  Copyright (c) 2013年 Yulore. All rights reserved.
//

#import <Foundation/Foundation.h>
@class City;

typedef enum DHBSDKDATAFILETYPE {
  DHBSDKDataPinyin,
  DHBSDKDataCategory,
  DHBSDKDataCategoryDat,
  DHBSDKDataDetail
	
} DHBSDKDataFileType;
@interface OfflineDataHelper : NSObject
+ (BOOL)hasCategoryData;
+ (BOOL)canOfflineSearch;
+ (NSString *)nationaldataFilePath:(DHBSDKDataFileType)type;
+ (NSArray *)pinyinIndexWithKeyWords:(NSString *)keyWords;
//+ (NSMutableArray *)pinyinIndexFileOffsetArray;
//+ (NSMutableArray *)allItem;
//+ (BOOL)decompressDatFile:(City *)aCity;
+ (BOOL)decompressDatFileWithCityId:(NSString *)cityId;
+ (NSData *)dataOfFilePath:(DHBSDKDataFileType)type;
+ (NSString *)dataFilePath:(DHBSDKDataFileType)type;
//+ (BOOL)deleteSelected:(City *)aCity ;
//+ (BOOL)deleteSelectedCityID:(NSInteger)aCity;
//+ (BOOL) updateCityDataDelete :(City *)aCity;
//+ (BOOL) updateCityDataDeleteWithCityID :(NSInteger)aCity;
@end
