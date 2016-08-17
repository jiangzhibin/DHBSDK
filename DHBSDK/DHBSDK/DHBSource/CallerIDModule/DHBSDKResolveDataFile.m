//
//  ResolveDataFile.m
//  OfflineResolveDemo
//
//  Created by Zhang Heyin on 15/7/8.
//  Copyright (c) 2015年 Yulore. All rights reserved.
//

#import "DHBSDKResolveDataFile.h"
#import "DHBSDKYP_ASIDataDecompressor.h"
#import "DHBSDKFilePaths.h"
//#include <string>
//#define PATH "/Users/zhangheyin/Desktop/OfflineResolveDemo/CPF"
#define HEADER_LENGTH 12


@interface DHBSDKResolveDataFile() {
  //  NSString *filePath;
  FILE *fp;
  //  int lengthKeysArray[20];
}


@property (nonatomic) char* headerBuffer;
@property (nonatomic) NSInteger skipBytesLength;


@property (nonatomic, strong) NSArray * dataParts;
@property (nonatomic) NSInteger dataFileLength;

@property (nonatomic, assign) NSInteger indexContentLength;
@property (nonatomic, assign) NSRange dataContent;

@property (nonatomic, strong) NSMutableArray *indexContentHeaderArray;

@end


@implementation DHBSDKResolveDataFile


- (void)dealloc {
  
  fclose(fp);
}

- (char *)headerBuffer {
  
  if (_headerBuffer == NULL) {
    
    fseek(fp, 0, SEEK_SET);
    char headerBuffer[HEADER_LENGTH] = {0};
    
    
    fread(headerBuffer, 1, HEADER_LENGTH, fp);
    
    _headerBuffer = headerBuffer;
  }
  return _headerBuffer;
}

/**
 *  计算压缩文件的长度
 *
 *  @return 计算压缩文件的长度
 */
- (NSInteger)dataFileLength {
  if (_dataFileLength == 0) {
    fseek(fp, 0,  SEEK_SET);
    //    printf("%ld\n", ftell(fp));
    _dataFileLength = ftell(fp);
    fseek(fp, 0,  SEEK_SET);
  }
  return _dataFileLength;
}

/**
 *  计算跳过部分的自己长度
 *  Random skip bytes is calculated by (5593FF30 % 4 + 1) x 4 = 4 bytes.
 *  @return 字节长度
 */
- (NSInteger)skipBytesLength {
  
  if (_skipBytesLength == 0) {
    _skipBytesLength = (self.timeStamp % 4 + 1) * 4;
  }
  return _skipBytesLength;
}

/**
 *  获取压缩文件的时间戳
 *
 *  @return 时间戳的long型
 */
- (NSInteger)timeStamp {
  //  double time = 1435762480;
  if (_timeStamp == 0) {
      
    long a0 = self.headerBuffer[4] & 0x00ff;
    long a1 = self.headerBuffer[5] & 0x00ff;
    long a2 = self.headerBuffer[6] & 0x00ff;
    long a3 = self.headerBuffer[7] & 0x00ff;
    
    //1435771234
    //1435762480
    long lTimeStamp = (a3 << 6*4) + (a2 << 4*4) + (a1 << 2*4) + a0;
    
    _timeStamp = lTimeStamp;
     
    long a6 = _headerBuffer[2] & 0xff;
    _currentVersion = a6;
  }
  return _timeStamp;
  
  //  return 0;
}
/**
 *  获取压缩文件的Version
 *
 *  @return 时间戳的long型
 */
- (NSInteger)currentVersion {
    [self timeStamp];
    return _currentVersion;
}


/**
 *  计算索引部分的长度
 *
 *  @return 索引部分去除gzipheader10字节的长度
 */
- (long)indexContentLength {
  if (_indexContentLength == 0) {
    //The index content length = 00002d6e (little endian) is the size after compressing by gzip tool and removing the first 10 bytes header.
    fseek(fp, HEADER_LENGTH + self.skipBytesLength - 4, SEEK_SET);
      NSLog(@"SEEK %ld",HEADER_LENGTH + self.skipBytesLength - 4);
    char lengthBuffer[4] = {0};
    size_t numRead = fread(lengthBuffer, 1, 4, fp);
    long contentLength = 0;
    if (numRead == 4) {
      long a0 = lengthBuffer[0] & 0x00ff;
      long a1 = lengthBuffer[1] & 0x00ff;
      long a2 = lengthBuffer[2] & 0x00ff;
      long a3 = lengthBuffer[3] & 0x00ff;
      //1435771234
      //1435762480
      contentLength = (a3 << 6*4) + (a2 << 4*4) + (a1 << 2*4) + a0;
      _indexContentLength = contentLength;
    }
    
  }
  
  return _indexContentLength;
}

- (NSRange)dataContent{
    if (_dataContent.length == 0) {
        
        long contentLocation = HEADER_LENGTH + self.skipBytesLength + self.indexContentLength;
        
        fseek(fp, contentLocation, SEEK_SET);
        NSLog(@"SEEK 2 %ld",contentLocation);

        char lengthBuffer[4] = {0};
        size_t numRead = fread(lengthBuffer, 1, 4, fp);
        
        long contentLength = 0;
        if (numRead == 4) {
            long a0 = lengthBuffer[0] & 0x00ff;
            long a1 = lengthBuffer[1] & 0x00ff;
            long a2 = lengthBuffer[2] & 0x00ff;
            long a3 = lengthBuffer[3] & 0x00ff;
            //1435771234
            //1435762480
            contentLength = (a3 << 6*4) + (a2 << 4*4) + (a1 << 2*4) + a0;
        }
        contentLocation = contentLocation + contentLength + 4;
        fseek(fp,contentLocation , SEEK_SET);
        NSLog(@"SEEK 3 %ld",contentLocation);
        numRead = fread(lengthBuffer, 1, 4, fp);
        contentLength = 0;
        if (numRead == 4) {
            long a0 = lengthBuffer[0] & 0x00ff;
            long a1 = lengthBuffer[1] & 0x00ff;
            long a2 = lengthBuffer[2] & 0x00ff;
            long a3 = lengthBuffer[3] & 0x00ff;
            //1435771234
            //1435762480
            contentLength = (a3 << 6*4) + (a2 << 4*4) + (a1 << 2*4) + a0;
            _dataContent = NSMakeRange(contentLocation+4, contentLength);
        }
        
    }
    return _dataContent;
}
/**
 *  构建索引部分，解压缩为JSON数组
 *  The index content
 *  The index content is compressed by gzip tool
 *  @return
 */
- (NSMutableArray *)indexContentHeaderArray {
  if (_indexContentHeaderArray == nil) {
    
    //构建gzip头部
    char gzipHeaderBytes[10] = {0};
    gzipHeaderBytes[0] = 0x1f;
    gzipHeaderBytes[1] = 0x8b;
    gzipHeaderBytes[2] = 0x08;
    gzipHeaderBytes[3] = 0x00;
    gzipHeaderBytes[4] = 0x55;
    gzipHeaderBytes[5] = 0x00;
    gzipHeaderBytes[6] = 0x00;
    gzipHeaderBytes[7] = 0x00;
    gzipHeaderBytes[8] = 0x00;
    gzipHeaderBytes[9] = 0x03;
    
    
    NSMutableData *gzipHeaderData = [NSMutableData dataWithBytes:gzipHeaderBytes length:10];
    
    //取得当前压缩文件的index content的长度
    NSUInteger indexContentLength = self.indexContentLength;
    
    //定位读取index content位置
    NSUInteger indexContentStartPostion = HEADER_LENGTH + self.skipBytesLength;
    
    //gzip头与index content部分连接，形成一个争取的gzip压缩文件以便解压
    [gzipHeaderData appendData:[_mappedData subdataWithRange:NSMakeRange(indexContentStartPostion, indexContentLength)]];
      
    /**
     *  解压部分
     */
    NSError *error = nil;
    NSData *decompressedData = [DHBSDKYP_ASIDataDecompressor uncompressData:gzipHeaderData error:&error];
      //NSLog(@"JSON = %@",[[NSString alloc] initWithData:decompressedData encoding:NSUTF8StringEncoding]);
    ///解压的二进制数据，JSON解码为数组
    NSMutableArray *results = decompressedData ? [NSJSONSerialization JSONObjectWithData:decompressedData
                                                                                 options:NSJSONReadingMutableLeaves|NSJSONReadingMutableContainers error:&error] : nil;
    if (error) NSLog(@"[%@ %@] JSON error: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), error.localizedDescription);
    
    _indexContentHeaderArray = results;
    NSLog(@"JSON LEN = %ld (%ld)",[decompressedData length],[results count]);
    NSLog(@"JSON = S %ld L %ld",indexContentStartPostion,indexContentLength);

  }
  
  return _indexContentHeaderArray;
}


- (instancetype)init {
  self = [super init];
  if (self) {
    NSString *filePath = [DHBSDKFilePaths pathForFullOfflineFilePath];
      NSLog(@"init resolve: %@",filePath);
    fp = fopen(filePath.UTF8String,"r");
    
    _resolveOffsetDictionary = [[NSMutableDictionary alloc] init];
    
    if (fp == nil) {
        return nil;
    }
    
    _mappedData = [NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedIfSafe error:nil];
      [self indexContentHeaderArray];
      [self dataContent];
      //NSLog(@"DATA LEN = %ld %ld",dataSegment.location,dataSegment.length);
      //NSLog(@"DATA PARTS = %ld",[self.dataParts count]);
    

      //NSLog(@"FINAL");
      //NSLog(@"FINAL DATA: %@",[self.resolveOffsetDictionary objectForKey:@"10"]);
  }
  
  return self;
}

- (void)readDataFromFile:(void (^)(float progress))progressBlock {
    for (int i = 0; i < [_indexContentHeaderArray count]; i++) {
        NSLog(@"READ 0-%d",i);
        [self offsetArrayWithIndex:i]; // read each data part index
        progressBlock((float)i/(float)[_indexContentHeaderArray count]/2.0f);
    }//read JSON
    
    for (int i = 0; i < [_indexContentHeaderArray count]; i++) {
        NSLog(@"READ 1-%d",i);
        [self teleListWithHeaderIndex:i];
        progressBlock(0.5f+(float)i/(float)[_indexContentHeaderArray count]/2.0f);
    }
}

/**
 *  指定index区块中所有的key列表
 *
 *  @param index 不同的区块
 *
 *  @return 000, 001, 003, 005, 007, 008, 010, 019, 020, 021,
 */
- (NSMutableArray *)buildKeysArrayIndex:(NSUInteger)index {
    NSLog(@"buildKeysArrayIndex");
    NSMutableArray *keysArray = [[NSMutableArray alloc] init];
    @autoreleasepool {
        NSArray *offsetListAtCurrentIndex=nil;
        for (NSString * key in [self.indexContentHeaderArray[index] allKeys]){
            if ([key isEqualToString:@"index_table"]) {
                offsetListAtCurrentIndex = [self.indexContentHeaderArray[index] valueForKey:key];
                //NSLog(@"Index 2 %@ = %@",key,offsetListAtCurrentIndex);
            }
        }
        
        for (id aItem in offsetListAtCurrentIndex) {
            NSString * n =  [[aItem allKeys] firstObject];
            //    NSNumber *offset = [NSNumber numberWithInteger:n];
            [keysArray addObject:n];
        }
        NSLog(@"buildKeysArrayIndex return");
    }
    return keysArray;
}


/**
 *  偏移量集合构建
 *
 *  @param index 不同的区块
 *
 *  @return 偏移量集合
 */
- (NSMutableSet *)buildOffsetCountsSetWithIndex:(NSUInteger)index {
    NSMutableSet *sets = [[NSMutableSet alloc] init];
    
    @autoreleasepool {
        NSArray *offsetListAtCurrentIndex=nil;
        
        for (NSString * key in [self.indexContentHeaderArray[index] allKeys]){
            if ([key isEqualToString:@"index_table"]) {
                offsetListAtCurrentIndex = [self.indexContentHeaderArray[index] valueForKey:key];
                //NSLog(@"Index 3 %@ = %@",key,offsetListAtCurrentIndex);
            }
        }
        
        for (id aItem in offsetListAtCurrentIndex) {
            NSInteger n =  [[[aItem allValues] firstObject] integerValue];
            NSNumber *offset = [NSNumber numberWithInteger:n];
            [sets addObject:offset];
        }
        
    }
    
    return sets;
}

- (void)teleListWithHeaderIndex:(NSUInteger)index {

    long phoneLength=0;
    for (NSString * key in [self.indexContentHeaderArray[index] allKeys]) {
        if ([key isEqualToString:@"phone_len"]) {
            phoneLength=[[self.indexContentHeaderArray[index] valueForKey:key] integerValue];
        }
    }
    
  NSMutableDictionary *massPartDictionary = [[NSMutableDictionary alloc] init];
  //获取当前区块的位置 location， length
  NSRange range = [((NSValue *)self.dataParts[index]) rangeValue];

  NSLog(@"teleList: %ld %ld",range.location,range.length);

  NSArray *keyArrays = [self buildKeysArrayIndex:index];
  NSMutableSet *sets  = [self buildOffsetCountsSetWithIndex:index];

  NSData *data = [_mappedData subdataWithRange:range];
  const void *pData = data.bytes;
  
  char *p = pData;
  
  int i = 0;
  Byte bytes[8] = {0};
  memset(bytes, 0, 8);
  void *pTemp = bytes;
  int byteLength = 0;
  //  long lastNumber = 0;
  int teleCounter = 0;
  
  
  int partByteLen = 0;
  int partIndex = 0; //000 010 010 这种的 782的
  
  long partPostionStart = 0;
  long long tempPhoneNumber=0;
  while (i  <= range.length  ) {
    i++;
    partByteLen++;
    char  pChar = p[0];
    
    
    // 0xA[0, 1, 2, 3, 4, 5, 6, 7, 8]
    // 例如0xA2  10100010 右移4位 00001010
    // 与0x0f与运算 取得1010部分 也就是 0x0a
    if (0x0a == (pChar >> 4 & 0x0f) ) {
      if (teleCounter == 0) {
        partPostionStart = range.location + i - partByteLen;
        NSLog(@"TEL-COUNTER RESET %ld",partPostionStart);
      }
        //NSLog(@"P %@");
        NSString *key = keyArrays[partIndex];
        long a0= pChar & 0xf;
      if ([sets containsObject:[NSNumber numberWithInt:teleCounter+1]]) {
          tempPhoneNumber=0;
          //NSLog(@"%@ = %d %ld %d",key,partIndex,partPostionStart,byteLength);
          //NSLog(@"%02x %02x %02x %02x %02x %02x %02x %02x",bytes[0],bytes[1],bytes[2],bytes[3],bytes[4],bytes[5],bytes[6],bytes[7]);
          if (byteLength<=8) {
              for (int i = 0;i<byteLength;i++){
                  int hhalf=bytes[i] >> 4;
                  int lhalf=bytes[i] & 0x0f;
                  tempPhoneNumber+=pow(10,byteLength*2-i*2-1)*hhalf;
                  tempPhoneNumber+=pow(10,byteLength*2-i*2-2)*lhalf;
              }
              //NSLog(@"TEL-C = %ld %@ %ld",tempPhoneNumber,key,phoneLength);
              [massPartDictionary setObject:[[NSString alloc] initWithFormat:@"%ld",a0] forKey:[self buildPhoneNumberWithKey:key numberOffset:tempPhoneNumber phoneNumberLength:phoneLength]];
          }
          partByteLen = 0;
          //lastNumber = 0;
          partIndex++;
          partPostionStart = range.location + i - partByteLen;
          tempPhoneNumber=0;
      } else {
          //NSLog(@"%@ = %d %ld %d",key,partIndex,partPostionStart,byteLength);
          //NSLog(@"HALF %02x %02x %02x %02x %02x %02x %02x %02x",bytes[0],bytes[1],bytes[2],bytes[3],bytes[4],bytes[5],bytes[6],bytes[7]);
          long phoneNumberOffset=0;
          if (byteLength<=8) {
              for (int i = 0;i<byteLength;i++){
                  int hhalf=bytes[i] >> 4;
                  int lhalf=bytes[i] & 0x0f;
                  phoneNumberOffset+=pow(10,byteLength*2-i*2-1)*hhalf;
                  phoneNumberOffset+=pow(10,byteLength*2-i*2-2)*lhalf;
              }
//              NSLog(@"TEL-P = %ld %ld %@ %ld",tempPhoneNumber,phoneNumberOffset,key,phoneLength);
              tempPhoneNumber+=phoneNumberOffset;
              [massPartDictionary setObject:[[NSString alloc] initWithFormat:@"%ld",a0] forKey:[self buildPhoneNumberWithKey:key numberOffset:tempPhoneNumber phoneNumberLength:phoneLength]];
          }
          
      }
      teleCounter++;
      memset(bytes, 0, 8);
      pTemp = bytes;
      byteLength = 0;
    }
    else {
      byteLength++;
      memset(pTemp++, pChar, 1);
    }
    
    p++;
    
  }

  //final part
  //NSRange rangeLast = NSMakeRange(partPostionStart, partByteLen);
  //NSValue *rangeValueLast = [NSValue valueWithRange:rangeLast];
  
  //[massPartDictionary setObject:rangeValueLast forKey:[keyArrays lastObject]];
    NSLog(@"TELCOUNTER %ld = %ld phoneLEN = %ld",index,[[massPartDictionary allKeys] count],phoneLength);
    for (NSString * key in [massPartDictionary allKeys])
    {
        [self.resolveOffsetDictionary setObject:[massPartDictionary objectForKey:key] forKey:key];
    }
}

-(NSString *) buildPhoneNumberWithKey:(NSString*)key numberOffset:(long long)offset phoneNumberLength:(long)length {
    @autoreleasepool {
        NSString * phoneNumberOffset=[[NSString alloc] initWithFormat:@"%ld",offset];
        //        NSLog(@"PAD: %ld %@ %@ %ld",length-[phoneNumberOffset length]-[key length],key,phoneNumberOffset,length);
        NSString * leadingZero = @"";
        if (length>[phoneNumberOffset length]+[key length]){
            leadingZero = [@"" stringByPaddingToLength:length-[phoneNumberOffset length]-[key length] withString: @"0" startingAtIndex:0];
        }
        if ([[key substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"0"])
        {
            return [[NSString alloc] initWithFormat:@"+86%@%@%@",[key substringFromIndex:1],leadingZero,phoneNumberOffset];
        } else {
            return [[NSString alloc] initWithFormat:@"+86%@%@%@",key,leadingZero,phoneNumberOffset];
        }
    }
}


- (NSArray *)dataParts {
  
  if (_dataParts == nil) {
    
    NSMutableArray *rangeArray = [[NSMutableArray alloc] init];
    
    ///数据区的位置
    ///get the length of compress phone number data append after the whole index content by calculating the compress phone number data offset by 16 bytes (the size of file header) plus with index content with 00002d6e bytes
    NSInteger phoneNumberDataOffset = [self dataContent].location;
    
    const void *data = [self.mappedData bytes];
    
    char *p = data + (phoneNumberDataOffset);
    NSInteger i = 0,k = phoneNumberDataOffset;
    NSUInteger location = k;

      long dataFileEndLocation = [self dataContent].location+[self dataContent].length;
      
    while ( k <= dataFileEndLocation  ) {
        k++;
      //    ushort  pChar = p[0];
      if ((0x00ff & p[0]) == 0x00ff) {
        i++;
        //      printf("ok %ld\n",  k-1 );
        NSRange range = NSMakeRange(location, k - location);
        location = k;
        NSLog(@"Data Parts %lu  %lu", range.location, range.length);
        [rangeArray addObject:[NSValue valueWithRange:range]];
      }
      p++;
    }
    
    NSLog(@"dataParts read OK: from %ld",phoneNumberDataOffset);
    _dataParts = rangeArray;
  }
  return _dataParts;
}


- (NSArray *)offsetArrayWithIndex:(NSUInteger)index {
    @autoreleasepool {
        NSMutableDictionary *aHeader = self.indexContentHeaderArray[index];
        NSMutableString *keyString = nil;
        long phoneLength = 0;
        
        id offsetDictionary = nil;
        
        for (NSString * key in [aHeader allKeys]) {
            if ([key isEqualToString:@"index_table"]) {
                keyString = [[NSMutableString alloc] initWithString:key];
                offsetDictionary = [aHeader valueForKey:key];
                //NSLog(@"Index 1 %@ = %@",keyString,offsetDictionary);
            } else if ([key isEqualToString:@"phone_len"]) {
                phoneLength=[[aHeader valueForKey:key] integerValue];
                NSLog(@"Index 1 Phone length %ld",phoneLength);
            }
        }
        
        //  NSError *error = nil;
        //  id offsetDictionary = [NSJSONSerialization JSONObjectWithData:[valueString dataUsingEncoding:NSUTF8StringEncoding]
        //                                                        options:NSJSONReadingAllowFragments
        //                                                          error:&error];
        NSMutableArray *indexArray = [[NSMutableArray alloc] init];
        if (offsetDictionary !=nil) {
            [offsetDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                //NSLog(@"key %@ : value %@",key , obj);
                [indexArray addObject:[NSDictionary dictionaryWithObject:obj forKey:key]];
            }];
        }
        [indexArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            long obj1Key = [[[obj1 allKeys] firstObject] integerValue];
            long obj2Key = [[[obj2 allKeys] firstObject] integerValue];
            
            if (obj1Key > obj2Key) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            
            if (obj1Key < obj2Key) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            
            return (NSComparisonResult)NSOrderedSame;
        }];
        
        [aHeader setValue:indexArray forKey:keyString];
        //  lengthKeysArray[index] = [keyString intValue];
        //NSLog(@"Index 1 %@ = %@",keyString,aHeader);
        
        self.indexContentHeaderArray[index] = aHeader;
        
        return indexArray;
    }
}


@end
