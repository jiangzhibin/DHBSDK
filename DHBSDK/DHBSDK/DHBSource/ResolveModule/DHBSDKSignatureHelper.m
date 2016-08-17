//
//  SignatureHelper.m
//  DianHuaBang
//
//  Created by Zhang Heyin on 13-7-17.
//  Copyright (c) 2013年 Yulore. All rights reserved.
//

#import "DHBSDKSignatureHelper.h"
#import "NSString+DHBSDKCrypto.h"
#import "CommonTmp.h"
#import "Commondef.h"

static NSString * const kCITY_ID            =   @"city_id";
static NSString * const kCAT_ID             =   @"cat_id";
static NSString * const kSTART              =   @"s";
static NSString * const kNUMBER             =   @"n";
static NSString * const kQUERY              =   @"q";
static NSString * const kUID                =   @"uid";
static NSString * const kMN                 =   @"mn";
static NSString * const kSEARCHCATEGORY     =   @"t";
static NSString * const kLAT                =   @"lat";
static NSString * const kLNG                =   @"lng";
static NSString * const kOLDER              =   @"o";
static NSString * const kSID                =   @"sid";
static NSString * const kDIS_ID             =   @"dis_id";
static NSString * const kSIGNATURE          =   @"sig";

@implementation DHBSDKSignatureHelper


+ (NSString *) listPassword {
  NSString *sdkKey = [DHBSDKApiManager shareManager].signature;
  if ([sdkKey length] < 150) {
    return nil;
  }
  return [sdkKey substringWithRange:NSMakeRange(53, 36)];
}



+ (NSString *) listSignature:(NSMutableDictionary *)info {
  NSString *city_id =[info valueForKey:kCITY_ID] ? [info valueForKey:kCITY_ID] : @"";
  NSString *cat_id = [info valueForKey:kCAT_ID] ? [info valueForKey:kCAT_ID] : @"";
  NSString *s = [info valueForKey:kSTART] ? [info valueForKey:kSTART] : @"";
  NSString *n = [info valueForKey:kNUMBER] ? [info valueForKey:kNUMBER] : @"";
  NSString *q = [info valueForKey:kQUERY] ? [info valueForKey:kQUERY] : @"";
  
//  q = [q stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  
  NSString *uid = [info valueForKey:kUID] ? [info valueForKey:kUID] : @"";
  NSString *mn = [info valueForKey:kMN] ? [info valueForKey:kMN] : @"";
  NSString *lat = [info valueForKey:kLAT] ? [info valueForKey:kLAT] : @"";
  NSString *lng = [info valueForKey:kLNG] ? [info valueForKey:kLNG] : @"";
  NSString *older = [info valueForKey:kOLDER] ? [info valueForKey:kOLDER] : @"";
 // NSString *sid = [info valueForKey:kSID] ?  [info valueForKey:kSID] : @"";
  NSString *t = [info valueForKey:kSEARCHCATEGORY] ? [info valueForKey:kSEARCHCATEGORY] : @"";
 // NSString *dis_id =[info valueForKey:kDIS_ID] ? [info valueForKey:kDIS_ID] : @"";
  
  NSArray *locations =  @[@0,  @6,   @9,   @10,  @13,  @16,  @18,  @21,  @24,  @30, @33];
  NSArray *lengths =    @[@6,  @3,   @1,    @3,  @3,   @2,   @3,   @3,   @6,   @3, @3];

  NSString *secretKEY = [self listPassword];
  NSString *formatSecrtKey = [[NSString alloc] init];
  for (int i = 0; i < [locations count]; i++) {
    NSUInteger loc = [locations[i] integerValue];
    NSUInteger len = [lengths[i] integerValue];
    //  DHBSDKDLog(@"%@", [secretKEY substringWithRange:NSMakeRange(loc , len)]);
    if (i == ([locations count] - 3)) {
      formatSecrtKey = [formatSecrtKey stringByAppendingFormat:@"%@%@",[secretKEY substringWithRange:NSMakeRange(loc , len)], @"%@%@" ];
    } else {
      formatSecrtKey = [formatSecrtKey stringByAppendingFormat:@"%@%@",[secretKEY substringWithRange:NSMakeRange(loc , len)], @"%@" ];
    }
  }

  formatSecrtKey = [formatSecrtKey substringToIndex:([formatSecrtKey length] - 2)];

  NSString *string =[NSString stringWithFormat:formatSecrtKey, city_id, older,lng,  s, cat_id, q, lat, n ,uid, t, mn];

  NSString *sha1String = [string sha1String];//sha1(string.UTF8String);
  return  [sha1String substringWithRange:NSMakeRange(1, 32)];
  
}

+ (NSString *)detailKey {
  NSString *sdkKey = [DHBSDKApiManager shareManager].signature;
  return [sdkKey substringWithRange:NSMakeRange(89, 40)];


}



+ (NSString *) detialSignature:(NSDictionary *)info {
  NSString *shop_id = [info valueForKey:@"SHOP_ID"] ? [info valueForKey:@"SHOP_ID"] : nil;
  
  NSString *uid = [info valueForKey:kUID] ? [info valueForKey:kUID] : nil;
  
  NSString *new = [self detailKey];
  NSString *formatSecrtKey = [[NSString alloc] init];
  NSArray *locations =  @[@0, @9,  @24, @31];
  NSArray *lengths =    @[@9, @15,  @7, @9];
  for (int i = 0; i < [locations count]; i++) {
    NSUInteger loc = [locations[i] integerValue];
    NSUInteger len = [lengths[i] integerValue];
    //  DHBSDKDLog(@"%@", [new substringWithRange:NSMakeRange(loc , len)]);
    formatSecrtKey = [formatSecrtKey stringByAppendingFormat:@"%@%@",[new substringWithRange:NSMakeRange(loc , len)], @"%@" ];
  }
  //remove last two byte
  formatSecrtKey = [formatSecrtKey substringToIndex:([formatSecrtKey length] - 2)];
  NSString *string =[NSString stringWithFormat:formatSecrtKey,shop_id, uid, shop_id ];
  //  NSString *string = [NSString stringWithFormat:@"9sk-c$xA_%@_5#jclsOc9^bv2_%@_7cJ&h_%@_ld4=U3Ki", shop_id, uid, shop_id];
  NSString *sha1String = [string sha1String]; // [self sha1String:string];
  
  return  [sha1String substringWithRange:NSMakeRange(4, 32)];
}







+ (NSString *) categorySignature:(NSMutableDictionary *)info {
  NSString *city_id = [info valueForKey:kCITY_ID] ? [info valueForKey:kCITY_ID] : nil;
  NSString *cat_id = [info valueForKey:kCAT_ID] ? [info valueForKey:kCAT_ID] : nil;
  NSString *s = [info valueForKey:kSTART] ? [info valueForKey:kSTART] : nil;
  NSString *n = [info valueForKey:kNUMBER] ? [info valueForKey:kNUMBER] : nil;
  NSString *q = [info valueForKey:kQUERY] ? [info valueForKey:kQUERY] : nil;
  NSString *uid = [info valueForKey:kUID] ? [info valueForKey:kUID] : nil;
  
  
  NSString *string = [NSString stringWithFormat:@"vY2ul_%@_o)3s!_%@_Ns%@$_%@_g4*d_%@_cne@_%@_c#bst", city_id, s, cat_id, q, n, uid];
  
  
  NSString *sha1String = [string sha1String];
  return  [sha1String substringWithRange:NSMakeRange(1, 32)];
}

+ (NSString *) signatureWithDictionary:(NSMutableDictionary *)info {
  NSInteger type = [[info valueForKey:kSIGNATURE] integerValue];
  NSString *SHA1String = [[NSString alloc] init];
  switch (type) {
    case DHBSDKSIGNATURETYPELIST:
      SHA1String = [self listSignature:info];
      break;
    case DHBSDKSIGNATURETYPEDETIAL:
      SHA1String = [self detialSignature:info];
      break;
    case DHBSDKSIGNATURETYPECATEGORY:
      SHA1String = [self categorySignature:info];
      break;
    default:
      break;
  }
  
  return SHA1String;
}

+ (NSString *) batchResolveSignature:(NSString *)telenumberString {
  

  NSString *uid = [DHBSDKOpenUDID value];

  NSString *string = [NSString stringWithFormat:@"vs2#D_%@d&-vaSc%@7szV%@s!jc%@Cs5$N%@", uid,[DHBSDKApiManager shareManager].apiKey, uid,telenumberString, [DHBSDKApiManager shareManager].apiKey];
  
  NSString *sha1String = [string sha1String];
  return  [sha1String substringWithRange:NSMakeRange(7, 32)];
}

+ (NSString *) resolveSignature:(NSString *)telenumber {
  
  NSString *uid = [DHBSDKOpenUDID value];
  NSRange r1 = NSMakeRange(0, 6);
  NSRange r2 = NSMakeRange(6, 7);
  NSRange r3 = NSMakeRange(13, 4);
  NSRange r4 = NSMakeRange(17, 4);
  NSRange r5 = NSMakeRange(21, 6);
  
  NSString *sig = [DHBSDKApiManager shareManager].signature;

  NSString *str1 = [sig substringWithRange:r1];
  NSString *str2 = [sig substringWithRange:r2];
  NSString *str3 = [sig substringWithRange:r3];
  NSString *str4 = [sig substringWithRange:r4];
  NSString *str5 = [sig substringWithRange:r5];
  
  NSString *string = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@",str1,uid,str2,telenumber,str3,uid,str4,[DHBSDKApiManager shareManager].apiKey,str5,telenumber];

  NSString *sha1String = [string sha1String];// [self sha1String:string];
  
  return  [sha1String substringWithRange:NSMakeRange(5, 32)];
}

/*j*sD5&_<tel>ds2{<app>hX13<flag>e2@s<tel>9C#s3#<apikey>zF!v%b<uid>a^2Dc
 
 NSRange r1 = NSMakeRange(0, 7);
 NSRange r2 = NSMakeRange(7, 3);
 NSRange r3 = NSMakeRange(10, 4);
 NSRange r4 = NSMakeRange(14, 4);
 NSRange r5 = NSMakeRange(18, 6);
  NSRange r5 = NSMakeRange(24, 6);
  NSRange r5 = NSMakeRange(30, 5);
 j*sD5&_    7
 ds2{   3
 hX13   4
 e2@s    4
 9C#s3#  6
 zF!v%b   6
 a^2Dc   5
 */
+ (NSString *) flagSignature:(NSString *)telenumber withFlag:(NSString *)flag withAppname:(NSString *)appName{
  int offset = 129;
  NSString *uid = [DHBSDKOpenUDID value];
  NSRange r1 = NSMakeRange(0+offset, 7);
  NSRange r2 = NSMakeRange(7+offset, 4);
  NSRange r3 = NSMakeRange(11+offset, 4);
  NSRange r4 = NSMakeRange(15+offset, 4);
  NSRange r5 = NSMakeRange(19+offset, 6);
  NSRange r6 = NSMakeRange(25+offset, 6);
  NSRange r7 = NSMakeRange(31+offset, 5);
  NSString *sig = [DHBSDKApiManager shareManager].signature;
  
  NSString *str1 = [sig substringWithRange:r1];
  NSString *str2 = [sig substringWithRange:r2];
  NSString *str3 = [sig substringWithRange:r3];
  NSString *str4 = [sig substringWithRange:r4];
  NSString *str5 = [sig substringWithRange:r5];
  NSString *str6 = [sig substringWithRange:r6];
  NSString *str7 = [sig substringWithRange:r7];
  
    NSString *string = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@",str1, telenumber,str2, appName ,str3, flag,str4, telenumber,str5,  [DHBSDKApiManager shareManager].apiKey,str6, uid, str7];
  
  
//  NSString *app = @"com.yulore.yellowpage";
  //NSString *string = [NSString stringWithFormat:@"j*sD5&_%@ds2{%@hX13%@e2@s%@9C#s3#%@zF!v%%b%@a^2Dc", telenumber, app,flag,telenumber, kAPIKEY, uid];
  NSString *sha1String = [string sha1String];
  NSString *fin =  [sha1String substringWithRange:NSMakeRange(8, 32)];
  return fin;
}

+ (NSString *)orderSignature:(NSString *)parametersString {
  NSString *APISECRET = [DHBSDKApiManager shareManager].signature;
  
  NSString *APISECRET1_32 = [APISECRET substringToIndex:32];
  NSString *APISECRET33_128 = [APISECRET substringWithRange:NSMakeRange(32, 96)];
  NSString *unionString = [NSString stringWithFormat:@"%@%@%@", APISECRET1_32 , parametersString, APISECRET33_128];
  

  
  NSString *sha1String = [unionString sha1String];
    NSString *fin =  [sha1String substringWithRange:NSMakeRange(1, 32)];
  return fin;
}


+ (NSString *)returnSignature:(NSString *)parametersString {
  NSString *APISECRET = [DHBSDKApiManager shareManager].signature;
  
  NSString *APISECRET1_96 = [APISECRET substringToIndex:96];
  NSString *APISECRET96_128 = [APISECRET substringWithRange:NSMakeRange(96, 32)];
  NSString *unionString = [NSString stringWithFormat:@"%@%@%@", APISECRET1_96 , parametersString, APISECRET96_128];
  
  
  
  NSString *sha1String = [unionString sha1String];
  NSString *fin =  [sha1String substringWithRange:NSMakeRange(6, 32)];
  return fin;
}

@end
