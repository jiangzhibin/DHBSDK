//
//  DHBUpdateItem.h
//  CallerID
//
//  Created by Zhang Heyin on 15/8/13.
//  Copyright (c) 2015年 Yulore Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DHBSDKUpdateItem : NSObject
+ (instancetype)itemWithDictionary:(NSDictionary *)dictonary;
- (void)failed;

- (void) print;

@property (nonatomic, copy) NSDate *version;

/// 更新包下载地址（若无更新包可用，则这个属性值为空）
@property (nonatomic, copy) NSString *deltaDownloadPath;

/// 更新包Hash (若无更新包可用，则这个属性值为空)
@property (nonatomic, copy) NSString *deltaMD5;

/// 更新包大小（字节）(若无更新包可用，则这个属性值为为0)
@property (nonatomic, assign) NSInteger deltaSize;

/// 更新包版本 (若无更新包可用，则这个属性值为0)
@property (nonatomic, assign) NSInteger deltaVersion;

/// 全量包下载地址 (若无全量包可用，则这个属性值为空)
@property (nonatomic, copy) NSString *fullDownloadPath;

/// 全量包Hash (若无全量包可用，则这个属性值为空)
@property (nonatomic, copy) NSString *fullMD5;

/// 全量包大小（字节）(若无全量包可用，则这个属性值为0)
@property (nonatomic, assign) NSInteger fullSize;

/// 全量包版本 (若无全量包可用，则这个属性值为0)
@property (nonatomic, assign) NSInteger fullVersion;


//@property (nonatomic, assign) NSInteger dataSize;
//@property (nonatomic, assign) NSInteger packageSize;
@property (nonatomic, copy) NSString *versionString;
@property (nonatomic, copy) NSString *dataSizeString;
@property (nonatomic, assign, getter=isNeedRetry) BOOL needRetry;

@end
