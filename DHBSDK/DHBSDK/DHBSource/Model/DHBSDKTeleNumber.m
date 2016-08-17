//
//  TeleNumber.m
//  DemoDetail
//
//  Created by Zhang Heyin on 13-7-11.
//  Copyright (c) 2013年 Yulore. All rights reserved.
//

#import "DHBSDKTeleNumber.h"

@implementation DHBSDKTeleNumber
- (id)initWithBlank{
  self = [super init];
  if (self) {
    self.teleDescription = [NSString stringWithFormat:@""];
    self.teleNumber =  [NSString stringWithFormat:@""];
    self.teleType =  [NSString stringWithFormat:@""];
  }
  return self;
}

- (id)initWithDictionary:(NSDictionary *)detailsDictionary {
  self = [super init];
  if (self) {
    
    if (![[detailsDictionary valueForKey:@"tel_des"] isKindOfClass:[NSNull class]]) {
      self.teleDescription = [detailsDictionary valueForKey:@"tel_des"];
    } else {
      self.teleDescription = @"";
    }
    
    if (![[detailsDictionary valueForKey:@"tel_num"] isKindOfClass:[NSNull class]]) {
      self.teleNumber = [detailsDictionary valueForKey:@"tel_num"];
    } else {
      self.teleNumber = @"";
    }
    
    
    if (![[detailsDictionary valueForKey:@"tel_type"] isKindOfClass:[NSNull class]]) {
      self.teleType = [detailsDictionary valueForKey:@"tel_type"];
    } else {
      self.teleType = @"";
    }

  }
  
  return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
  if ((self = [super init])){
    if ([aDecoder containsValueForKey:@"TEL_DES"]) {
      _teleDescription =   [aDecoder decodeObjectForKey:@"TEL_DES"];
    }

    if ([aDecoder containsValueForKey:@"TEL_TYPE"]) {
      _teleType =   [aDecoder decodeObjectForKey:@"TEL_TYPE"];
    }
    if ([aDecoder containsValueForKey:@"TEL_NUMBER"]) {
      _teleNumber =   [aDecoder decodeObjectForKey:@"TEL_NUMBER"];
    }
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder*)coder
{
  [coder encodeObject:_teleDescription forKey:@"TEL_DES"];
  [coder encodeObject:_teleType forKey:@"TEL_TYPE"];
  [coder encodeObject:_teleNumber forKey:@"TEL_NUMBER"];

}

- (NSString *)description {
    return [NSString stringWithFormat:@"TeleNumber: teleDescription:%@ | teleType:%@ | teleNumber:%@",self.teleDescription,self.teleType,self.teleNumber];
}

@end
