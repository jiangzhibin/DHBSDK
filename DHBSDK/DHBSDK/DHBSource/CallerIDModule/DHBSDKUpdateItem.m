//
//  DHBUpdateItem.m
//  CallerID
//
//  Created by Zhang Heyin on 15/8/13.
//  Copyright (c) 2015年 Yulore Inc. All rights reserved.
//

#import "DHBSDKUpdateItem.h"
/**
 {
 status: 0,
 type: 0,
 delta: "http://w01.yulore.com/apple/data_20150818_7",
 delta_hash: "aace0a07bc53789144daddcece87dce5",
 delta_size: "3804",
 full: "http://w01.yulore.com/apple/data_20150818",
 full_hash: "89f50fb35b8af6c0d30e8e1a898dad96",
 full_size: "6916",
 wait: 36000
 }
 */

@interface DHBSDKUpdateItem()
@property (nonatomic, assign) NSInteger retryTimes;
@end



@implementation DHBSDKUpdateItem
- (instancetype)init {
  self = [super init];
  if (self) {
    _retryTimes = 0;
    [self setNeedRetry:YES];
  }
  
  return self;
}


- (void)failed {
  
  _retryTimes++;
  if (_retryTimes >= 3) {
    [self setNeedRetry:NO];
  }
  else {
    [self setNeedRetry:YES];
  }
}


- (NSDate *)version {
  
  NSDate *versionDate = nil;
  if (self.deltaDownloadPath) {
    
    NSString *deltaString =  [[self.deltaDownloadPath  lastPathComponent] stringByDeletingPathExtension];
    
    NSArray *fileNameArray = [deltaString componentsSeparatedByString:@"_"];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT+0000"];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    NSDate *aDate = [dateFormatter dateFromString:[fileNameArray[1] stringByAppendingString:@""]];
    
//    NSInteger offset = [[fileNameArray lastObject] integerValue] + 1;
//    NSTimeInterval secondsPerDay = 24 * 60 * 60;
//    versionDate = [aDate dateByAddingTimeInterval:-secondsPerDay * offset];
    versionDate = aDate;
  }
  else {
    NSString *deltaString =  [[self.fullDownloadPath  lastPathComponent] stringByDeletingPathExtension];
    
    NSArray *fileNameArray = [deltaString componentsSeparatedByString:@"_"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT+0000"];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    versionDate = [dateFormatter dateFromString:[[fileNameArray lastObject]  stringByAppendingString:@""]];
    
  }

  return versionDate;
}

+ (instancetype)itemWithDictionary:(NSDictionary *)dictonary {
  
  DHBSDKUpdateItem *item = [[DHBSDKUpdateItem alloc] init];
  item.deltaDownloadPath = dictonary[@"delta_link"];
  item.deltaMD5 = dictonary[@"delta_hash"];
  item.deltaSize = [dictonary[@"delta_size"] integerValue];
    item.deltaVersion = [dictonary[@"data_ver"] integerValue];

  item.fullDownloadPath = dictonary[@"data_link"];
  item.fullMD5 = dictonary[@"data_hash"];
  item.fullSize = [dictonary[@"data_size"] integerValue];
    item.fullVersion = [dictonary[@"data_ver"] integerValue];
    

  return item;
  
  
}

-(void)print{
    NSLog(@"FULL: %@ %ld %@\nDELTA %@ %ld %@",[self fullDownloadPath],[self fullSize],[self fullMD5],[self deltaDownloadPath],[self deltaSize],[self deltaMD5]);
}

- (NSString *)changeNumberFormat:(NSString *)num
{
  if (num == nil) {
    return @"";
  }
  int count = 0;
  long long int a = num.longLongValue;
  while (a != 0) {
    count++;
    a /= 10;
  }
  
  NSMutableString *string = [NSMutableString stringWithString:num];
  NSMutableString *newstring = [NSMutableString string];
  
  while (count > 3) {
    count -= 3;
    NSRange rang = NSMakeRange(string.length - 3, 3);
    NSString *str = [string substringWithRange:rang];
    [newstring insertString:str atIndex:0];
    [newstring insertString:@"," atIndex:0];
    [string deleteCharactersInRange:rang];
  }
  [newstring insertString:string atIndex:0];
  
  return newstring;
}

- (NSString *)dataSizeString {
  return @"";//[self changeNumberFormat:[NSString stringWithFormat:@"%ld", self.dataSize]];
}

- (NSString *)versionString {

  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  dateFormatter.locale = [NSLocale currentLocale];
  
  NSString *showtimeNew = [NSDateFormatter localizedStringFromDate:self.version
                                                         dateStyle:NSDateFormatterMediumStyle
                                                         timeStyle:NSDateFormatterNoStyle];
  
  _versionString = showtimeNew;
  return _versionString;
}

//@property (nonatomic, copy) NSDate *version;
//
//
//@property (nonatomic, copy) NSString *deltaDownloadPath;
//@property (nonatomic, copy) NSString *deltaMD5;
//@property (nonatomic, assign) NSInteger deltaSize;
//@property (nonatomic, assign) NSInteger deltaVersion;
//
//@property (nonatomic, copy) NSString *fullDownloadPath;
//@property (nonatomic, copy) NSString *fullMD5;
//@property (nonatomic, assign) NSInteger fullSize;
//@property (nonatomic, assign) NSInteger fullVersion;
//
//
//@property (nonatomic, copy) NSString *versionString;
//@property (nonatomic, copy) NSString *dataSizeString;
//@property (nonatomic, assign, getter=isNeedRetry) BOOL needRetry;

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@:%p>{version:%@,\ndeltaDownloadPath:%@,\ndeltaMD5:%@,\ndeltaSize:%zd,\ndeltaVersion:%zd,\nfullDownloadPath:%@,\nfullMD5:%@,\nfullSize:%zd,\nfullVersion:%zd,\nversionString:%@,\ndataSizeString:%@,\nneedRetry:%zd}",[self class],self,_version,_deltaDownloadPath,_deltaMD5,_deltaSize,_deltaVersion,_fullDownloadPath,_fullMD5,_fullSize,_fullVersion,_versionString,_dataSizeString,_needRetry];
}
@end
