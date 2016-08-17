//
//  DHBDownloadFetcher.m
//  Downloading
//
//  Created by Zhang Heyin on 15/8/10.
//  Copyright © 2015年 Yulore. All rights reserved.
//

#import "DHBSDKDownloadFetcher.h"
#import "DHBSDKFileHash.h"
#import "NSString+DHBSDKMD5Check.h"
#import "DHBSDKbspatchOC.h"
#import "DHBSDKFilePaths.h"
#import "DHBSDKEnvironmentValidate.h"
#import "CommonTmp.h"
#import "DHBSDKNetworkManager.h"
#import "Commondef.h"
#import "DHBErrorHelper.h"
#import "DHBSDKDHBFileOperation.h"
#import "DHBSDKURLSessionManager.h"

@interface DHBSDKDownloadFetcher()


@property (nonatomic, strong) NSURL *requestURL;
@property (nonatomic, strong) DHBSDKUpdateItem *updateItem;
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;

@end
@implementation DHBSDKDownloadFetcher

+ (instancetype)sharedInstance {
  
  static DHBSDKDownloadFetcher *_sharedDownloadFetcher = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
      _sharedDownloadFetcher = [[self alloc] init];
      [[NSNotificationCenter defaultCenter] addObserver:_sharedDownloadFetcher selector:@selector(reachabilityStatusChanged:) name:kDHBSDKNotifReachabilityStatusChanged object:nil];
    
  });
  
  return _sharedDownloadFetcher;
}

- (void)reachabilityStatusChanged:(NSNotification *)notif {
    DHBSDKAFNetworkReachabilityStatus status = [notif.object integerValue];
    if (status == DHBSDKAFNetworkReachabilityStatusNotReachable) {
        [self.downloadTask cancel];
    }
    else if (status == DHBSDKAFNetworkReachabilityStatusReachableViaWWAN) {
        if ([DHBSDKApiManager shareManager].downloadNetworkType == DHBSDKDownloadNetworkTypeWifiOnly) {
            [self.downloadTask cancel];
        }
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kDHBSDKNotifReachabilityStatusChanged object:nil];
}

- (NSString *)targetPathWithType:(DHBDownloadPackageType)type {
  
  NSString *targetPath = nil;
  switch (type) {
    case DHBDownloadPackageTypeDelta:
      targetPath = [DHBSDKFilePaths pathForDeltaOfflineFilePath];
      break;
      
    case DHBDownloadPackageTypeFull:
      targetPath = [DHBSDKFilePaths pathForFullOfflineFilePath];
      break;
      
  }
  
  return targetPath;
}


- (NSString *)md5WithUpdateItem:(DHBSDKUpdateItem *)updateItem packageType:(DHBDownloadPackageType)packageType {
  NSString *MD5 = nil;
  if (packageType == DHBDownloadPackageTypeDelta) {
    MD5 = updateItem.deltaMD5;
  } else if (packageType == DHBDownloadPackageTypeFull) {
     MD5 = updateItem.fullMD5;
  }
  return MD5;
}


/**
 *  <#Description#>
 *
 *  @param progressBlock     <#progressBlock description#>
 *  @param completionHandler <#completionHandler description#>
 */
- (void)downloadingWithType:(DHBDownloadPackageType)packageType
//   updateItem:(DHBUpdateItem *)updateItem
              progressBlock:(void (^)(double progress, long long totalBytes))progressBlock
          completionHandler:(void (^)(NSError *error))completionHandler {
    self.requestURL = nil;
    if (packageType == DHBDownloadPackageTypeDelta) {
        self.requestURL = [NSURL URLWithString:self.updateItem.deltaDownloadPath];
    } else if (packageType == DHBDownloadPackageTypeFull) {
        self.requestURL = [NSURL URLWithString:self.updateItem.fullDownloadPath];
    }
    
    NSString *targetSavePath = [self targetPathWithType:packageType];
    NSString *targetPathUnzipped = [[NSString alloc] initWithFormat:@"%@_zip/",targetSavePath];
    
    DHBSDKDLog(@"to %@ (%@)", targetSavePath,targetPathUnzipped);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:targetSavePath]) {
        [fileManager removeItemAtPath:targetSavePath error:nil];
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:self.requestURL];
    
    self.downloadTask = [[DHBSDKURLSessionManager shareManager] downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        float progress = downloadProgress.completedUnitCount * 1.0 / downloadProgress.totalUnitCount;
        progressBlock(progress, downloadProgress.totalUnitCount);
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return [NSURL fileURLWithPath:targetSavePath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        DHBSDKDLog(@"file downloaded to:%@",filePath);
        if ([(NSHTTPURLResponse *)response statusCode] != 200) {
            NSError *errorTmp = [NSError errorWithDomain:DHBSDKDownloadErrorDomain code:DHBSDKDownloadErrorCodeResponseCodeNot200 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:error,@"description", nil]];
            completionHandler(errorTmp);
            return;
        }
        
        NSString *testMD5 = nil;
        if (packageType == DHBDownloadPackageTypeDelta) {
            testMD5 = self.updateItem.deltaMD5;
        } else if (packageType == DHBDownloadPackageTypeFull) {
            testMD5 = self.updateItem.fullMD5;
        }
        
        NSError *errorTmp = nil;
        
        if (packageType == DHBDownloadPackageTypeFull){
            
            DHBSDKYuloreZipArchive *zip = [[DHBSDKYuloreZipArchive alloc] init];
            zip.progressBlock = ^ (int percentage, int filesProcessed, int numFiles) {
                if (percentage == 100) {
                    //completionBlock(nil);
                }
            };
            BOOL result = NO;
            
            if ([zip UnzipOpenFile:targetSavePath]) {
                result = [zip UnzipFileTo:targetPathUnzipped overWrite:YES];//解压文件
                if (!result) {
                    //解压失败
                    DHBSDKDLog(@"unzip fail................");
                } else if ([zip numFiles]>0) {
                    //解压成功
                    NSString * unzippedFile=[[NSString alloc] initWithFormat:@"%@%@",targetPathUnzipped,[[zip getZipFileContents] objectAtIndex:0]];
                    DHBSDKDLog(@"unzip success.............%@",unzippedFile);
                    [zip UnzipCloseFile];
                    
                    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:targetPathUnzipped error:NULL];
                    for (int count = 0; count < (int)[directoryContent count]; count++)
                    {
                        DHBSDKDLog(@"File %d: %@", (count + 1), [directoryContent objectAtIndex:count]);
                    }
                    
                    [[NSFileManager defaultManager] removeItemAtPath:targetSavePath error:&errorTmp];
                    [[NSFileManager defaultManager] moveItemAtPath:unzippedFile toPath:targetSavePath error:&error];
                    [targetSavePath fileValidMD5WithMD5String:testMD5 error:&errorTmp];
                    if (errorTmp!=nil){
                        DHBSDKDLog(@"error fileValidMD5WithMD5String %@", errorTmp);
                    }
                }
            }
            //full package, unzip first
        } else {
            [targetSavePath fileValidMD5WithMD5String:testMD5 error:&errorTmp];
            if (errorTmp!=nil){
                DHBSDKDLog(@"error fileValidMD5WithMD5String %@", errorTmp);
            }
            //delta package, not zipped
        }
        completionHandler(errorTmp);
    }];
    [self.downloadTask resume];
}

/**
 *  <#Description#>
 *
 *  @param progressBlock     <#progressBlock description#>
 *  @param completionHandler <#completionHandler description#>
 */
- (void)baseDownloadingWithType:(DHBDownloadPackageType)packageType
                     updateItem:(DHBSDKUpdateItem *)updateItem
                  progressBlock:(void (^)(double progress, long long totalBytes))progressBlock
              completionHandler:(void (^)(BOOL retry, NSError *error))completionHandler  {

    self.updateItem = updateItem;
    [self downloadingWithType:packageType  progressBlock:^(double progress, long long totalBytes) {
        //进度回调
        progressBlock(progress, totalBytes);
    
    } completionHandler:^(NSError *error)
    {
        if (error) {
            [self.updateItem failed];
            completionHandler([self.updateItem isNeedRetry], error);
        }
        else {
            [self afterDownloadingWithType:packageType completionHandler:^(NSError *error) {
         
             /**
              *  如果没有异常重置次版本的版本报错记录
              */
                if (error == nil) {
          
                }
                completionHandler([self.updateItem isNeedRetry], error);
            }];
        }
   }];
  
}

/**
 *  Description
 *
 *  @param completionHandler completionHandler description
 */
- (void)bspatchActionCompletionHandler:(void (^)(NSError *error))completionHandler  {
  
  NSString *oldFile = [DHBSDKFilePaths pathForFullOfflineFilePath];
  
  NSString *deltaFile = [DHBSDKFilePaths pathForDeltaOfflineFilePath];
  
  NSString *newFile = [DHBSDKFilePaths pathForPreOfflineFilePath];
  
  
  [DHBbspatchOC DHBbspatchWithOldFile:oldFile newFile:newFile patchFile:deltaFile
                    completionHandler:^(NSError *bspatchError)
   {
     if (bspatchError) {
       completionHandler(bspatchError);
       
       return;
     }

     /**
      *  1 check delta file md5 / 检查delta文件的MD5
      */
     NSString *md5 = self.updateItem.deltaMD5;
     NSError *error = nil;
     [deltaFile fileValidMD5WithMD5String:md5 error:&error];
     
     if (error) {
       completionHandler(error);
       
       return;
     }

     /**
      *  生成新文件的MD5
      */
     [newFile fileValidMD5WithMD5String:self.updateItem.fullMD5 error:&error];
     if (error) {
       
       completionHandler(error);
    
       return;
     }
    
     /**
      *  2 文件更新
      */
     error = [DHBSDKDHBFileOperation errorWithFileUpdateOperation];

       completionHandler(error);

     
   }];
  
}

- (void)afterDownloadingWithType:(DHBDownloadPackageType)type
               completionHandler:(void (^)(NSError *error))completionHandler{
  /**
   *  bspatch
   */
    DHBSDKDLog(@"After Download");
  if (type == DHBDownloadPackageTypeDelta) {
    [self bspatchActionCompletionHandler:^(NSError *error) {
      
      if (error) {
        [self.updateItem failed];
      }
      else {
        //[DHBInitBusiness updateCurrentVersionWithItem:self.updateItem];
      }
      
      completionHandler(error);
    }];
    
  }
  else {
    /**
     *  更新版本
     */
    
    //[DHBInitBusiness updateCurrentVersionWithItem:self.updateItem];
    
    completionHandler(nil);
  }
}
@end
