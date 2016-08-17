//
//  NSDictionary+Offset.m
//  DianHuaBang
//
//  Created by Zhang Heyin on 13-8-1.
//  Copyright (c) 2013年 Yulore. All rights reserved.
//  last 2014.4.19

#import "NSDictionary+DHBSDKOffset.h"
#import "DHBSDKYP_ASIDataDecompressor.h"
#import "Commondef.h"
@implementation NSDictionary (DHBSDKOffset)


+ (NSDictionary *)categorysWithOffset:(NSUInteger) offset
                              filePath:(NSString *)filePath {
  FILE *fp = fopen([filePath UTF8String],"r");
  NSMutableData *compreseData = [[NSMutableData alloc] init];
  int c = 0xff;
  int pre = 0xff;
  long offsete = 0;
  
  
  BOOL getDouble0x00 = NO;
  if (fp == nil) {
    return nil;
  }
  fseek(fp, 0, SEEK_SET);
  
  while((c=fgetc(fp))!=EOF) {
    //printf("%.2x ",c);

    if (getDouble0x00) {
      if (c == 0x00) {
        [compreseData appendBytes:&c  length:1];
      }
      break;
    }
    
    [compreseData appendBytes:&c  length:1];


    if ((c || pre) == 0x00) {
      //这里是是位置
      // DHBSDKDLog(@"");
      offsete = ftell(fp);
      getDouble0x00 = YES;
    }
  

    
    pre = c;
  }

  //fclose(fp);
  NSMutableData *compreseData2 = [[NSMutableData alloc] init];

  NSInteger appartOffset = [compreseData length];
  if(fseek(fp, offset + appartOffset, SEEK_SET) == -1) {
    return nil;
  }
  
  getDouble0x00 = NO;
  
  
  while((c=fgetc(fp))!=EOF) {
    if (getDouble0x00) {
      if (c == 0x00) {
        [compreseData2 appendBytes:&c  length:1];
      }
      break;
    }
    
    [compreseData2 appendBytes:&c  length:1];

    if ((c || pre) == 0x00) {
      //这里是是位置
      // DHBSDKDLog(@"");
      offsete = ftell(fp);
     getDouble0x00 = YES;
    }
    pre = c;
  }
  
  fclose(fp);
  
  
  
  
  
  
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
  
  
  NSData *subIC = [compreseData2 subdataWithRange:NSMakeRange(6, [compreseData2 length] - 6 -2)];
  NSData *appendData = [NSData dataWithBytes:append length:10];
  NSMutableData *newData = [NSMutableData dataWithData:appendData];
  [newData appendData:subIC];
  NSData *newNSData = [NSData dataWithData:newData];
  
 // [newNSData writeToFile:[NSString stringWithFormat:@"%@.gz",filePath] atomically:YES];
  NSData *decompressedData = [DHBSDKYP_ASIDataDecompressor uncompressData:newNSData error:nil];
  //[decompressedData writeToFile:dbPath atomically:YES];
  NSError *error = nil;
  NSDictionary *results = decompressedData ? [NSJSONSerialization JSONObjectWithData:decompressedData
                                                                             options:NSJSONReadingMutableLeaves error:&error] : nil;
  if (error) DHBSDKDLog(@"[%@ %@] JSON error: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), error.localizedDescription);
  
  
  return results;
}


+ (NSDictionary *)dictionaryWithOffset:(NSUInteger) offset
                              filePath:(NSString *)filePath {
  FILE *fp = fopen([filePath UTF8String],"r");
  
  NSMutableData *compreseData = [[NSMutableData alloc] init];
  int c = 0xff;
  int pre = 0xff;
  long offsete = 0;
  if (fp == nil) {
    return nil;
  }
  if( fseek(fp, offset, SEEK_SET) == -1   ) {
    return nil;
  }
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
  if ([compreseData length] > 1024 * 2 || [compreseData length] < 4) {
    return nil;
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
  
  
  NSData *subIC = [compreseData subdataWithRange:NSMakeRange(2, [compreseData length] - 4)];
  NSData *appendData = [NSData dataWithBytes:append length:10];
  free(append);
  NSMutableData *newData = [NSMutableData dataWithData:appendData];
  [newData appendData:subIC];
  NSData *newNSData = [NSData dataWithData:newData];
  
  //DHBSDKDLog(@"a");
  NSData *decompressedData =/*[self  uncompressBytes:(Bytef *)[newNSData bytes] len:[newNSData length]];*/
   [DHBSDKYP_ASIDataDecompressor uncompressData:newNSData error:nil];
//  DHBSDKDLog(@"b");
  NSError *error = nil;
  NSDictionary *results = decompressedData ? [NSJSONSerialization JSONObjectWithData:decompressedData
                                                                             options:NSJSONReadingMutableLeaves error:&error] : nil;
  if (error) DHBSDKDLog(@"[%@ %@] JSON error: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), error.localizedDescription);
  //DHBSDKDLog(@"c");
  
  return results;
}




+ (NSData *) uncompressBytes:(Bytef *)bytes len:(int )length {
  z_stream zStream;
  //- (NSData *)uncompressBytes:(Bytef *)bytes length:(NSUInteger)length error:(NSError **)err
  //{
	// Setup the inflate stream
	zStream.zalloc = Z_NULL;
	zStream.zfree = Z_NULL;
	zStream.opaque = Z_NULL;
	zStream.avail_in = 0;
	zStream.next_in = 0;
	//int status2 = inflateInit2(&zStream, (15+32));
  //zStream.total_out = 0;
  //zStream.total_in = 0;
	if (length == 0) return NULL;
	
	int  halfLength = length/2;
	//NSMutableData *outputData = [NSMutableData dataWithLength:length+halfLength];
	Byte *outputData = (Byte *)malloc(halfLength + length);
  memset(outputData, 0, halfLength + length);
	int status;
	
	zStream.next_in = bytes;
	zStream.avail_in = (unsigned int)length;
	zStream.avail_out = 0;
	
	uLong bytesProcessedAlready = zStream.total_out;
  
  int times = 1;
	while (zStream.avail_in != 0) {
		
		if (zStream.total_out-bytesProcessedAlready >= halfLength + length) {
			//[outputData increaseLengthBy:halfLength];
      outputData = (Byte *)realloc(outputData, halfLength * times + length);
      times ++;
		}
		
		zStream.next_out = (Bytef*)outputData + zStream.total_out-bytesProcessedAlready;
		zStream.avail_out = (unsigned int)((halfLength * times + length) - (zStream.total_out-bytesProcessedAlready));
		
		status = inflate(&zStream, Z_NO_FLUSH);
		
		if (status == Z_STREAM_END) {
			break;
		} else if (status != Z_OK) {
      //	if (err) {
			//	*err = [[self class] inflateErrorWithCode:status];
			//}
			//return nil;
		}
    //  times++;
	}
	
	// Set real length

	//[outputData setLength: zStream.total_out-bytesProcessedAlready];
  unsigned long  oout = (zStream.total_out - bytesProcessedAlready);
  //  &outLength = *len;
  NSData *outData = [NSData dataWithBytes:outputData  length:oout];
    free(outputData);
	return outData;
}

@end
