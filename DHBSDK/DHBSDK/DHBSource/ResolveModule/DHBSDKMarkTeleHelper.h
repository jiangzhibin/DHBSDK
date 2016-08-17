//
//  MarkTeleHelper.h
//  DHBDemo
//
//  Created by 蒋兵兵 on 16/8/12.
//  Copyright © 2016年 蒋兵兵. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DHBSDKMarkTeleHelper : NSObject



/**
 在线标记号码

 @param aNumber             电话号码
 @param flagInfomation      被标记的信息
 @param completeBlock       标记完成的回调
 */
+ (void)markTeleNumberOnlineWithNumber:(NSString *)aNumber
                        flagInfomation:(NSString *)flagInfomation
                     completionHandler:(void (^)( BOOL successed, NSError *error))completeBlock;

@end
