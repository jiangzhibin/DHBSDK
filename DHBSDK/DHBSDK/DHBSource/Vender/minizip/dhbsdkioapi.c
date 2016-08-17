/* ioapi.c -- IO base function header for compress/uncompress .zip
   files using zlib + zip or unzip API

   Version 1.01h, December 28th, 2009

   Copyright (C) 1998-2009 Gilles Vollant
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "zlib.h"
#include "dhbsdkioapi.h"



/* I've found an old Unix (a SunOS 4.1.3_U1) without all SEEK_* defined.... */

#ifndef SEEK_CUR
#define SEEK_CUR    1
#endif

#ifndef SEEK_END
#define SEEK_END    2
#endif

#ifndef SEEK_SET
#define SEEK_SET    0
#endif

voidpf DHBSDK_ZCALLBACK dhbsdk_fopen_file_func OF((
   voidpf opaque,
   const char* filename,
   int mode));

uLong DHBSDK_ZCALLBACK dhbsdk_fread_file_func OF((
   voidpf opaque,
   voidpf stream,
   void* buf,
   uLong size));

uLong DHBSDK_ZCALLBACK dhbsdk_fwrite_file_func OF((
   voidpf opaque,
   voidpf stream,
   const void* buf,
   uLong size));

long DHBSDK_ZCALLBACK dhbsdk_ftell_file_func OF((
   voidpf opaque,
   voidpf stream));

long DHBSDK_ZCALLBACK dhbsdk_fseek_file_func OF((
   voidpf opaque,
   voidpf stream,
   uLong offset,
   int origin));

int DHBSDK_ZCALLBACK dhbsdk_fclose_file_func OF((
   voidpf opaque,
   voidpf stream));

int DHBSDK_ZCALLBACK dhbsdk_ferror_file_func OF((
   voidpf opaque,
   voidpf stream));


voidpf DHBSDK_ZCALLBACK dhbsdk_fopen_file_func (opaque, filename, mode)
   voidpf opaque;
   const char* filename;
   int mode;
{
    FILE* file = NULL;
    const char* mode_fopen = NULL;
    if ((mode & DHBSDK_ZLIB_FILEFUNC_MODE_READWRITEFILTER)==DHBSDK_ZLIB_FILEFUNC_MODE_READ)
        mode_fopen = "rb";
    else
    if (mode & DHBSDK_ZLIB_FILEFUNC_MODE_EXISTING)
        mode_fopen = "r+b";
    else
    if (mode & DHBSDK_ZLIB_FILEFUNC_MODE_CREATE)
        mode_fopen = "wb";

    if ((filename!=NULL) && (mode_fopen != NULL))
        file = fopen(filename, mode_fopen);
    return file;
}


uLong DHBSDK_ZCALLBACK dhbsdk_fread_file_func (opaque, stream, buf, size)
   voidpf opaque;
   voidpf stream;
   void* buf;
   uLong size;
{
    uLong ret;
    ret = (uLong)fread(buf, 1, (size_t)size, (FILE *)stream);
    return ret;
}


uLong DHBSDK_ZCALLBACK dhbsdk_fwrite_file_func (opaque, stream, buf, size)
   voidpf opaque;
   voidpf stream;
   const void* buf;
   uLong size;
{
    uLong ret;
    ret = (uLong)fwrite(buf, 1, (size_t)size, (FILE *)stream);
    return ret;
}

long DHBSDK_ZCALLBACK dhbsdk_ftell_file_func (opaque, stream)
   voidpf opaque;
   voidpf stream;
{
    long ret;
    ret = ftell((FILE *)stream);
    return ret;
}

long DHBSDK_ZCALLBACK dhbsdk_fseek_file_func (opaque, stream, offset, origin)
   voidpf opaque;
   voidpf stream;
   uLong offset;
   int origin;
{
    int fseek_origin=0;
    long ret;
    switch (origin)
    {
    case DHBSDK_ZLIB_FILEFUNC_SEEK_CUR :
        fseek_origin = SEEK_CUR;
        break;
    case DHBSDK_ZLIB_FILEFUNC_SEEK_END :
        fseek_origin = SEEK_END;
        break;
    case DHBSDK_ZLIB_FILEFUNC_SEEK_SET :
        fseek_origin = SEEK_SET;
        break;
    default: return -1;
    }
    ret = 0;
    if (fseek((FILE *)stream, offset, fseek_origin) != 0)
        ret = -1;
    return ret;
}

int DHBSDK_ZCALLBACK dhbsdk_fclose_file_func (opaque, stream)
   voidpf opaque;
   voidpf stream;
{
    int ret;
    ret = fclose((FILE *)stream);
    return ret;
}

int DHBSDK_ZCALLBACK dhbsdk_ferror_file_func (opaque, stream)
   voidpf opaque;
   voidpf stream;
{
    int ret;
    ret = ferror((FILE *)stream);
    return ret;
}

void dhbsdk_fill_fopen_filefunc (pzlib_filefunc_def)
  dhbsdk_zlib_filefunc_def* pzlib_filefunc_def;
{
    pzlib_filefunc_def->zopen_file = dhbsdk_fopen_file_func;
    pzlib_filefunc_def->zread_file = dhbsdk_fread_file_func;
    pzlib_filefunc_def->zwrite_file = dhbsdk_fwrite_file_func;
    pzlib_filefunc_def->ztell_file = dhbsdk_ftell_file_func;
    pzlib_filefunc_def->zseek_file = dhbsdk_fseek_file_func;
    pzlib_filefunc_def->zclose_file = dhbsdk_fclose_file_func;
    pzlib_filefunc_def->zerror_file = dhbsdk_ferror_file_func;
    pzlib_filefunc_def->opaque = NULL;
}
