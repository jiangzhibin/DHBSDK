//
//  DHBCovertIndexContent.h
//  CallerID
//
//  Created by Zhang Heyin on 15/8/12.
//  Copyright (c) 2015年 Yulore Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DHBSDKResolveDataFile.h"

@interface DHBSDKCovertIndexContent : NSObject
@property (nonatomic, strong) NSDictionary *indexContent;
@property (nonatomic, strong) NSData *mappedData;
@property (nonatomic, copy) NSString *dataFileInfo;
@property (nonatomic, strong) DHBSDKResolveDataFile *resolveDataFile;

+ (instancetype)sharedInstance;
- (void)needReload;
- (void)readDataFromFile:(void (^)(float progress))progressBlock
                 completionHandler:(void (^)(NSError *error))completionHandler;

@end
