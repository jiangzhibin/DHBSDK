//
//  YuloreApiManager.h
//  DHBDemo
//
//  Created by 蒋兵兵 on 16/8/8.
//  Copyright © 2016年 蒋兵兵. All rights reserved.
//

#import "DHBSDKApiManager.h"
#import "DHBSDKFilePaths.h"
#import "DHBSDKStartLoadingService.h"
#import "Commondef.h"
#import "DHBSDKMarkTeleHelper.h"
#import "DHBSDKDataFetcher.h"
#import "DHBSDKDownloadFetcher.h"
#import "DHBSDKResolveFecherNew.h"
#import "DHBSDKCovertIndexContent.h"
#import "DHBSDKAFNetworking.h"
#import "DHBSDKNetworkManager.h"
#import "DHBSDKUpdateItem.h"
#import "DHBSDKResolveItemNew.h"
#import "DHBErrorHelper.h"

/// ApiKey & Signature
static NSString * const kApiKeyString               = @"DHBSDKApiKeyString";
static NSString * const kSignatureString            = @"DHBSDKSignatureString";
/// 经纬度
static NSString * const kCoordinatelatitude         = @"kDHBSDKCoordinatelatitude";
static NSString * const kCoordinatelongitude        = @"kDHBSDKCoordinatelongitude";
/// CityId
static NSString * const kCityId                     = @"kDHBSDKCityId";
/// 下载网络类型
static NSString * const kDownloadNetworkType        = @"kDHBSDKDownloadNetworkType";
static NSString * const kShareGroupIdentifier       = @"kShareGroupIdentifier";

/*
a)	数据下载完成，显示进度75%，进入校验流程
b)	数据校验完成，显示90%，进入导入流程
c)	数据校验失败，则进入校验失败界面，选择【重新下载】、【取消】
*/
static float const kProgressPercentDownload             = 0.75f;
//static float const kProgressPercentDataValidate         = 0.90f;
//static float const kProgressPercentDownloadPercent      = 1.0f;


@interface DHBSDKApiManager ()

@end
@implementation DHBSDKApiManager
+ (instancetype)shareManager {
  static DHBSDKApiManager *apiManager;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
      apiManager = [DHBSDKApiManager new];
      [apiManager initializeValues];
      [[DHBSDKAFNetworkReachabilityManager sharedManager] startMonitoring];
      [[DHBSDKAFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(DHBSDKAFNetworkReachabilityStatus status) {
          [[NSNotificationCenter defaultCenter] postNotificationName:kDHBSDKNotifReachabilityStatusChanged object:@(status)];
      }];
  });
  return apiManager;
}

- (void)initializeValues {
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    
    // 经纬度
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [userDefaults doubleForKey:kCoordinatelatitude];
    coordinate.longitude = [userDefaults doubleForKey:kCoordinatelongitude];
    _coordinate = coordinate;
    
    // 城市id
    NSString *cityId = [userDefaults objectForKey:kCityId];
    _cityId = cityId ? [cityId copy] : @"0";
    
    // apikey & signature
    _apiKey = [[userDefaults objectForKey:kApiKeyString] copy];
    _signature = [[userDefaults objectForKey:kSignatureString] copy];
    
    // 网络类型 (未设置过，则为0，代表DHBSDKDownloadNetworkTypeWifiOnly 仅wifi)
    _downloadNetworkType = [userDefaults integerForKey:kDownloadNetworkType];
    
    // 数据共享标识
    _shareGroupIdentifier = [[userDefaults objectForKey:kShareGroupIdentifier] copy];
}

#pragma mark - properties getter && setter

/**
 设置城市id

 @param cityId 城市id
 */
- (void)setCityId:(NSString *)cityId {
    if (_cityId != cityId) {
        _cityId = [cityId copy];
        [[NSUserDefaults standardUserDefaults] setObject:cityId ?: @"0" forKey:kCityId];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

/**
 设置经纬度

 @param coordinate 经纬度
 */
- (void)setCoordinate:(CLLocationCoordinate2D)coordinate {
    if (_coordinate.latitude != coordinate.latitude
        && _coordinate.longitude != coordinate.longitude) {
        _coordinate = coordinate;
        [[NSUserDefaults standardUserDefaults] setDouble:coordinate.latitude forKey:kCoordinatelatitude];
        [[NSUserDefaults standardUserDefaults] setDouble:coordinate.longitude forKey:kCoordinatelongitude];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}


/**
 设置ApiKey

 @param apiKey apiKey
 */
- (void)setApiKey:(NSString *)apiKey {
    if (_apiKey != apiKey) {
        _apiKey = [apiKey copy];
        [[NSUserDefaults standardUserDefaults] setObject:apiKey forKey:kApiKeyString];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

/**
 设置Signature

 @param signature signature
 */
- (void)setSignature:(NSString *)signature {
    if (_signature != signature) {
        _signature = [signature copy];
        [[NSUserDefaults standardUserDefaults] setObject:signature forKey:kSignatureString];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)setDownloadNetworkType:(DHBSDKDownloadNetworkType)downloadNetworkType {
    if (_downloadNetworkType != downloadNetworkType) {
        _downloadNetworkType = downloadNetworkType;
        [[NSUserDefaults standardUserDefaults] setInteger:downloadNetworkType forKey:kDownloadNetworkType];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)setShareGroupIdentifier:(NSString *)shareGroupIdentifier {
    if (_shareGroupIdentifier != shareGroupIdentifier) {
        _shareGroupIdentifier = [shareGroupIdentifier copy];
        [[NSUserDefaults standardUserDefaults] setObject:shareGroupIdentifier forKey:kShareGroupIdentifier];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}



#pragma mark - 摘取自YuloreAPI.m
+ (BOOL) registerInfoApikey:(NSString *)apikey
                  signature:(NSString *)signature
                       host:(NSString *)host
                     {
    
    BOOL registered = NO;
    
    NSUserDefaults * pref = [NSUserDefaults standardUserDefaults];
    id __apikey = [pref objectForKey:kApiKeyString];
    
    if (__apikey) {
        registered = YES;
    }
    
    [DHBSDKApiManager shareManager].apiKey = apikey;
    [DHBSDKApiManager shareManager].signature = signature;
    [DHBSDKApiManager shareManager].host = host;
    return registered;
    
}

+ (void)copyInitDataCompletionBlock:(void (^)(NSError *error) )completionBlock  {
    
    dispatch_queue_t q = dispatch_queue_create("queue", 0);
    dispatch_async(q, ^{
        
        [DHBSDKStartLoadingService copyInitDataCompletionBlock:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // [StartLoadingService cacheCategoyDataFromInternet];
                [DHBSDKStartLoadingService updateLastVersion];
                completionBlock(nil);
            });
        }];
        
        
        //    dispatch_async(dispatch_get_main_queue(), ^{
        //      completionBlock(nil);
        //    });
    });
}


+ (BOOL)existedFolder
{
    BOOL isDir = NO;
    NSString *createFolder = [DHBSDKFilePaths pathForOfflineDataDirectory];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:createFolder isDirectory:&isDir];
    
    
    return existed;
}
+ (BOOL)registered {
    NSUserDefaults * pref = [NSUserDefaults standardUserDefaults];
    
    id __apikey = [pref objectForKey:kApiKeyString];
    id __signature = [pref objectForKey:kSignatureString];
    if (__apikey == nil || __signature == nil) {
        return NO;
    }
    
    if ([[DHBSDKApiManager shareManager].cityId isEqualToString:@"0"]) {
        return NO;
    }
    
    return YES;
}


+ (BOOL) registerApp:(NSString *)apikey
           signature:(NSString *)signature
                host:(NSString *)host
//              cityId:(NSString *)cityId
     completionBlock:(void (^)(NSError *error) )completionBlock {
    
    if (apikey == nil || [apikey isKindOfClass:[NSNull class]] || apikey.length < 4) {
        NSError *error = [NSError errorWithDomain:@"apikey无效" code:-1 userInfo:nil];
        completionBlock(error);
        return NO;
    }
    BOOL needToUpdate = [DHBSDKStartLoadingService fetcherLastVersion];
    BOOL registered = [self registerInfoApikey:apikey signature:signature host:host];
    if (!needToUpdate && registered) {
        if (![self existedFolder]) {
            [self copyInitDataCompletionBlock:^(NSError *error) {
                completionBlock(error);
            }];
        }
        else {
            completionBlock(nil);
        }
    }
    else {
        [self copyInitDataCompletionBlock:^(NSError *error) {
            completionBlock(error);
        }];
    }
    return YES;
}

#pragma mark - Public APIS
/**
 查询号码信息
 
 @param teleNumber        号码
 @param completionHandler 查询结果回调
 */
+ (void)searchTeleNumber:(nonnull NSString *)teleNumber
       completionHandler:(void (^)(DHBSDKResolveItemNew *resolveItem, NSError *error))completionHandler {
        [[DHBSDKResolveFecherNew sharedResolveFecherNew] resolveFectcherWithTelephoneNumber:teleNumber completionHandler:^(DHBSDKResolveItemNew *resolveItem, NSError *error) {
            if (completionHandler) {
                completionHandler(resolveItem,error);
            }
        }];
}

/**
 在线标记号码
 
 @param aNumber             电话号码
 @param flagInfomation      被标记的信息
 @param completeBlock       标记完成的回调
 */
+ (void)markTeleNumberOnlineWithNumber:(NSString *)aNumber
                        flagInfomation:(NSString *)flagInfomation
                     completionHandler:(void (^)( BOOL successed, NSError *error))completeBlock {
    [DHBSDKMarkTeleHelper markTeleNumberOnlineWithNumber:aNumber flagInfomation:flagInfomation completionHandler:completeBlock];
}

/**
 数据信息获取
 如 更新包下载地址及md5等，详情见DHBSDKUpdateItem.h
 @param completionHandler 回调
 */
+ (void)dataInfoFetcherCompletionHandler:(void(^)(DHBSDKUpdateItem *updateItem, NSError *error))completionHandler {
    [[DHBSDKDataFetcher sharedInstance] dataFetcherCompletionHandler:^(DHBSDKUpdateItem *updateItem, NSError *error) {
        completionHandler(updateItem,error);
    }];
}

/**
 下载 全量/增量包
 
 @param updateItem        下载所需的信息model
 @param packageType          下载的数据类型
 @param progressBlock     进度回调
 @param completionHandler 下载结束回调，error == nil，则下载失败；error == nil,下载成功
 */
+ (void)downloadDataWithUpdateItem:(DHBSDKUpdateItem *)updateItem
                          dataType:(DHBDownloadPackageType)packageType
                     progressBlock:(void(^)(double progress))progressBlock
                 completionHandler:(void(^)(NSError *error))completionHandler {
    if (updateItem == nil) {
        NSError *error = [NSError errorWithDomain:@"downloadDataWithUpdateItem 传入的 updateItem为空" code:-1 userInfo:nil];
        completionHandler(error);
        return;
    }
    
    // 网络状态及下载设置处理
    DHBSDKNetworkType networkType = [DHBSDKNetworkManager networkType];
    DHBSDKDownloadNetworkType downloadNetworkType = [DHBSDKApiManager shareManager].downloadNetworkType;
    NSError *error = nil;
    if (networkType == DHBSDKNetworkTypeNotReachable) {
        // 无网状态 提示连接网络
        error = [NSError errorWithDomain:DHBSDKDownloadErrorDomain code:DHBSDKDownloadErrorCodeNetworkNotReachable userInfo:@{@"description":@"下载失败：网络不可用"}];
        completionHandler(error);
        return;
    }
    if (downloadNetworkType == DHBSDKDownloadNetworkTypeNotAllow) {
        // 未允许下载 提示打开下载
        error = [NSError errorWithDomain:DHBSDKDownloadErrorDomain code:DHBSDKDownloadErrorCodeNotAllow userInfo:@{@"description":@"下载失败：用户已设置不允许下载"}];
        completionHandler(error);
        return;
    }
    if (networkType == DHBSDKNetworkTypeViaWWAN
        && downloadNetworkType == DHBSDKDownloadNetworkTypeWifiOnly) {
        // 未打开数据流量下载
        error = [NSError errorWithDomain:DHBSDKDownloadErrorDomain code:DHBSDKDownloadErrorCodeWWANDownloadNotAllow userInfo:@{@"description":@"下载失败：当前为3G/4G网络，用户仅允许WiFi下载"}];
        completionHandler(error);
        return;
    }
    NSError *batteryLevelError = [DHBErrorHelper errorWithBatteryLevel];
    if (batteryLevelError) {
        // 电量过低
        error = [NSError errorWithDomain:DHBSDKDownloadErrorDomain code:DHBSDKDownloadErrorCodeBatteryLevelTooLow userInfo:@{@"description":@"下载失败：当前电量过低，不允许下载"}];
        completionHandler(error);
        return;
    }
    
    
    // 下载
    [[DHBSDKDownloadFetcher sharedInstance] baseDownloadingWithType:packageType updateItem:updateItem progressBlock:^(double progress, long long totalBytes) {
        progressBlock(progress * kProgressPercentDownload);
    } completionHandler:^(BOOL retry, NSError *error) {
        if (error) {
            completionHandler(error);
            return ;
        }
        
        [[DHBSDKCovertIndexContent sharedInstance] needReload];
        dispatch_queue_t q = dispatch_queue_create("com.dhbsdk.callerid.dataloader", 0);
        dispatch_async(q, ^{
            [[DHBSDKCovertIndexContent sharedInstance] readDataFromFile:^(float progress) {
                progressBlock(kProgressPercentDownload + progress * (1 - kProgressPercentDownload)+0.005);
            } completionHandler:^(NSError *error) {
                completionHandler(error);
            }];
        });
    }];
}

- (NSString *)pathForBridgeOfflineFilePath {
    return [DHBSDKFilePaths pathForBridgeOfflineFilePath];
}

@end
