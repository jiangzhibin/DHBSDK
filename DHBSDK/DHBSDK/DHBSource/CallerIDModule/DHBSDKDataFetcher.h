//
//  DHBDataFetcher.h
//  CallerID
//
//  Created by Zhang Heyin on 15/8/18.
//  Copyright (c) 2015年 Yulore Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DHBSDKUpdateItem.h"
@interface DHBSDKDataFetcher : NSObject
+ (instancetype)sharedInstance;
- (void)dataFetcherCompletionHandler:(void (^)( DHBSDKUpdateItem *updateItem, NSError *error) )completionHandler;
@end
