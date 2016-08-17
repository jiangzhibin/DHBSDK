//
//  ResolveItem.m
//  TestMuti1
//
//  Created by Zhang Heyin on 15/3/10.
//  Copyright (c) 2015年 Yulore. All rights reserved.
//
#import "DHBSDKResolveItemNew.h"
#import "DHBSDKTeleNumber.h"
@implementation DHBSDKResolveItemNew


- (NSString *)flagInfo {
  
  if (self.name) {
    
    
    
    NSString *string = [NSString stringWithFormat:@"%@ %@ %@", self.teleNumber, self.rDescription, self.location ? self.location : @""];
    
    return string;
  }
  NSString *string = nil;
  if (self.rDescription) {
    return self.rDescription;
  }
  else if (self.location) {
    if (self.flagType == nil && self.flagNumber == nil) {
      string = self.location;
    }
    else {
      string = [NSString stringWithFormat:@"已被%@人标记为%@ %@", self.flagNumber, self.flagType, self.location];
    }

  }

  _flagInfo = string;
//  string = [NSString stringWithFormat:@"已被%@人标记为%@ %@", self.flagNumber, self.flagType, self.location];
  
  return string;
}

- (NSString *)displayTitle {
  if (self.name) {
    return self.name;
  }
  
  if (self.teleNumber) {
    return self.teleNumber;
  }
  return @"";
}


- (NSString *)formattedWith055:(NSString *)sourceTelenumber {
  
  return [sourceTelenumber stringByReplacingOccurrencesOfString:@" " withString:@"-"];
  
}

- (NSString *)formatedTele:(NSString *)tel {
//      NBAsYouTypeFormatter *numFormatter = [[NBAsYouTypeFormatter alloc] initWithRegionCode:@"CN"];
//  
//  NSString *formatted = [numFormatter inputString:tel];
//  if (numFormatter.isSuccessfulFormatting) {
//    return [self formattedWith055:formatted];
//  }
//  else {
//    return tel;
//  }
  return tel;
// return [numFormatter description];

}
static  NSString *kTELLOC = @"telloc";
static  NSString *kTELRANK = @"telrank";
static  NSString *kTELDESC = @"teldesc";
static  NSString *kNAME = @"name";
static  NSString *kIMAGE = @"image";
static  NSString *kID = @"id";
static  NSString *kTELTYPE = @"teltype";
static  NSString *kTELNUM = @"telnum";
static  NSString *kLOGO = @"logo";
static  NSString *kHIGHRISK = @"highrisk";
static  NSString *kFLAGNUM = @"flag.num";
static  NSString *kFLAGTYPE = @"flag.type";
static  NSString *kFLAGDATE = @"date";
static  NSString *kUSERTAGGED = @"usertagged";
static  NSString *kRSHOPID = @"act.data";
static  NSString *kTELENUMBERS = @"tels";
static  NSString *kWEBURL = @"web";

static  NSString *kUSERFLAGCONTENT = @"userflagcontent";
static  NSString *kSLOGAN_IMG = @"slogan_img";
static  NSString *kSLOGAN_CONTENT = @"slogan";

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
  self = [super init];
  if (self) {
    _location      = [dictionary valueForKey:kTELLOC];
    _rank          = [dictionary valueForKey:kTELRANK];
    _rDescription  = [dictionary valueForKey:kTELDESC];
    _name          = [dictionary valueForKey:kNAME];
    _imageLink     = [dictionary valueForKey:kIMAGE];
    _rID           = [dictionary valueForKey:kID];
    _rType         = [dictionary valueForKey:kTELTYPE];
    _teleNumber    = [self formatedTele:[dictionary valueForKey:kTELNUM] ];
    _logoImageLink = [dictionary valueForKey:kLOGO];
    _highrisk      = [dictionary valueForKey:kHIGHRISK];
    _flagNumber    = [dictionary valueForKeyPath:kFLAGNUM];
    _flagType      = [dictionary valueForKeyPath:kFLAGTYPE];
    _flagDate      = [dictionary valueForKeyPath:kFLAGDATE];
    _shopID = [dictionary valueForKeyPath:kRSHOPID];
    _sloganImageURL = [dictionary valueForKey:kSLOGAN_IMG];
    _sloganContent = [dictionary valueForKey:kSLOGAN_CONTENT];
    _teleNumbers = [[NSMutableArray alloc] init];
    NSMutableArray *telnumbersArray = [dictionary valueForKey:kTELENUMBERS];

    for (NSDictionary *detailsDictionary in telnumbersArray) {
      DHBSDKTeleNumber *aTelNumber = [[DHBSDKTeleNumber alloc] init];

      if (![[detailsDictionary valueForKey:@"desc"] isKindOfClass:[NSNull class]]) {
        aTelNumber.teleDescription = [detailsDictionary valueForKey:@"desc"];
      } else {
        aTelNumber.teleDescription = @"";
      }
      
      if (![[detailsDictionary valueForKey:@"num"] isKindOfClass:[NSNull class]]) {
        aTelNumber.teleNumber = [detailsDictionary valueForKey:@"num"];
      } else {
        aTelNumber.teleNumber = @"";
      }
      
      
      if (![[detailsDictionary valueForKey:@"type"] isKindOfClass:[NSNull class]]) {
        aTelNumber.teleType = [detailsDictionary valueForKey:@"type"];
      } else {
        aTelNumber.teleType = @"";
      }
      [_teleNumbers addObject:aTelNumber];
    }

    _webURL = [dictionary valueForKey:kWEBURL];
      
      _userTaggedType = DHBSDKMarkNumberTypeUnMark;
    
  }

  return self;
}


- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  
  if (self = [super init]) {
    if ([aDecoder containsValueForKey:kTELLOC]) {
      _location = [aDecoder decodeObjectForKey:kTELLOC];
    }
    if ([aDecoder containsValueForKey:kTELRANK]) {
      _rank = [aDecoder decodeObjectForKey:kTELRANK];
    }
    if ([aDecoder containsValueForKey:kTELDESC]) {
      _rDescription = [aDecoder decodeObjectForKey:kTELDESC];
    }
    if ([aDecoder containsValueForKey:kNAME]) {
      _name = [aDecoder decodeObjectForKey:kNAME];
    }
    if ([aDecoder containsValueForKey:kIMAGE]) {
      _imageLink = [aDecoder decodeObjectForKey:kIMAGE];
    }
    if ([aDecoder containsValueForKey:kID]) {
      _rID = [aDecoder decodeObjectForKey:kID];
    }
    if ([aDecoder containsValueForKey:kTELTYPE]) {
      _rType = [aDecoder decodeObjectForKey:kTELTYPE];
    }
    if ([aDecoder containsValueForKey:kTELNUM]) {
      _teleNumber = [aDecoder decodeObjectForKey:kTELNUM];
    }
    if ([aDecoder containsValueForKey:kLOGO]) {
      _logoImageLink = [aDecoder decodeObjectForKey:kLOGO];
    }
    if ([aDecoder containsValueForKey:kHIGHRISK]) {
      _highrisk = [aDecoder decodeObjectForKey:kHIGHRISK];
    }
    if ([aDecoder containsValueForKey:kFLAGNUM]) {
      _flagNumber = [aDecoder decodeObjectForKey:kFLAGNUM];
    }
    if ([aDecoder containsValueForKey:kFLAGTYPE]) {
      _flagType = [aDecoder decodeObjectForKey:kFLAGTYPE];
    }
    if ([aDecoder containsValueForKey:kFLAGDATE]) {
      _flagDate = [aDecoder decodeObjectForKey:kFLAGDATE];
    }
    
      if ([aDecoder containsValueForKey:kUSERTAGGED]) {
          _userTaggedType = [aDecoder decodeIntForKey:kUSERTAGGED];
      }

    if ([aDecoder containsValueForKey:kRSHOPID]) {
      _shopID = [aDecoder decodeObjectForKey:kRSHOPID];
    }
    if ([aDecoder containsValueForKey:kTELENUMBERS]) {
      _teleNumbers =   [aDecoder decodeObjectForKey:kTELENUMBERS];
    }
    if ([aDecoder containsValueForKey:kWEBURL]) {
      _webURL =   [aDecoder decodeObjectForKey:kWEBURL];
    }
    if ([aDecoder containsValueForKey:kUSERFLAGCONTENT]) {
      _userFlagContent =   [aDecoder decodeObjectForKey:kUSERFLAGCONTENT];
    }
    
    if ([aDecoder containsValueForKey:kSLOGAN_IMG]) {
      _sloganImageURL =   [aDecoder decodeObjectForKey:kSLOGAN_IMG];
    }
    
    if ([aDecoder containsValueForKey:kSLOGAN_CONTENT]) {
      _sloganContent =   [aDecoder decodeObjectForKey:kSLOGAN_CONTENT];
    }
    
    
  }
  
  return self;
}

- (void)encodeWithCoder:(NSCoder*)coder {

  [coder encodeObject:_location forKey:kTELLOC];
  [coder encodeObject:_rank forKey:kTELRANK];
  [coder encodeObject:_rDescription forKey:kTELDESC];
  [coder encodeObject:_name forKey:kNAME];
  [coder encodeObject:_imageLink forKey:kIMAGE];
  [coder encodeObject:_rID forKey:kID];
  [coder encodeObject:_rType forKey:kTELTYPE];
  [coder encodeObject:_teleNumber forKey:kTELNUM];
  [coder encodeObject:_logoImageLink forKey:kLOGO];
  [coder encodeObject:_highrisk forKey:kHIGHRISK];
  [coder encodeObject:_flagNumber forKey:kFLAGNUM];
  [coder encodeObject:_flagType forKey:kFLAGTYPE];
  [coder encodeObject:_flagDate forKey:kFLAGDATE];
    [coder encodeInteger:_userTaggedType forKey:kUSERTAGGED];
    [coder encodeObject:_shopID forKey:kRSHOPID];
  
      [coder encodeObject:_teleNumbers forKey:kTELENUMBERS];
  [coder encodeObject:_webURL forKey:kWEBURL];
  
  [coder encodeObject:_userFlagContent forKey:kUSERFLAGCONTENT];
  [coder encodeObject:_sloganImageURL forKey:kSLOGAN_IMG];
    [coder encodeObject:_sloganContent forKey:kSLOGAN_CONTENT];
  
}

/*
 @property (nonatomic, copy) NSString *location;
 @property (nonatomic, copy) NSString *rank;
 @property (nonatomic, copy) NSString *rDescription;
 @property (nonatomic, copy) NSString *name;
 @property (nonatomic, copy) NSString *imageLink;
 @property (nonatomic, copy) NSString *rID;
 @property (nonatomic, copy) NSString *rType;
 @property (nonatomic, copy) NSString *teleNumber;
 @property (nonatomic, copy) NSString *logoImageLink;
 @property (nonatomic, copy) NSString *highrisk;
 
 @property (nonatomic, copy) NSString *flagNumber;
 @property (nonatomic, copy) NSString *flagType;
 @property (nonatomic, copy) NSString *flagDate;
 
 @property (nonatomic, copy) NSString *displayTitle;
 @property (nonatomic, copy) NSString *flagInfo;
 @property (nonatomic, copy) NSString *shopID;
 @property (nonatomic, copy) NSMutableArray *teleNumbers;
 @property (nonatomic, copy) NSString *webURL;
 
 @property (nonatomic, copy) NSString *sloganImageURL;
 @property (nonatomic, copy) NSString *sloganContent;
 
 @property (nonatomic, copy) NSString *userFlagContent;
 @property (nonatomic, assign) DHBSDKMarkNumberType userTaggedType;
 */
- (NSString *)description {
    return [NSString stringWithFormat:@"ResolveItemNew:\nlocation:%@ | rank:%@ | rDescription:%@| name:%@ | imageLink:%@ | rId:%@ | rType:%@ | teleNumber:%@ | logoImageLink:%@ | highrisk:%@ | flagNumber:%@ | flagType:%@ | flagDate:%@ | displayTitle:%@ | flagInfo:%@ | shopID:%@ | teleNumbers:%@ | webURL:%@ | sloganImageURL:%@ | sloganContent:%@ | userFlagContent:%@ | userTaggedType:%zd",self.location,self.rank,self.rDescription,self.name,self.imageLink,self.rID,self.rType,self.teleNumber,self.logoImageLink,self.highrisk,self.flagNumber,self.flagType,self.flagDate,self.displayTitle,self.flagInfo,self.shopID,self.teleNumbers,self.webURL,self.sloganImageURL,self.sloganContent,self.userFlagContent,self.userTaggedType];
}

@end
