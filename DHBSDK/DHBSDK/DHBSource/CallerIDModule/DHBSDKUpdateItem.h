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


@property (nonatomic, copy) NSString *deltaDownloadPath;
@property (nonatomic, copy) NSString *deltaMD5;
@property (nonatomic, assign) NSInteger deltaSize;
@property (nonatomic, assign) NSInteger deltaVersion;

@property (nonatomic, copy) NSString *fullDownloadPath;
@property (nonatomic, copy) NSString *fullMD5;
@property (nonatomic, assign) NSInteger fullSize;
@property (nonatomic, assign) NSInteger fullVersion;


//@property (nonatomic, assign) NSInteger dataSize;
//@property (nonatomic, assign) NSInteger packageSize;
@property (nonatomic, copy) NSString *versionString;
@property (nonatomic, copy) NSString *dataSizeString;
@property (nonatomic, assign, getter=isNeedRetry) BOOL needRetry;

@end
