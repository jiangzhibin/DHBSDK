/* ioapi.h -- IO base function header for compress/uncompress .zip
   files using zlib + zip or unzip API

   Version 1.01h, December 28th, 2009

   Copyright (C) 1998-2009 Gilles Vollant
*/

#ifndef _ZLIBIOAPI_H
#define _ZLIBIOAPI_H


#define DHBSDK_ZLIB_FILEFUNC_SEEK_CUR (1)
#define DHBSDK_ZLIB_FILEFUNC_SEEK_END (2)
#define DHBSDK_ZLIB_FILEFUNC_SEEK_SET (0)

#define DHBSDK_ZLIB_FILEFUNC_MODE_READ      (1)
#define DHBSDK_ZLIB_FILEFUNC_MODE_WRITE     (2)
#define DHBSDK_ZLIB_FILEFUNC_MODE_READWRITEFILTER (3)

#define DHBSDK_ZLIB_FILEFUNC_MODE_EXISTING (4)
#define DHBSDK_ZLIB_FILEFUNC_MODE_CREATE   (8)


#ifndef DHBSDK_ZCALLBACK

#if (defined(WIN32) || defined (WINDOWS) || defined (_WINDOWS)) && defined(CALLBACK) && defined (USEWINDOWS_CALLBACK)
#define DHBSDK_ZCALLBACK CALLBACK
#else
#define DHBSDK_ZCALLBACK
#endif
#endif

#ifdef __cplusplus
extern "C" {
#endif

typedef voidpf (DHBSDK_ZCALLBACK *open_file_func) OF((voidpf opaque, const char* filename, int mode));
typedef uLong  (DHBSDK_ZCALLBACK *read_file_func) OF((voidpf opaque, voidpf stream, void* buf, uLong size));
typedef uLong  (DHBSDK_ZCALLBACK *write_file_func) OF((voidpf opaque, voidpf stream, const void* buf, uLong size));
typedef long   (DHBSDK_ZCALLBACK *tell_file_func) OF((voidpf opaque, voidpf stream));
typedef long   (DHBSDK_ZCALLBACK *seek_file_func) OF((voidpf opaque, voidpf stream, uLong offset, int origin));
typedef int    (DHBSDK_ZCALLBACK *close_file_func) OF((voidpf opaque, voidpf stream));
typedef int    (DHBSDK_ZCALLBACK *testerror_file_func) OF((voidpf opaque, voidpf stream));

typedef struct dhbsdk_zlib_filefunc_def_s
{
    open_file_func      zopen_file;
    read_file_func      zread_file;
    write_file_func     zwrite_file;
    tell_file_func      ztell_file;
    seek_file_func      zseek_file;
    close_file_func     zclose_file;
    testerror_file_func zerror_file;
    voidpf              opaque;
} dhbsdk_zlib_filefunc_def;



void dhbsdk_fill_fopen_filefunc OF((dhbsdk_zlib_filefunc_def* pzlib_filefunc_def));

#define DHBSDK_ZREAD(filefunc,filestream,buf,size) ((*((filefunc).zread_file))((filefunc).opaque,filestream,buf,size))
#define DHBSDK_ZWRITE(filefunc,filestream,buf,size) ((*((filefunc).zwrite_file))((filefunc).opaque,filestream,buf,size))
#define DHBSDK_ZTELL(filefunc,filestream) ((*((filefunc).ztell_file))((filefunc).opaque,filestream))
#define DHBSDK_ZSEEK(filefunc,filestream,pos,mode) ((*((filefunc).zseek_file))((filefunc).opaque,filestream,pos,mode))
#define DHBSDK_ZCLOSE(filefunc,filestream) ((*((filefunc).zclose_file))((filefunc).opaque,filestream))
#define DHBSDK_ZERROR(filefunc,filestream) ((*((filefunc).zerror_file))((filefunc).opaque,filestream))


#ifdef __cplusplus
}
#endif

#endif

