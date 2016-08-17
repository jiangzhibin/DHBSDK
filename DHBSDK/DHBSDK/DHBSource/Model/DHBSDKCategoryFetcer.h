//
//  CategoryFetcer.h
//  SuperYellowPageSDK
//
//  Created by Zhang Heyin on 15/3/17.
//  Copyright (c) 2015年 Yulore. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^DHBSDKCategoryCompletionHandler)(NSMutableArray *allHotCategories,
                                          NSMutableArray *allServices,
                                          NSMutableArray *allLocalServices,
                                          NSMutableArray *allNeabys,
                                          NSMutableArray *allPromotions,
                                          NSError *error);

typedef void (^DHBSDKCategoryAllCompletionHandler)(NSMutableArray *allCategories,
                                             NSMutableArray *allHotCategories,
                                             NSMutableArray *allServices,
                                             NSMutableArray *allLocalServices,
                                             NSMutableArray *allNeabys,
                                             NSMutableArray *allPromotions,
                                             NSError *error);

//typedef NS_ENUM(NSUInteger, DHBSDKCategoryResultType) {
//  DHBSDKCategoryResultTypeAllCategories,
//  DHBSDKCategoryResultTypeAllHotCategories,
//  DHBSDKCategoryResultTypeAllLocalServices,
//  DHBSDKCategoryResultTypeAllServices
//};
@interface DHBSDKCategoryFetcer : NSObject

- (void)loadingListViewControllerParamter:(NSDictionary *)parameter completionHandler:(void (^)(id responseObject))completionHandler;

@property (nonatomic , strong) NSMutableArray *categoryDataValue;
@property (nonatomic , strong) NSMutableArray *serviceDataValue;
@property (nonatomic , strong) NSMutableArray *localServiceDataValue;
@property (nonatomic , strong) NSMutableArray *nearbyDataValue;
@property (nonatomic , strong) NSMutableArray *promotionsDataValue;




@property (nonatomic , strong) NSMutableArray *allNearby;
@property (nonatomic , strong) NSMutableArray *allCategories;
@property (nonatomic , strong) NSMutableArray *allHotCategories;
@property (nonatomic , strong) NSMutableArray *allServices;
@property (nonatomic , strong) NSMutableArray *allLocalServices;
@property (nonatomic , strong) NSMutableArray *allPromotions;
+ (instancetype)sharedCategoryFetcer;
//- (void)categoriesWithCityID:(NSString *)cityID completionHandler:(CategoryAllCompletionHandler)completionHandler;


- (void)categoriesWithCityID:(NSString *)cityID
loadFromSandboxCompletionHandler:(DHBSDKCategoryCompletionHandler)loadFromSandboxCompletionHandler
updateFromServerCompletionHandler:(DHBSDKCategoryCompletionHandler)updateFromServerCompletionHandler;
@end
