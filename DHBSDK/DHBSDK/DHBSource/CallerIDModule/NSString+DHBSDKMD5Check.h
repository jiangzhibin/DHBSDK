//
//  NSString+MD5Check.h
//  Downloading
//
//  Created by Zhang Heyin on 15/8/10.
//  Copyright (c) 2015年 Yulore. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (DHBSDKMD5Check)

/**
 *  根据输入的文件计算md5比较
 *
 *  @param MD5String 与之比较的md5
 *  @param error     产生的error，无异常为nil
 *
 *  @return 有异常NO，无异常YES
 */
- (BOOL)fileValidMD5WithMD5String:(NSString *)MD5String error:(NSError **)error;
@end
