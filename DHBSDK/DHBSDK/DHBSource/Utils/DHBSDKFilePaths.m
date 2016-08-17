//
//  DHBSDKFilePaths.m
//  DHBDemo
//
//  Created by 蒋兵兵 on 16/8/17.
//  Copyright © 2016年 蒋兵兵. All rights reserved.
//

#import "DHBSDKFilePaths.h"
#import "DHBSDKApiManager.h"

@implementation DHBSDKFilePaths

+ (NSString *)pathForDirectory:(NSSearchPathDirectory)directoryConstant domainMask:(NSSearchPathDomainMask)domainMask
{
    NSFileManager* sharedFM = [NSFileManager defaultManager];
    NSArray *possiblepaths = [sharedFM URLsForDirectory:directoryConstant
                                              inDomains:domainMask];
    NSURL *path = nil;
    
    if ([possiblepaths count] >= 1) {
        // Use the first directory (if multiple are returned)
        path = [possiblepaths objectAtIndex:0];
    }
    
    return path.path;
}

+ (NSString *)pathForLibraryDirectory {
    return [self pathForDirectory:NSLibraryDirectory domainMask:NSUserDomainMask];
}


+ (NSString *)pathForOfflineDataDirectory {
    return [[self pathForLibraryDirectory] stringByAppendingString:@"/Caches/OfflineData/"];
}

/**
 *  pathForOfflineLOGOFile
 *
 *  @return pathForOfflineLOGOFile
 */
+ (NSString *)pathForOfflineLOGOWithShopID:(NSString *)shopID {
    return [[self pathForOfflineDataDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"logo/%@", shopID]];
}



/**
 *  CATEGORY
 */

+ (NSString *)pathForOriginalCategoryDataFile {
    NSString *path = [[self pathForOfflineDataDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"c0.json"]];
    return path;
}


+ (NSString *)pathForCategoryDataFileWithCityID:(NSString *)cityID {
    NSString *fileName = [NSString stringWithFormat:@"category%@.dat", cityID];
    NSString *cityCategoryFilePath = [[self pathForOfflineDataDirectory] stringByAppendingPathComponent:fileName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:cityCategoryFilePath]) {
        return cityCategoryFilePath;
    }else {
        return [self pathForOriginalCategoryDataFile];
    }
    
}




+ (NSString *)pathForMajorDirectory {
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"DHBSDKFiles"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:nil];
    }
    return path;
}

+ (NSString *)pathForShareGroupContainerDirectory {
    NSString *identifier = [DHBSDKApiManager shareManager].shareGroupIdentifier;
    if (identifier
        && ![identifier isKindOfClass:[NSNull class]]
        && identifier.length > 0) {
        return [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:identifier].path;
    }
    return [self pathForMajorDirectory];
}

+ (NSString *)pathForBackupTempOfflineFilePath {
    return [NSTemporaryDirectory() stringByAppendingString:@"/BackupOfflineFile"];
}

// 处理好的数据文件
+ (NSString *)pathForBridgeOfflineFilePath {
    return [[self pathForShareGroupContainerDirectory] stringByAppendingString:@"/BridgeFile"];
}

+ (NSString *)pathForDeltaOfflineFilePath {
    return [[self pathForMajorDirectory] stringByAppendingString:@"/DeltaFile"];
}

+ (NSString *)pathForFullOfflineFilePath {
    return [[self pathForMajorDirectory] stringByAppendingString:@"/OfflineFile"];
}


+ (NSString *)pathForPreOfflineFilePath {
    return [[self pathForMajorDirectory] stringByAppendingString:@"/PreOfflineFile"];
}

@end
