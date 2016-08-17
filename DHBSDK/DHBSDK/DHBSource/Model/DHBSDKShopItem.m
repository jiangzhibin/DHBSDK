//
//  ShopItem.m
//  DianHuaBang
//
//  Created by Zhang Heyin on 13-7-15.
//  Copyright (c) 2013年 Yulore. All rights reserved.
//

#import "DHBSDKShopItem.h"
#import "DHBSDKTeleNumber.h"
#import "DHBSDKCustomItem.h"
#import "DHBSDKResolveItemNew.h"
@implementation DHBSDKShopItem
#define KEY_NAME (@"name")
#define KEY_SID (@"sid")
#define KEY_CATEGORYIDS (@"categoryIDs")
#define KEY_SUBNAME (@"subName")
#define KEY_CALLTIMES (@"callTimes")
#define KEY_TYPE (@"type")
#define KEY_DISTANCE (@"distance")
#define KEY_TELENUMBER (@"telenumber")
#define KEY_TELENUMBERS (@"teleNumbers")
#define KEY_LOGOURL (@"logoURL")
#define KEY_TUAN (@"tuan")
#define KEY_COUPON (@"coupon")
#define KEY_CUSTOMS (@"customs")
#define KEY_WEBSITE (@"website")
#define KEY_ADDRESS (@"address")


#define KEY_IMAGEURL (@"imageurl")
#define KEY_PRICE (@"price")
#define KEY_SCORE (@"score")
#define KEY_COORDINATE_LAT (@"coordinate_lat")
#define KEY_COORDINATE_LNG (@"coordinate_lng")



+ (instancetype)shopItemWithResolveItem:(DHBSDKResolveItemNew *)aResolveItem {
  DHBSDKShopItem *aShopItem = [[DHBSDKShopItem alloc] init];
  if (aShopItem) {
    aShopItem.name = aResolveItem.name;
    aShopItem.teleNumbers = aResolveItem.teleNumbers;
    aShopItem.subName = @"";//customItem.subTitle;
    aShopItem.website = aResolveItem.webURL;
    aShopItem.logoURL = [NSURL URLWithString:aResolveItem.logoImageLink];
    aShopItem.customs = nil;//[NSMutableArray arrayWithObject:customItem];
    aShopItem.sid = aResolveItem.shopID;
    if (aResolveItem.teleNumbers && [aResolveItem.teleNumbers count] > 0) {
      aShopItem.telenumber =((DHBSDKTeleNumber *) aShopItem.teleNumbers.firstObject).teleNumber;
    }
    else {
      DHBSDKTeleNumber *aTel = [[DHBSDKTeleNumber alloc] init];
      aTel.teleDescription =aResolveItem.rDescription;
      aTel.teleNumber = aResolveItem.teleNumber;
      aTel.teleType = aResolveItem.flagType;
      aShopItem.teleNumbers = [@[aTel] mutableCopy];
      aShopItem.telenumber = aResolveItem.teleNumber;
    }
  }
  
  
  return aShopItem;
}




+ (instancetype)shopItemWithCustomItem:(DHBSDKCustomItem *)customItem {
  
  DHBSDKShopItem *aShopItem = [[DHBSDKShopItem alloc] init];
  if (aShopItem) {
    aShopItem.name = customItem.title;
    aShopItem.teleNumbers = customItem.telenumberItems;
    aShopItem.subName = customItem.subTitle;
    aShopItem.website = customItem.website;
    aShopItem.logoURL = customItem.iconURL;
    aShopItem.customs = [NSMutableArray arrayWithObject:customItem];
    aShopItem.sid = customItem.shopID;
    if (aShopItem.teleNumbers) {
      aShopItem.telenumber =((DHBSDKTeleNumber *) aShopItem.teleNumbers.firstObject).teleNumber;
    }
  }
  
  
  return aShopItem;
}
- (NSString *)description {
  return [NSString stringWithFormat:@"name : %@, telenumber : %@", self.name, self.telenumber ];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  if (self = [super init]) {
    if ([aDecoder containsValueForKey:KEY_NAME]) {
      _name =   [aDecoder decodeObjectForKey:KEY_NAME];
    }
    if ([aDecoder containsValueForKey:KEY_SID]) {
      _sid =   [aDecoder decodeObjectForKey:KEY_SID];
    }
    if ([aDecoder containsValueForKey:KEY_CATEGORYIDS]) {
      _categoryIDs =   [aDecoder decodeObjectForKey:KEY_CATEGORYIDS];
    }
    if ([aDecoder containsValueForKey:KEY_SUBNAME]) {
      _subName =   [aDecoder decodeObjectForKey:KEY_SUBNAME];
    }
    if ([aDecoder containsValueForKey:KEY_CALLTIMES]) {
      _name =   [aDecoder decodeObjectForKey:KEY_NAME];
    }
    if ([aDecoder containsValueForKey:KEY_TYPE]) {
      _type =   [aDecoder decodeObjectForKey:KEY_TYPE];
    }
    if ([aDecoder containsValueForKey:KEY_DISTANCE]) {
      _distance =   [aDecoder decodeObjectForKey:KEY_DISTANCE];
    }
    if ([aDecoder containsValueForKey:KEY_TELENUMBER]) {
      _telenumber =   [aDecoder decodeObjectForKey:KEY_TELENUMBER];
    }
    if ([aDecoder containsValueForKey:KEY_TELENUMBERS]) {
      _teleNumbers =   [aDecoder decodeObjectForKey:KEY_TELENUMBERS];
    }
    if ([aDecoder containsValueForKey:KEY_LOGOURL]) {
      _logoURL =   [aDecoder decodeObjectForKey:KEY_LOGOURL];
    }
    
    if ([aDecoder containsValueForKey:KEY_WEBSITE]) {
      _website =   [aDecoder decodeObjectForKey:KEY_WEBSITE];
    }
//    if ([aDecoder containsValueForKey:KEY_CUSTOMS]) {
//      _customs =   [aDecoder decodeObjectForKey:KEY_CUSTOMS];
//    }
    if ([aDecoder containsValueForKey:KEY_ADDRESS]) {
      _address =   [aDecoder decodeObjectForKey:KEY_ADDRESS];
    }
    
    if ([aDecoder containsValueForKey:KEY_COORDINATE_LAT] &&
        [aDecoder containsValueForKey:KEY_COORDINATE_LNG]) {
      CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([aDecoder decodeDoubleForKey:KEY_COORDINATE_LAT], [aDecoder decodeDoubleForKey:KEY_COORDINATE_LNG]);
      _coordinate = coordinate;
    }
    if ([aDecoder containsValueForKey:KEY_PRICE]) {
      _price =   [aDecoder decodeObjectForKey:KEY_PRICE];
    }
    if ([aDecoder containsValueForKey:KEY_SCORE]) {
      _score =   [aDecoder decodeObjectForKey:KEY_SCORE];
    }

  }
  return self;
}





- (void)encodeWithCoder:(NSCoder*)coder
{
  [coder encodeObject:_name forKey:KEY_NAME];
  [coder encodeObject:_sid forKey:KEY_SID];
  [coder encodeObject:_categoryIDs forKey:KEY_CATEGORYIDS];
  [coder encodeObject:_subName forKey:KEY_SUBNAME];
  [coder encodeObject:_callTimes forKey:KEY_CALLTIMES];
  [coder encodeObject:_type forKey:KEY_TYPE];
  [coder encodeObject:_distance forKey:KEY_DISTANCE];
  [coder encodeObject:_telenumber forKey:KEY_TELENUMBER];
  [coder encodeObject:_teleNumbers forKey:KEY_TELENUMBERS];
  [coder encodeObject:_logoURL forKey:KEY_LOGOURL];
  [coder encodeBool:_tuan forKey:KEY_TUAN];
  [coder encodeBool:_coupon forKey:KEY_COUPON];
  [coder encodeObject:_website forKey:KEY_WEBSITE];
  //[coder encodeObject:_customs forKey:KEY_CUSTOMS];
  [coder encodeObject:_address forKey:KEY_ADDRESS];
  
  [coder encodeDouble:_coordinate.latitude forKey:KEY_COORDINATE_LAT];
  [coder encodeDouble:_coordinate.longitude forKey:KEY_COORDINATE_LNG ];
  [coder encodeObject:_price forKey:KEY_PRICE];
  [coder encodeObject:_score forKey:KEY_SCORE];

}
- (NSString *)formatDistance:(NSString *)distance {
  int idistance = [distance intValue];
  NSString *formatDistance = nil;
  if (idistance > 1000) {
    if (idistance > 100*1000) {
      // formatDistance = @">100km";
      formatDistance = @"";
    } else {
      formatDistance = [NSString stringWithFormat:@"%.2fkm", idistance / 1000.f];
    }
  } else if (idistance > 0){
    formatDistance = [NSString stringWithFormat:@"%dm", idistance];
  } else if (idistance == -1) {
    formatDistance = @"";
  }
  return formatDistance;
}

- (NSString *)formatCalltimes:(id)callTimes {
  NSString *formatCalltimes = nil;
  
  
  if ([callTimes isKindOfClass:[NSNull class]] || callTimes == nil) {
    formatCalltimes = @"";
  } else {
    NSString *strCallTimes = [NSString stringWithFormat:@"%@", callTimes];
    
    if ([strCallTimes length] > 0) {
      
      if ([strCallTimes length] > 4) {
        int calls = [strCallTimes intValue];
        float fcalls = calls / 10000.f;
        float b =(int)((fcalls * 10) + 0.5) / 10.0;
        formatCalltimes = [NSString stringWithFormat:@"%.1f万人拨打", b];
      } else {
        formatCalltimes = [NSString stringWithFormat:@"%@人拨打", strCallTimes];
      }
    } else {
      formatCalltimes = @"";
    }
  }
  return formatCalltimes;
}

- (NSMutableSet *) mainLevelSet {
  NSArray *array = [NSArray arrayWithObjects:
                    @"36",@"18",@"52",@"45",@"42",@"51",@"26",@"8",@"29",@"33",@"30",@"11",@"48",@"16",@"1467",@"4", nil];
  NSMutableSet *mainLevelSet = [[NSMutableSet alloc] init];
  for (NSString *aID in array) {
    [mainLevelSet addObject:[NSString stringWithFormat:@"%@", aID]];
  }
  return mainLevelSet;
}


- (NSString *)shopIDWithData:(NSString *)urlformatted {
  //  NSString *urlformatted = [data stringByReplacingOccurrencesOfString:@"yulorepage-list:" withString:@""];
  if (urlformatted == nil) {
    return nil;
  }
  NSArray *array = [urlformatted componentsSeparatedByString:@"&"];
  
  
//  NSInteger city_id = 0;
  
  NSString *cat_id = @"";
  for (NSString *keyValue in array) {
    NSArray *keyValueArray = [keyValue componentsSeparatedByString:@"="];
    if ([keyValueArray count] == 2) {
      NSString *key = keyValueArray[0];
      NSString *value = keyValueArray[1];
      
      if ([key isEqualToString:@"sid"]) {
        cat_id = value;
      }
    }
  }
  
  
  
  return cat_id;
  
}


+ (instancetype)shopItemWithDictionary:(NSDictionary *)dictionary {
  DHBSDKShopItem *shopItem = [[DHBSDKShopItem alloc] initWithDictionary:dictionary];
  
  return shopItem;
}

- (id)initWithDictionary:(NSDictionary *)item {
  self = [super init];
  if (self) {
    _sid = [item valueForKey:@"id"];
    
    if (_sid == nil) {
      _sid = [self shopIDWithData:[item valueForKeyPath:@"act.data"]];
    }
    
    _name = [item valueForKey:@"name"];
    
    if (_name == nil) {
      _name = [item valueForKey:@"title"];
    }
    
    _website = [item valueForKey:@"website"];
    // _customs = [item valueForKey:@"customs"];
    _address = [item valueForKey:@"address"];
    
    _teleNumbers = [[NSMutableArray alloc] init];
    _categoryIDs = [item valueForKey:@"cat_id"];
    
    
    
    id svc = [item valueForKey:@"svcs"];
    
    for (id item in svc) {
      if ([item isEqualToString:@"tuan"]) {
        _tuan = YES;
      }
    }
 //   _tuan = [item valueForKey:@"tuan"] ? YES : NO;
    _coupon = [item valueForKey:@"tuan"] ? YES : NO;
    
    NSString *urlString = [item objectForKey:@"logo"];
    if (![urlString isKindOfClass:[NSNull class]]) {
      _logoURL = ( [urlString length] != 0) ?  [NSURL URLWithString:[NSString stringWithFormat:@"%@",urlString]] : nil;
      
    }
    
    if (urlString == nil) {
      _logoURL = [item objectForKey:@"icon"] ? [NSURL URLWithString:[NSString stringWithFormat:@"%@",[item objectForKey:@"icon"]]] : nil;
      
    }
    
    
    

    NSString *logoString = [item objectForKey:@"image"];
    if (![logoString isKindOfClass:[NSNull class]]) {
      _imageURL = ( [logoString length] != 0) ?  [NSURL URLWithString:[NSString stringWithFormat:@"%@",logoString]] : nil;
      
    }

    

    
    _distance = [self formatDistance:[item valueForKey:@"dist"]];
    
    _callTimes = [self formatCalltimes:[item valueForKey:@"dialnum"]];
    
    if ([[item allKeys] containsObject:@"lat"] && [[item allKeys] containsObject:@"lng"]) {
      _coordinate = CLLocationCoordinate2DMake([[item valueForKey:@"lat"] doubleValue], [[item valueForKey:@"lng"] doubleValue]);
    } else {
      _coordinate = CLLocationCoordinate2DMake(999,999);
    }
    
    
    
    NSArray *cat_ids = _categoryIDs;
    NSMutableSet *mainLevel = [self mainLevelSet];
    NSString *displayImageID = @"-1";
    
    for (id aID in cat_ids) {
      if ([mainLevel containsObject:[NSString stringWithFormat:@"%@", aID]]) {
        displayImageID = aID;
        break;
      }
    }
    _type = displayImageID;
    
    
    NSArray *allKeys = [item allKeys];
    NSString *telKey ;
    if ([allKeys containsObject:@"tel"]) {
      telKey = @"tel";
    } else {
      telKey = @"tels";
    }
    
    NSMutableArray *telnumbersArray = [item valueForKey:telKey];
    
    for (NSDictionary *aTel in telnumbersArray) {
      DHBSDKTeleNumber *aTelNumber = [[DHBSDKTeleNumber alloc] initWithDictionary:aTel];
      [_teleNumbers addObject:aTelNumber];
    }
    
    
    DHBSDKTeleNumber *disp = [_teleNumbers count] > 0 ? [_teleNumbers objectAtIndex:0] : [[DHBSDKTeleNumber alloc] initWithBlank];
    
    _telenumber = disp.teleNumber;
    
    NSMutableArray *customsArray = [item valueForKey:@"customs"];
    
    
    
    _customs = [[NSMutableArray alloc] init];
    for (NSDictionary *aCustom in customsArray) {
      DHBSDKCustomItem *aCus = [[DHBSDKCustomItem alloc] initWithDictionary:aCustom];
      [_customs addObject:aCus];
    }
    
    
    
    
    
    id extend = [item objectForKey:@"extend"];
    if (extend) {
      _price = [item valueForKeyPath:@"extend.price"];
      _score = [item valueForKeyPath:@"extend.score"];
    }
  }
  
  return self;
}


@end
