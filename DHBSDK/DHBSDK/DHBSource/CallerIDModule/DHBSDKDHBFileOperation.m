//
//  DHBFIleOpeation.m
//  Downloading
//
//  Created by Zhang Heyin on 15/8/11.
//  Copyright (c) 2015年 Yulore. All rights reserved.
//

#import "DHBSDKDHBFileOperation.h"
#import "DHBSDKFilePaths.h"
@implementation DHBSDKDHBFileOperation

+ (NSError *)rollbackOperation {
  NSString *backupTempFile = [DHBSDKFilePaths pathForBackupTempOfflineFilePath];
  NSString *oldFile = [DHBSDKFilePaths pathForFullOfflineFilePath];

  NSFileManager  *manager = [NSFileManager defaultManager];

  NSError *fileRollbackError = nil;
  BOOL opeationResult = [manager moveItemAtPath:backupTempFile toPath:oldFile error:&fileRollbackError];
  if (opeationResult == NO && fileRollbackError != nil) {
    
    return fileRollbackError;
  }

  return nil;
}


+ (NSError *)errorWithFileUpdateOperation {
  NSString *oldFile = [DHBSDKFilePaths pathForFullOfflineFilePath];
  
  NSString *deltaFile = [DHBSDKFilePaths pathForDeltaOfflineFilePath];
  
  NSString *newFile = [DHBSDKFilePaths pathForPreOfflineFilePath];
  
  NSString *backupTempFile = [DHBSDKFilePaths pathForBackupTempOfflineFilePath];

  NSFileManager  *manager = [NSFileManager defaultManager];

  BOOL opeationResult = NO;
  /**
   *  转移旧数据文件
   */
  NSError *backupFileError = nil;
  opeationResult = [manager moveItemAtPath:oldFile toPath:backupTempFile error:&backupFileError];
  if (opeationResult == NO && backupFileError != nil) {
    
    return backupFileError;
  }
  
  /**
   *  合成新数据文件更名 「OfflineFile」
   */
  NSError *fileMoveOpeationError = nil;
  opeationResult = [manager moveItemAtPath:newFile toPath:oldFile error:&fileMoveOpeationError];
  if (opeationResult == NO && fileMoveOpeationError != nil) {
    
    [self rollbackOperation];
    
    return fileMoveOpeationError;
  }
  
  /**
   *  更名后删除 delta 和 旧文件
   */
  
  /**
   *  删除backup
   */
  NSError *deleteBackupFileError = nil;
  opeationResult = [manager removeItemAtPath:backupTempFile error:&deleteBackupFileError];
  if (opeationResult == NO && deleteBackupFileError != nil) {
    
    return deleteBackupFileError;
  }
  
  /**
   *  删除delta
   */
  NSError *deleteDeltaFileError = nil;
  opeationResult = [manager removeItemAtPath:deltaFile error:&deleteDeltaFileError];
  if (opeationResult == NO && deleteDeltaFileError != nil) {
    
    return deleteDeltaFileError;
  }

  return nil;
}
@end
