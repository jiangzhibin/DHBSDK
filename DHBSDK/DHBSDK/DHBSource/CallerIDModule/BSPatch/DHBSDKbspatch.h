//
//  DHBBSpatch.h
//  TestiOSBSPatch
//
//  Created by Zhang Heyin on 15/8/6.
//  Copyright (c) 2015年 Yulore. All rights reserved.
//

#ifndef __TestiOSBSPatch__DHBBSpatch__
#define __TestiOSBSPatch__DHBBSpatch__

/**
 *  bspatch 核心代码
 *
 *  @param oldfile   输入旧文件
 *  @param newfile   输出新文件
 *  @param patchfile 中间包文件
 *
 *  @return 0正常 !0有异常
 */
int bspatch(const char *oldfile, const char * newfile,const char * patchfile);
#endif /* defined(__TestiOSBSPatch__DHBBSpatch__) */
