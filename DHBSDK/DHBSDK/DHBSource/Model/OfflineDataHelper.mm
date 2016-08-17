//
//  OfflineDataHelper.m
// DianHuaBang
//
//  Created by Zhang Heyin on 13-7-23.
//  Copyright (c) 2013年 Yulore. All rights reserved.
//
#import "DHBSDKYP_ASIDataDecompressor.h"
#import "OfflineDataHelper.h"
//#import "FMDatabase.h"
#include <string>
#import "CommonTmp.h"
#import "Commondef.h"
using namespace std;


static NSString *const dhbsdkchinese = @"chinese";
static NSString *const dhbsdkpinyin = @"pinyin";
//static NSString *const dhbsdkchinese = @"pinyinindex";
//static NSString *const dhbsdkchinese = @"pinyinshort";
//static NSString *const dhbsdkchinese = @"pinyinshortindex";
//static NSString *const dhbsdkchinese = @"offset";
//static NSString *const dhbsdkchinese = @"chinese";
//static NSString *const dhbsdkchinese = @"chinese";


@implementation OfflineDataHelper

+ (NSString *)cacheDir {
  return [DHBSDKFilePaths pathForOfflineDataDirectory];
}

+ (NSString *)databasePath {
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentDirectory = [paths objectAtIndex:0];
  //dbPath： 数据库路径，在Document中。
  NSString *dbPath = [documentDirectory stringByAppendingPathComponent:@"yulore.db"];
  return dbPath;
}

//此方法是根据路径解压id。dat文件
//+ (void)




/*
+ (void)pinyinWithOffset:(NSUInteger) offset readLength:(long)readLength
                    city:(City *)aCity{
  
  //fclose(fp);
  FILE *fp = fopen([[[self cacheDir] stringByAppendingFormat:@"/d%@_id.dat", aCity.cityID] UTF8String],"r");
  if (fp == NULL) {
    NSString * filePath = [[self cacheDir] stringByAppendingFormat:@"/d%@_id.dat", @"0"];
    fp = fopen([filePath UTF8String],"r");
  }
  //NSMutableData *compreseData2 = [[NSMutableData alloc] init];
  
  
  // int c = 0xff;
  //int pre = 0xff;
  //long offsete = 0;
  fseek(fp, offset , SEEK_SET);
  
  char *buffer = (char*)malloc(readLength);
  memset(buffer, 0, readLength);
  
  fread(buffer, 1,readLength , fp);
  
  
  
  char *bufferPreDepress = (char *)malloc(readLength + 7);
  memset(bufferPreDepress , 0, readLength + 7);
  bufferPreDepress[0] = 0x1f;
  bufferPreDepress[1] = 0x8b;
  bufferPreDepress[2] = 0x08;
  bufferPreDepress[3] = 0x00;
  bufferPreDepress[4] = 0x00;
  bufferPreDepress[5] = 0x00;
  bufferPreDepress[6] = 0x00;
  bufferPreDepress[7] = 0x00;
  bufferPreDepress[8] = 0x00;
  bufferPreDepress[9] = 0x03;
  memcpy(bufferPreDepress + 10, (buffer + 3), readLength - 3);
  //  NSString *filename = [NSString stringWithFormat:@"/datapinyin_%@_%d.dat", aCity.cityID, offset];
  // NSString *apartFilePath = [[self cacheDir] stringByAppendingString:filename];
  NSData *newNSData = [NSData dataWithBytes:bufferPreDepress length:readLength + 7];
  //NSData *newNSDatax = [NSData dataWithBytes:buffer length:readLength];
  // [newNSDatax writeToFile:[NSString stringWithFormat:@"%@.dat",apartFilePath] atomically:YES];
  // [newNSData writeToFile:[NSString stringWithFormat:@"%@.gz",apartFilePath] atomically:YES];
  
  [YP_ASIDataDecompressor uncompressData:newNSData error:nil];
  // [decompressedData writeToFile:apartFilePath atomically:YES];
  
  free(buffer);
  free(bufferPreDepress);
  
  fclose(fp);
  
}

*/

/*
+ (BOOL)decompressPinyinDataWithOffset:(NSArray *)offsetArray
                              withCity:(City *)aCity{
  NSString *filePath = [[self cacheDir] stringByAppendingFormat:@"/d%@_id.dat", aCity.cityID];
  FILE *fp = fopen([filePath UTF8String],"r");
  NSMutableData *compreseData = [[NSMutableData alloc] init];
  int c = 0xff;
  int pre = 0xff;
  long offsete = 0;
  fseek(fp, 0, SEEK_SET);
  while((c=fgetc(fp))!=EOF) {
    //printf("%.2x ",c);
    [compreseData appendBytes:&c  length:1];
    if ((c || pre) == 0x00) {
      //这里是是位置
      // DHBSDKDLog(@"");
      offsete = ftell(fp);
      break;
    }
    pre = c;
  }
  fclose(fp);
  NSUInteger offsetH = [compreseData length] + 1;
  
  for( int i = 1; i < [offsetArray count] ; i++) {
    
    NSUInteger offsetV = [[offsetArray objectAtIndex:i-1] integerValue];
    NSUInteger readLength = [[offsetArray objectAtIndex:i] integerValue] - [[offsetArray objectAtIndex:i-1] integerValue];
    DHBSDKDLog(@"offsetV %lu , readLength %lu  i = %d", (unsigned long)offsetV, (unsigned long)readLength, i);
    [self pinyinWithOffset:offsetH + offsetV readLength:readLength  city:aCity];
  }
  
  return YES;
  
}
 */



+ (BOOL)decompress:(DHBSDKDataFileType)type cityId:(NSString *)cityId {
  
  NSString *orignalDatFilePath = nil;
  NSString *decompressJsonFilePath = nil;
  NSUInteger cutsize = 0;
  switch (type) {
    case DHBSDKDataPinyin: {
      cutsize = 3;
      orignalDatFilePath = [[self cacheDir] stringByAppendingFormat:@"d%@_id.dat",cityId];
      decompressJsonFilePath = [[self cacheDir]  stringByAppendingFormat:@"d%@_id.json", cityId];
    }
      break;
    case DHBSDKDataCategory: {
      cutsize = 6;
      orignalDatFilePath = [[self cacheDir]  stringByAppendingFormat:@"d%@_ic.dat", cityId];
      decompressJsonFilePath = [[self cacheDir]  stringByAppendingFormat:@"d%@_ic.json",cityId];
    }
      break;
    default:
      break;
  }
  
  
  char *append = (char *)malloc(10);
  append[0] = 0x1f;
  append[1] = 0x8b;
  append[2] = 0x08;
  append[3] = 0x00;
  append[4] = 0x00;
  append[5] = 0x00;
  append[6] = 0x00;
  append[7] = 0x00;
  append[8] = 0x00;
  append[9] = 0x03;
  
  NSData *orignalData = [NSData dataWithContentsOfFile:orignalDatFilePath];
  NSData *subIC = [orignalData subdataWithRange:NSMakeRange(cutsize, [orignalData length] -cutsize)];
  NSData *appendData = [NSData dataWithBytes:append length:10];
  NSMutableData *newData = [NSMutableData dataWithData:appendData];
  [newData appendData:subIC];
  NSData *newNSData = [NSData dataWithData:newData];
  
  // [newNSData writeToFile:decompressedDatafileName atomically:YES];
  NSData *decompressedData = [DHBSDKYP_ASIDataDecompressor uncompressData:newNSData error:nil];
  BOOL result =  [decompressedData writeToFile:decompressJsonFilePath atomically:YES];
  
  if (type == DHBSDKDataPinyin) {
    NSError *error = nil;
    // NSArray *results = decompressedData ? [NSJSONSerialization JSONObjectWithData:decompressedData options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:&error] : nil;
    if (error) DHBSDKDLog(@"[%@ %@] JSON error: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), error.localizedDescription);
    // [self decompressPinyinDataWithOffset:results withCity:aCity];
  }
  
  
  
  
  
  return result;
}


+ (BOOL)decompressDatFileWithCityId:(NSString *)cityId{
  BOOL pinyinDatFileResult = [self decompress:DHBSDKDataPinyin cityId:cityId];
  BOOL categoryDatFileResult = [self decompress:DHBSDKDataCategory cityId:cityId];
  return (pinyinDatFileResult && categoryDatFileResult);
}


+ (NSString *)nationaldataFilePath:(DHBSDKDataFileType)type {
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
  NSString *documentDirectory = [paths objectAtIndex:0];
  NSString *dbPath = nil;
  switch (type) {
    case DHBSDKDataPinyin:{
      dbPath = [documentDirectory stringByAppendingFormat:@"/Caches/OfflineData/d0_id.json"];
    }
      break;
    case DHBSDKDataCategory: {
      dbPath = [documentDirectory stringByAppendingFormat:@"/Caches/OfflineData/d0_ic.json"];
    }
      break;
    case DHBSDKDataCategoryDat: {
      dbPath = [documentDirectory stringByAppendingFormat:@"/Caches/OfflineData/d0_ic.dat"];
    }
      break;
    case DHBSDKDataDetail: {
      dbPath = [documentDirectory stringByAppendingFormat:@"/Caches/OfflineData/d0.dat"];
      
    }
      
      break;
    default:
      break;
  }
  return dbPath;
}

+ (NSString *)dataFilePath:(DHBSDKDataFileType)type {
  NSString *cityid = [DHBSDKApiManager shareManager].cityId;
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
  NSString *documentDirectory = [paths objectAtIndex:0];
  NSString *dbPath = nil;
  switch (type) {
    case DHBSDKDataPinyin:{
      dbPath = [documentDirectory stringByAppendingFormat:@"/Caches/OfflineData/d%@_id.json", cityid];
    }
      break;
    case DHBSDKDataCategory: {
      dbPath = [documentDirectory stringByAppendingFormat:@"/Caches/OfflineData/d%@_ic.json", cityid];
    }
      break;
    case DHBSDKDataCategoryDat: {
      dbPath = [documentDirectory stringByAppendingFormat:@"/Caches/OfflineData/d%@_ic.dat", cityid];
    }
      break;
    case DHBSDKDataDetail: {
      dbPath = [documentDirectory stringByAppendingFormat:@"/Caches/OfflineData/d%@.dat", cityid];
      
    }
      
      break;
    default:
      break;
  }
  
  FILE *fp = fopen([dbPath UTF8String],"r");
  if (fp == NULL) {
    dbPath = [self nationaldataFilePath:type];
  }
  
  
  return dbPath;

  
}

+ (BOOL)hasCategoryData {
  NSString *dbPath = [self dataFilePath:DHBSDKDataCategoryDat];
  NSError *error= nil;
  NSData *aData = [NSData dataWithContentsOfFile:dbPath options:0 error:&error];
  
  
  if (aData != nil) {
    return YES;
  } else {
    return NO;
  }
}

+ (NSData *)dataOfFilePath:(DHBSDKDataFileType)type {
  
  NSString *dbPath = [self dataFilePath:type];
  NSError *error= nil;
  NSData *aData = [NSData dataWithContentsOfFile:dbPath options:0 error:&error];
  return aData;
}
//
//+ (BOOL) updateCityDataDeleteWithCityID :(NSInteger)aCity{
//  BOOL result = NO;
//  FMDatabase *db = [FMDatabase databaseWithPath:[self databasePath]];
//  if (![db open]) {
//    DHBSDKDLog(@"Could not open db.");
//    return NO;
//  } else {
//    NSString * SQLUPDATE=[NSString stringWithFormat:@"UPDATE city SET selected=0  ,DataVersion = 0 WHERE c_id=%ld", (long)aCity];
//    result = [db executeUpdate:SQLUPDATE];
//  }
//  // [db close];
//  return result;
//  
//  
//}
//
//+ (BOOL) updateCityDataDelete :(City *)aCity{
//  BOOL result = NO;
//  FMDatabase *db = [FMDatabase databaseWithPath:[self databasePath]];
//  if (![db open]) {
//    DHBSDKDLog(@"Could not open db.");
//    return NO;
//  } else {
//    NSString * SQLUPDATE=[NSString stringWithFormat:@"UPDATE city SET selected=0  ,DataVersion = 0 WHERE c_id=%@", aCity.cityID];
//    result = [db executeUpdate:SQLUPDATE];
//  }
//  // [db close];
//  return result;
//  
//  
//}

//
//+ (BOOL)deleteSelectedCityID:(NSInteger)aCity {
//  BOOL bIC = NO;
//  BOOL bID = NO;
//  BOOL bData = NO;
//  
//  NSFileManager *fileManager =[NSFileManager defaultManager];
//  NSString *folderName = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/OfflineData/"];
//  NSString * fileName = nil;
//  fileName=[folderName stringByAppendingFormat:@"/d%ld_ic.dat",(long)aCity];
//  if ([fileManager fileExistsAtPath:fileName]) {
//    bIC = [fileManager removeItemAtPath:fileName error:nil];
//  }
//  
//  fileName=[folderName stringByAppendingFormat:@"/d%ld_id.dat",(long)aCity];
//  if ([fileManager fileExistsAtPath:fileName]) {
//    bID = [fileManager removeItemAtPath:fileName error:nil];
//  }
//  
//  fileName=[folderName stringByAppendingFormat:@"/d%ld_ic.json",(long)aCity];
//  if ([fileManager fileExistsAtPath:fileName]) {
//    bIC = [fileManager removeItemAtPath:fileName error:nil];
//  }
//  
//  fileName=[folderName stringByAppendingFormat:@"/d%ld_id.json",(long)aCity];
//  if ([fileManager fileExistsAtPath:fileName]) {
//    bID = [fileManager removeItemAtPath:fileName error:nil];
//  }
//  
//  
//  
//  fileName=[folderName stringByAppendingFormat:@"/d%ld.dat",(long)aCity];
//  if ([fileManager fileExistsAtPath:fileName]) {
//    bData = [fileManager removeItemAtPath:fileName error:nil];
//  }
//  
//  
//  fileName=[folderName stringByAppendingFormat:@"/c%ld.json",(long)aCity];
//  if ([fileManager fileExistsAtPath:fileName]) {
//    bIC = [fileManager removeItemAtPath:fileName error:nil];
//  }
//  
//  return bIC && bID && bData;
//  
//}
//
//+ (BOOL)deleteSelected:(City *)aCity {
//  return [self deleteSelectedCityID:[aCity.cityID integerValue]];
//}
//

//////////////
#pragma
#pragma PINYIN


+ (NSInteger)headerPinyinIndexFileOffset:(NSString *)cityID {
  NSString *filePath = [[self cacheDir] stringByAppendingFormat:@"/d%@_id.dat", cityID];
  FILE *fp = fopen([filePath UTF8String],"r");
  if (fp == NULL) {
    filePath = [[self cacheDir] stringByAppendingFormat:@"/d%@_id.dat", @"0"];
    fp = fopen([filePath UTF8String],"r");
  }
  int c = 0xff;
  int pre = 0xff;
  long offsete = 0;
  fseek(fp, 0, SEEK_SET);
  //1.	此文件头部为GZIP压缩的JSON字符串，读到连续至少2字节0的非0字节前（包含所有读到的0），记录读到的字节数（H）。
  bool canFinish = false;
  while((c=fgetc(fp))!=EOF) {
    if (canFinish) {
      if (c != 0x00) {
        offsete = ftell(fp);
        break;
      }
    } else {
      if ((c || pre) == 0x00) {
        canFinish = YES;
      }
    }
    pre = c;
  }
  fclose(fp);
  
  return offsete - 1;
}


+ (NSMutableArray *)headerArray {
  
  NSString *currentSelectedCityID = [DHBSDKApiManager shareManager].cityId;
  NSString *filePath = [[self cacheDir] stringByAppendingFormat:@"/d%@_id.json",currentSelectedCityID];
  NSString *pinyinIndexJsonFilePath =filePath;
  
  FILE *fp = fopen([filePath UTF8String],"r");
  if (fp == NULL) {
    pinyinIndexJsonFilePath =  filePath = [[self cacheDir] stringByAppendingFormat:@"/d%@_id.json", @"0"];
    // fp = fopen([filePath UTF8String],"r");
  }
  
  
  
  NSData *jsonData = [NSData dataWithContentsOfFile:pinyinIndexJsonFilePath];
  
  
  
  NSError *error = nil;
  NSMutableArray *resultsjson = jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:&error] : nil;
  if (error) DHBSDKDLog(@"[%@ %@] JSON error: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), error.localizedDescription);
  
  return resultsjson;
}


+ (NSMutableArray *)pinyinIndexFileOffsetArray {
  NSMutableArray *offsetArray = [[NSMutableArray alloc] init];
  NSInteger headerOffset = [self headerPinyinIndexFileOffset:[DHBSDKApiManager shareManager].cityId];
  
  NSMutableArray *headerArray = [self headerArray];
  NSInteger count = [headerArray count];
  if (count == 1) {
    count = 2;
  }
  
  for (int i = 0; i < count - 1; i++) {
    [offsetArray addObject:[NSNumber numberWithInteger:headerOffset + [[headerArray objectAtIndex:i] integerValue]]];
  }
  
  return offsetArray;
}


+ (NSMutableArray *)pinyinGzipFileLengthArray {
  
  NSMutableArray *headerArray = [self headerArray];
  
  NSMutableArray *GzipFileLengthArray = [[NSMutableArray alloc] init];
  
  NSInteger count = [headerArray count];
  if (count == 1) {
   // count++;
        NSString * filePath = [[self cacheDir] stringByAppendingFormat:@"/d%@_id.dat", @"0"];
    unsigned long long size = [self fileSizeAtPath:filePath];
    [GzipFileLengthArray addObject:[NSNumber numberWithUnsignedLong:((long)size - [[headerArray objectAtIndex:0] integerValue])]];
  } else {
  for (int i = 1; i < count; i++) {
    [GzipFileLengthArray addObject:[NSNumber numberWithInteger:([[headerArray objectAtIndex:i] integerValue] - [[headerArray objectAtIndex:i - 1] integerValue])]];
  }
  }
  return GzipFileLengthArray;
}


+ (BOOL)recordContent3:(char *)content length:(NSInteger)length keyWords:(string)keyWords{
  //NSMutableArray *contentArray = [NSMutableArray array];
  //NSMutableDictionary *contentDic = [NSMutableDictionary dictionary];
  string mString = string(content);
  BOOL b = NO;
  
  string::size_type position;
  transform(mString.begin(), mString.end(), mString.begin(), ::tolower);
  position = mString.find(keyWords);
  if (position != mString.npos)  //如果没找到，返回一个特别的标志c++中用npos表示，我这里npos取值是4294967295，
  {
    
    b = YES;
  }
  else
  {
    b = NO;
  }
  
  return b;
}




+ (NSMutableDictionary *)recordContent2:(char *)content length:(NSInteger)length{
  NSMutableArray *contentArray = [NSMutableArray array];
  NSMutableDictionary *contentDic = [NSMutableDictionary dictionary];
  
  NSArray *keyArray1 = @[@"chinese", @"pinyin", @"pinyinindex", @"pinyinshort", @"pinyinshortindex", @"offset", @"length"];
  NSArray *keyArray2 = @[@"chinese", @"pinyin", @"pinyinindex", @"offset", @"length"];
  //char *currentTempString = (char * )malloc(length);
  //memset(currentTempString, 0, length);
  //aomemcpy(currentTempString, content, length);
  
  // NSString *stringTemp = [NSString stringWithCString:content encoding:NSUTF8StringEncoding];
  // NSCharacterSet *whitespace = [NSCharacterSet  whitespaceAndNewlineCharacterSet];
  //NSArray *contentArray = [stringTemp componentsSeparatedByCharactersInSet:whitespace];
  
  
  string temp;
  for  (int i = 0; i < length; i++) {
    if (content[i] == 0x20 || content[i] == 0x09 || content[i] == 0x0a) {
      
      [contentArray addObject:[NSString stringWithCString:temp.c_str() encoding:NSUTF8StringEncoding]];
      temp = "";
      
      if(content[i] == 0x0a) {
        break;
      }
    } else {
      temp.append(1,content[i]);
      continue;
    }
  }
  if ([contentArray count] > 5) {
    for (int i = 0; i < [contentArray count]; i++) {
      [contentDic setValue:[contentArray objectAtIndex:i]
                    forKey:[keyArray1 objectAtIndex:i]];
    }
    
  } else {
    for (int i = 0; i < [contentArray count]; i++) {
      [contentDic setValue:[contentArray objectAtIndex:i]
                    forKey:[keyArray2 objectAtIndex:i]];
    }
  }

  return contentDic;
}




+ (NSMutableArray *)recordContent:(char *)content length:(NSInteger)length{
  NSMutableArray *contentArray = [[NSMutableArray alloc] init];
  NSMutableData *tempData = [[NSMutableData alloc] init];
  NSString *tempString = [[NSString alloc] init];
  char  *b = (char *)malloc(1);
  //string temp;
  for  (int i = 0; i < length; i++) {
    if (content[i] == 0x20 || content[i] == 0x09 || content[i] == 0x0a) {
      
      tempString = [[NSString alloc] initWithData:tempData encoding:NSUTF8StringEncoding];
      [contentArray addObject:tempString];
      
      tempData = [[NSMutableData alloc] init];
      if(content[i] == 0x0a) {
        break;
      }
    } else {
      
      b[0] = content[i];
      [tempData appendBytes:b length:1];
      
      continue;
    }
  }
  
  return contentArray;
}

+ (NSMutableArray *)indexRecordArray:(NSData *)decompressedData keyWords:(NSString *)keyWords  {
  
  NSMutableArray *array = [NSMutableArray array];
  //  NSMutableData *aRecordData = [[NSMutableData alloc] init];
  
  char *decompressedDataPoint = (char *)malloc([decompressedData length]);
  memset(decompressedDataPoint, 0, [decompressedData length]);
  memcpy(decompressedDataPoint, [decompressedData bytes], [decompressedData length]);
  char *point = decompressedDataPoint;
  long endofpos = [decompressedData length];
  long offset = 0;
  long lastPos = 0;
  
  long byteLength = 0;
  
  char *content = (char *)malloc(512);
  memset(content, 0, 512);
  string strkeyWords =string( [keyWords UTF8String]);
  transform(strkeyWords.begin(), strkeyWords.end(), strkeyWords.begin(), ::tolower);
  while (offset < endofpos) {
    
    //DLog(@"ddewe %ld %X", offset, (Byte)point[offset]);
    if ((Byte)point[offset] == 0x0a) {
      byteLength = offset - lastPos + 1;
      memcpy(content, decompressedDataPoint + lastPos, byteLength);
      lastPos = offset + 1;
      //DLog(@"start1");
      BOOL b = [self recordContent3:content length:byteLength keyWords:strkeyWords];
      //NSMutableDictionary *aRecord = [self recordContent2:content length:byteLength];
      // DLog(@"start2");
      if (!b) {
        offset++;
        continue;
      } else {
        
        //找到复合关键字的数据
        NSMutableDictionary *aRecord = [self recordContent2:content length:byteLength];
        [array addObject:aRecord];
      }
      
      //[array addObject:aRecord];
      // NSString *string = [[NSString alloc] initWithBytes:content length:byteLength encoding:NSUTF8StringEncoding];
      //[array addObject:string];
      //DLog(@"ddewe %ld", offset);
    } else {
      // DLog(@"char %X",(Byte)point[0]);
    }
    offset++;
  }
  free(decompressedDataPoint);
  return array;
}


+ (BOOL)inputCharacterType:(NSString *)inputString {
  BOOL type = NO;
  NSUInteger alength = [inputString length];
  for (int i = 0; i<alength; i++) {
    //  char commitChar = [inputString characterAtIndex:i];
    NSString *temp = [inputString substringWithRange:NSMakeRange(i,1)];
    const char *u8Temp = [temp UTF8String];
    if (3 == strlen(u8Temp)){
      type = YES;//DLog(@"字符串中含有中文");
    }else {
      type = NO;
    }
  }
  
  
  return type;
}


+ (NSArray *)filterContentForSearchText:(NSString*)searchText
                            recordArray:(NSMutableArray *)recordArray {
  
  NSString *match = [NSString stringWithFormat:@"*%@*", searchText];
  
  //NSString *format = ([self inputCharacterType:searchText]) ? [CITYNAME stringByAppendingString:@" like[cd] %@"] : [ stringByAppendingString:@" like[cd] %@"];//"cityname like[cd] %@" : @"city_en like[cd] %@";
  NSArray *filterArray = [[NSMutableArray alloc] init];
  if ([self inputCharacterType:searchText]) {
    NSString *format = [dhbsdkchinese stringByAppendingString:@" like[cd] %@"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:format, match];
    
    filterArray = [recordArray filteredArrayUsingPredicate:predicate];
  } else {
    NSString *format_en = [dhbsdkpinyin stringByAppendingString:@" like[cd] %@"];
    // NSString *format_sen = [CITYSENAME stringByAppendingString:@" like[cd] %@"];
    NSPredicate *predicate_en = [NSPredicate predicateWithFormat:format_en, match];
    // NSPredicate *predicate_sen = [NSPredicate predicateWithFormat:format_sen, match];
    
    NSArray *searchCityWithEN = [recordArray filteredArrayUsingPredicate:predicate_en];
    // NSArray *searchCityWithSEN = [self.cityArrayNative filteredArrayUsingPredicate:predicate_sen];
    
    
    
    //NSPredicate *thePredicate = [NSPredicate predicateWithFormat:@"NOT (SELF in %@)", searchCityWithSEN];
    
    // searchCityWithEN = [searchCityWithEN filteredArrayUsingPredicate:thePredicate];
    
    NSArray *result = searchCityWithEN;//[searchCityWithEN arrayByAddingObjectsFromArray:searchCityWithSEN];
    
    
    /*按照ranking排序*/
    NSArray *resultSorted = [result sortedArrayUsingComparator:^(id obj1,id obj2) {
      NSDictionary *dic1 = (NSDictionary *)obj1;
      NSDictionary *dic2 = (NSDictionary *)obj2;
      NSNumber *num1 = (NSNumber *)[dic1 objectForKey:@""];
      NSNumber *num2 = (NSNumber *)[dic2 objectForKey:@""];
      if ([num1 integerValue] > [num2 integerValue])
      {
        return (NSComparisonResult)NSOrderedDescending;
      }
      else
      {
        return (NSComparisonResult)NSOrderedAscending;
      }
      return (NSComparisonResult)NSOrderedSame;
    }];
    // DLog(@"%@", resultSorted);
    
    filterArray = resultSorted;
    
  }
  
  
  return filterArray;
}


+(unsigned long long) fileSizeAtPath:(NSString*) filePath{
  NSFileManager* manager = [NSFileManager defaultManager];
  if ([manager fileExistsAtPath:filePath]){
    return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
  }
  return 0;
}
+ (NSArray *)pinyinIndexWithKeyWords:(NSString *)keyWords {
  NSArray *results = [NSArray array];
  NSMutableArray *pinyinIndexArray = [NSMutableArray array];
  
  NSData *decompressedData = [NSData data];
  NSString *currentSelectedCityID = [DHBSDKApiManager shareManager].cityId;
  //fclose(fp);
  NSMutableArray *offsetArray = [self pinyinIndexFileOffsetArray];
  NSMutableArray *gzipLengthArray = [self pinyinGzipFileLengthArray];
  FILE *fp = fopen([[[self cacheDir] stringByAppendingFormat:@"/d%@_id.dat", currentSelectedCityID] UTF8String],"r");
  //NSArray *apartResults = [NSArray array];
  if (fp == NULL) {
    NSString * filePath = [[self cacheDir] stringByAppendingFormat:@"/d%@_id.dat", @"0"];
    fp = fopen([filePath UTF8String],"r");
  }
  for (int i = 0; i < [offsetArray count]; i++) {
    
    NSInteger readLength = [[gzipLengthArray objectAtIndex:i] integerValue];
    
    fseek(fp, [[offsetArray objectAtIndex:i] integerValue] , SEEK_SET);
    
    char *buffer = (char*)malloc(readLength);
    memset(buffer, 0, readLength);
    
    fread(buffer, 1, readLength, fp);
    
    char *bufferPreDepress = (char *)malloc(readLength + 7);
    memset(bufferPreDepress , 0, readLength + 7);
    bufferPreDepress[0] = 0x1f;
    bufferPreDepress[1] = 0x8b;
    bufferPreDepress[2] = 0x08;
    bufferPreDepress[3] = 0x00;
    bufferPreDepress[4] = 0x00;
    bufferPreDepress[5] = 0x00;
    bufferPreDepress[6] = 0x00;
    bufferPreDepress[7] = 0x00;
    bufferPreDepress[8] = 0x00;
    bufferPreDepress[9] = 0x03;
    memcpy(bufferPreDepress + 10, (buffer + 3), readLength - 3);
    //NSString *filename = [NSString stringWithFormat:@"/datapinyin_%@_%d.dat", currentSelectedCityID, [[offsetArray objectAtIndex:i] integerValue]];
    //  NSString *apartFilePath = [[self cacheDir] stringByAppendingString:filename];
    NSData *newNSData = [NSData dataWithBytes:bufferPreDepress length:readLength + 7];
    decompressedData = [DHBSDKYP_ASIDataDecompressor uncompressData:newNSData error:nil];
   // [decompressedData writeToFile:apartFilePath atomically:YES];
    
    
    pinyinIndexArray = [self indexRecordArray:decompressedData keyWords:keyWords];
    free(buffer);
    free(bufferPreDepress);
    
    ///开始检索
    //apartResults = [self filterContentForSearchText:keyWords recordArray:pinyinIndexArray];
    
    results = [results arrayByAddingObjectsFromArray:pinyinIndexArray];
    
    if ([results count] > 50) {
      break;
    }
  }
  fclose(fp);
  
  return results;
}

+ (BOOL)canOfflineSearch {
  
  BOOL can = NO;
  NSString *path = [self dataFilePath:DHBSDKDataCategoryDat];
  if ([path rangeOfString:@"d0_ic.json"].location != NSNotFound) {
    // return NO;
  }
  if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
    // DLog(@"文件已经存在了");
    can = YES;
  }
  return can;
}




@end
