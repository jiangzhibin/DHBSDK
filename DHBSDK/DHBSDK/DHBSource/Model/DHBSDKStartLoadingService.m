
//  StartLoadingService.m
//  yellopage
//
//  Created by Zhang Heyin on 14-3-28.
//  Copyright (c) 2014年 Yulore. All rights reserved.
//

#import "CommonTmp.h"
#import "Commondef.h"
#import "DHBSDKStartLoadingService.h"
#import "DHBSDKCategoryItem.h"

#import "OfflineDataHelper.h"
#import "DHBSDKServicesItem.h"
#import "DHBSDKNearbyItem.h"

static NSString * const kLastVersion = @"DHBSDKLastVersion";

@implementation DHBSDKStartLoadingService



+ (void)updateLastVersion {
    NSString *ver = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)@"CFBundleShortVersionString"];
    [[NSUserDefaults standardUserDefaults] setObject:ver forKey:kLastVersion];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)fetcherLastVersion {
    BOOL needToUpdate = YES;
    NSString *ver = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)@"CFBundleShortVersionString"];
    
    NSString *lastVersion = [[NSUserDefaults standardUserDefaults] valueForKey:kLastVersion];
    
    if (lastVersion) {
        
        
        
        if ([ver isEqualToString:lastVersion]) {
            needToUpdate = NO;
        } else {
            
            needToUpdate = YES;
        }
    }
    
    return needToUpdate;
}

/*
 + (void)startLocation {
 [[CurrentLocation sharedInstance] startingForLocation:^(CLLocation *currentLocation, City *currentCity, NSError *error) {
 
 NSUserDefaults * pref = [NSUserDefaults standardUserDefaults];
 
 NSNumber *timer  = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
 CLLocationCoordinate2D coordinate = currentLocation.coordinate;
 [pref setObject:[NSNumber numberWithDouble:coordinate.latitude] forKey:@"coordinatelatitude"];
 [pref setObject:[NSNumber numberWithDouble:coordinate.longitude] forKey:@"coordinatelongitude"];
 [pref setObject:timer forKey:@"lastlocatingtime"];
 [pref synchronize];
 }];
 }
 */


/**
 *  @author Zhang  Heyin
 *
 *  对离线文件从app中复制到沙箱中，zip文件会解压缩。
 *
 *  @param completionBlock <#completionBlock description#>
 */
+ (void) copyInitDataCompletionBlock:(void (^)(NSError *error) )completionBlock {
    NSString *offlineDirectory = [DHBSDKFilePaths pathForOfflineDataDirectory];
    
    NSString *filename = nil;
    NSString *apiKey = [DHBSDKApiManager shareManager].apiKey;
    if (apiKey.length > 0) {
        filename = [NSString stringWithFormat:@"0_%@_full.zip", [apiKey substringToIndex:4]];
    } else {
        if (completionBlock) {
            NSError *error = [NSError errorWithDomain:@"apikey为空" code:-1 userInfo:nil];
            completionBlock(error);
        }
        return;
    }
    
    [self copyAndUpzipZipFileWithNameArray:@[filename]
                              targetFolder:offlineDirectory
                           completionBlock:^(NSError *error)
     {
         dispatch_queue_t q = dispatch_queue_create("queue", 0);
         dispatch_async(q, ^{
             
             // cityId：0 代表all
             [OfflineDataHelper decompressDatFileWithCityId:@"0"];
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 DHBSDKDLog(@"copyAndUpzipZipFileWithNameArray");
                 completionBlock(nil);
             });
         });
     }];
    
    
}


+ (long long) fileSizeAtPath:(NSString*) filePath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}



/**
 *    @brief    创建文件夹
 *
 *    @param     createDir     创建文件夹路径
 */
+ (BOOL)createFolder:(NSString *)createDir
{
    BOOL createdDir = NO;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:createDir isDirectory:&createdDir];
    if ( !(createdDir == YES && existed == YES) ) {
        createdDir = [fileManager createDirectoryAtPath:createDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return createdDir;
}


+ (void ) copyAndUpzipZipFileWithNameArray:(NSArray *)nameArray targetFolder:(NSString *)targetFolder

                           completionBlock:(void (^)(NSError *error) )completionBlock
{
    
    NSString *zipFileFolderPath = nil;
    
    if ([nameArray count] <= 0) {
        NSError *error = [NSError errorWithDomain:@"" code:-1 userInfo:nil];
        if (completionBlock) {
            completionBlock(error);
        };
    }
    
    zipFileFolderPath = [targetFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", nameArray[0]]];
    
    //  if ([[NSFileManager defaultManager] fileExistsAtPath:targetFolder]
    //      && ([self fileSizeAtPath:targetFolder] > 0)
    //      ) {
    //    DHBSDKDLog(@"文件已经存在了");
    //    completionBlock(nil);
    //    return;
    //  }else {
    __block int countFiles = 0;
    
    if ([self createFolder:targetFolder]) {
        for (NSString *fileName in nameArray) {
            countFiles++;
            NSLog(@"fileName:%@ \n\nnameArray:%@",fileName,nameArray);
            NSString *resourceFolderPath =[[NSBundle mainBundle] pathForResource:fileName ofType:nil];
            NSData *mainBundleFile = [NSData dataWithContentsOfFile:resourceFolderPath];
            if ( [[NSFileManager defaultManager] createFileAtPath:zipFileFolderPath
                                                         contents:mainBundleFile
                                                       attributes:nil]) {
                //todo解压缩
                DHBSDKYuloreZipArchive *zip = [[DHBSDKYuloreZipArchive alloc] init];
                //   zip.progressBlock = progressBlock;
                NSLog(@"countFiles:%zd",countFiles);
                zip.progressBlock = ^ (int percentage, int filesProcessed, int numFiles) {
                    
                    DHBSDKDLog(@"countFiles:%zd  total %d, filesProcessed %d of %d", countFiles,percentage, filesProcessed, numFiles);
                    
                    if (countFiles == nameArray.count && percentage == 100) {
                        DHBSDKDLog(@"unzip finish!!!!!!");
                        completionBlock(nil);
                    }
                };
                BOOL result = NO;
                
                if ([zip UnzipOpenFile:zipFileFolderPath]) {
                    result = [zip UnzipFileTo:targetFolder overWrite:YES];//解压文件
                    if (!result) {
                        //解压失败
                        DHBSDKDLog(@"unzip fail................");
                    }else {
                        //解压成功
                        DHBSDKDLog(@"unzip success.............");
                        NSFileManager *fileManager = [NSFileManager defaultManager];
                        [fileManager removeItemAtPath:zipFileFolderPath error:nil];
                    }
                    // DHBSDKYuloreZipArchiveProgressUpdateBlock progressBlock
                    //DLog(@"total %d, filesProcessed %d of %d", percentage, filesProcessed, numFiles);
                }
                else {
                    DHBSDKDLog(@"\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n压缩包:%@无法打开或不存在\n!!!!!!!!!!!!!!!!!!!!!!!",fileName);
                }
                [zip UnzipCloseFile];//关闭
                
            }
            
        }
        //}
    }
}



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (alertView.tag==10000) {
        if (buttonIndex==1) {
            
            NSURL *url = [NSURL URLWithString:self.trackViewUrl];
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

+ (void) nearbyImageCache:(NSArray *)nearbyArray {
    
    
    for (DHBSDKNearbyItem *aItem in nearbyArray) {
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:aItem.iconURLString]];
        
        
        
        [NSURLConnection sendAsynchronousRequest:urlRequest
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   
                                   NSArray *urlArray = [aItem.iconURLString componentsSeparatedByString:@"/"];
                                   NSString *fileName = [urlArray lastObject];
                                   NSString *cacheFileNamePath = [[DHBSDKFilePaths pathForOfflineDataDirectory] stringByAppendingFormat:@"%@", fileName ];
                                   [data writeToFile:cacheFileNamePath atomically:YES];
                                   //                             DLog(@"%@ nearbyArray writeToFile", fileName);
                                   //                             countsForUpdate--;
                                   //                             if (countsForUpdate == 0) {
                                   //                               completionHandler(nil);
                                   //                             }
                               }];
    }
    
    
    
    
    
}
+ (void) cacheIconImageFromInternet:(NSArray *)contentArray
                        nearbyArray:(NSArray *)nearByArray
                         withPrefix:(NSString *)prefix
                  completionHandler:(void (^)(NSError *error))completionHandler {
    
    __block NSUInteger countsForUpdate = [contentArray count];
    //  __block int counter = 0;
    [self nearbyImageCache:nearByArray];
    if (countsForUpdate) {
        //  NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        NSMutableArray *urlArray = [[NSMutableArray alloc] initWithCapacity:[contentArray count]];
        for (id aItem in contentArray) {
            NSString *urlString  = nil;
            NSString *itemID = nil;
            //DLog(@"aItem -- %@", aItem);
            if ([aItem isKindOfClass:[NSDictionary class]]) {
                if ( [[aItem allKeys] containsObject:@"icon"]) {
                    [urlArray addObject:aItem[@"icon"]];
                    urlString = aItem[@"icon"];
                    itemID = aItem[@"id"];
                } else {
                    return;
                }
                
            } else if ([aItem isKindOfClass:[DHBSDKServicesItem class]]){
                urlString = ((DHBSDKServicesItem *)aItem).iconURLString;
                itemID =  ((DHBSDKServicesItem *)aItem).servicesID;
            } else if ([aItem isKindOfClass:[DHBSDKCategoryItem class]]){
                urlString = ((DHBSDKCategoryItem *)aItem).iconURLString;
                itemID =  ((DHBSDKCategoryItem *)aItem).categoryID;
            }
            
            
            
            
            
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
            
            
            
            [NSURLConnection sendAsynchronousRequest:urlRequest
                                               queue:[NSOperationQueue mainQueue]
                                   completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                       
                                       NSArray *urlArray = [urlString componentsSeparatedByString:@"/"];
                                       NSString *fileName = [urlArray lastObject];
                                       NSString *cacheFileNamePath = [[DHBSDKFilePaths pathForOfflineDataDirectory] stringByAppendingFormat:@"%@_%@",prefix, fileName ];
                                       
                                       [self createFolder:[DHBSDKFilePaths pathForOfflineDataDirectory]];
                                       
                                       
                                       
                                       
                                       BOOL cacheOK = [data writeToFile:cacheFileNamePath atomically:YES];
                                       //                               DLog(@"%@ writeToFile, %@", fileName, (cacheOK ? @"YES": @"NO"));
                                       countsForUpdate--;
                                       if (countsForUpdate == 0) {
                                           completionHandler(nil);
                                       }
                                   }];
        }
        
        
        
    }
    
    
}





+ (void) cacheServiceIconImageFromInternet2:(NSArray *)serviceArray
                                nearbyArray:(NSArray *)nearByArray
                          completionHandler:(void (^)(NSError *error))completionHandler {
    
    [self cacheIconImageFromInternet:serviceArray
                         nearbyArray:nearByArray
                          withPrefix:@"sicon"
                   completionHandler:^(NSError *error) {
                       DHBSDKDLog(@"cacheServiceIconImageFromInternet2");
                       completionHandler(error);
                   }];
    
}


+ (void) updateCurrentCity {
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(cacheCategoyDataFromInternet)
                                                 name: @"cacheCategoyDataFromInternet"
                                               object: nil];
    
}


@end
