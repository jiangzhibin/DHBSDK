//
//  NSDictionary+DHBSignature.m
//  CallerID
//
//  Created by Zhang Heyin on 15/8/18.
//  Copyright (c) 2015年 Yulore Inc. All rights reserved.
//

#import "NSDictionary+DHBSDKSignature.h"
#import "DHBSDKApiManager.h"

#import <CommonCrypto/CommonCrypto.h>
@implementation NSDictionary (DHBSDKSignature)
- (NSString *)signature {
    
    NSString *uid = [self objectForKey:@"uid"];
    NSString *appName = [self objectForKey:@"app"];
    NSString *version = [self objectForKey:@"ver"];
    NSString *inithot_ver = [self objectForKey:@"inithot_ver"];
    if (inithot_ver==nil)
        inithot_ver=@"";
    NSString *mobileloc_ver = [self objectForKey:@"mobileloc_ver"];
    if (mobileloc_ver==nil)
        mobileloc_ver=@"";
    NSString *bkwd_ver = [self objectForKey:@"bkwd_ver"];
    if (bkwd_ver==nil)
        bkwd_ver=@"";
    NSString *hot_ver = [self objectForKey:@"hot_ver"];
    if (hot_ver==nil)
        hot_ver=@"";
    NSString *flag_ver = [self objectForKey:@"flag_ver"];
    if (flag_ver==nil)
        flag_ver=@"";
    NSString *mcc_ver = [self objectForKey:@"mcc_ver"];
    if (mcc_ver==nil)
        mcc_ver=@"";
    NSString *apikey = [self objectForKey:@"apikey"];
    
    NSMutableArray *subArray = [self arrayWithSubPassword];
    
    NSString *sig = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@", subArray[0], uid, subArray[1], appName, subArray[2], version, subArray[3], inithot_ver, subArray[4], hot_ver, subArray[5], mobileloc_ver, subArray[6], bkwd_ver,subArray[7], flag_ver, subArray[8], mcc_ver, subArray[9], apikey, subArray[10]];
    NSLog(@"SIG: %@",sig);
    NSString *sha1String = sha1(sig.UTF8String); //
    
    return [sha1String substringWithRange:NSMakeRange(4, 32)];
}
- (NSMutableArray *)arrayWithSubPassword {
    NSRange range[11];
    range[0] = NSMakeRange(18, 2);
    range[1] = NSMakeRange(21, 4);
    range[2] = NSMakeRange(28, 3);
    range[3] = NSMakeRange(32, 3);
    range[4] = NSMakeRange(35, 3);
    range[5] = NSMakeRange(37, 1);
    range[6] = NSMakeRange(41, 3);
    range[7] = NSMakeRange(47, 3);
    range[8] = NSMakeRange(51, 2);
    range[9] = NSMakeRange(53, 5);
    range[10] = NSMakeRange(60, 3);
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 0; i < 11; i++) {
        NSString *sub = [[DHBSDKApiManager shareManager].signature substringWithRange:range[i]];
        [array addObject:sub];
    }
    return array;
}


NSString * sha1(const char *string) {
    static const NSUInteger LENGTH = 20;
    unsigned char result[LENGTH];
    CC_SHA1(string, (CC_LONG)strlen(string), result);
    
    char hexResult[2 * LENGTH + 1];
    hexString(result, hexResult, LENGTH);
    
    return [NSString stringWithUTF8String:hexResult];
}

static inline char hexChar(unsigned char c) {
    return c < 10 ? '0' + c : 'a' + c - 10;
}

static inline void hexString(unsigned char *from, char *to, NSUInteger length) {
    for (NSUInteger i = 0; i < length; ++i) {
        unsigned char c = from[i];
        unsigned char cHigh = c >> 4;
        unsigned char cLow = c & 0xf;
        to[2 * i] = hexChar(cHigh);
        to[2 * i + 1] = hexChar(cLow);
    }
    to[2 * length] = '\0';
}

@end
