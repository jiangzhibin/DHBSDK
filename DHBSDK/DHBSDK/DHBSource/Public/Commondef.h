//
//  Commondef.h
//  DHBDemo
//
//  Created by 蒋兵兵 on 16/8/5.
//  Copyright © 2016年 蒋兵兵. All rights reserved.
//

#ifndef Commondef_h
#define Commondef_h

#ifdef __OBJC__

#ifdef DEBUG
#   define DHBSDKDLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#   define DHBSDKDLog(...)
#endif


#endif /* #ifdef __OBJC__ */
#endif  /* #ifndef Commondef_h */
