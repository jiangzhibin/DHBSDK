//
//  ResolveDataFile.h
//  OfflineResolveDemo
//
//  Created by Zhang Heyin on 15/7/8.
//  Copyright (c) 2015年 Yulore. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DHBSDKResolveDataFile : NSObject

@property (nonatomic, strong) NSMutableDictionary *resolveOffsetDictionary;
@property (nonatomic, assign) NSInteger timeStamp;
@property (nonatomic, assign) NSInteger currentVersion;

@property (nonatomic, strong) NSData *mappedData;
- (void)readDataFromFile:(void (^)(float progress))progressBlock;

@end
