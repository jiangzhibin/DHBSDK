/* zip.c -- IO on .zip files using zlib
   Version 1.01h, December 28th, 2009

   27 Dec 2004 Rolf Kalbermatter
   Modification to zipOpen2 to support globalComment retrieval.

   Copyright (C) 1998-2009 Gilles Vollant

   Read zip.h for more info
*/


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include "zlib.h"
#include "dhbsdkzip.h"

#ifdef STDC
#  include <stddef.h>
#  include <string.h>
#  include <stdlib.h>
#endif
#ifdef NO_ERRNO_H
    extern int errno;
#else
#   include <errno.h>
#endif


#ifndef local
#  define local static
#endif
/* compile with -Dlocal if your debugger can't find static symbols */

#ifndef VERSIONMADEBY
# define VERSIONMADEBY   (0x0) /* platform depedent */
#endif

#ifndef Z_BUFSIZE
#define Z_BUFSIZE (16384)
#endif

#ifndef Z_MAXFILENAMEINZIP
#define Z_MAXFILENAMEINZIP (256)
#endif

#ifndef ALLOC
# define ALLOC(size) (malloc(size))
#endif
#ifndef TRYFREE
# define TRYFREE(p) {if (p) free(p);}
#endif

/*
#define DHBSDK_SIZECENTRALDIRITEM (0x2e)
#define DHBSDK_SIZEZIPLOCALHEADER (0x1e)
*/

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

#ifndef DEF_MEM_LEVEL
#if MAX_MEM_LEVEL >= 8
#  define DEF_MEM_LEVEL 8
#else
#  define DEF_MEM_LEVEL  MAX_MEM_LEVEL
#endif
#endif
const char dhbsdk_zip_copyright[] =
   " zip 1.01 Copyright 1998-2004 Gilles Vollant - http://www.winimage.com/zLibDll";


#define SIZEDATA_INDATABLOCK (4096-(4*4))

#define LOCALHEADERMAGIC    (0x04034b50)
#define CENTRALHEADERMAGIC  (0x02014b50)
#define ENDHEADERMAGIC      (0x06054b50)

#define FLAG_LOCALHEADER_OFFSET (0x06)
#define CRC_LOCALHEADER_OFFSET  (0x0e)

#define SIZECENTRALHEADER (0x2e) /* 46 */

typedef struct dhbsdk_linkedlist_datablock_internal
{
  struct dhbsdk_linkedlist_datablock_internal* next_datablock;
  uLong  avail_in_this_block;
  uLong  filled_in_this_block;
  uLong  unused; /* for future use and alignement */
  unsigned char data[SIZEDATA_INDATABLOCK];
} dhbsdk_linkedlist_datablock_internal;

typedef struct dhbsdk_linkedlist_data_s
{
    dhbsdk_linkedlist_datablock_internal* first_block;
    dhbsdk_linkedlist_datablock_internal* last_block;
} dhbsdk_linkedlist_data;


typedef struct
{
    z_stream stream;            /* zLib stream structure for inflate */
    int  stream_initialised;    /* 1 is stream is initialised */
    uInt pos_in_buffered_data;  /* last written byte in buffered_data */

    uLong pos_local_header;     /* offset of the local header of the file
                                     currenty writing */
    char* central_header;       /* central header data for the current file */
    uLong size_centralheader;   /* size of the central header for cur file */
    uLong flag;                 /* flag of the file currently writing */

    int  method;                /* compression method of file currenty wr.*/
    int  raw;                   /* 1 for directly writing raw data */
    Byte buffered_data[Z_BUFSIZE];/* buffer contain compressed data to be writ*/
    uLong dosDate;
    uLong crc32;
    int  encrypt;
#ifndef NOCRYPT
    unsigned long keys[3];     /* keys defining the pseudo-random sequence */
    const unsigned long* pcrc_32_tab;
    int crypt_header_size;
#endif
} dhbsdk_curfile_info;

typedef struct
{
    dhbsdk_zlib_filefunc_def z_filefunc;
    voidpf filestream;        /* io structore of the zipfile */
    dhbsdk_linkedlist_data central_dir;/* datablock with central dir in construction*/
    int  in_opened_file_inzip;  /* 1 if a file in the zip is currently writ.*/
    dhbsdk_curfile_info ci;            /* info on the file curretly writing */

    uLong begin_pos;            /* position of the beginning of the zipfile */
    uLong add_position_when_writting_offset;
    uLong number_entry;
#ifndef NO_ADDFILEINEXISTINGZIP
    char *globalcomment;
#endif
} dhbsdk_zip_internal;



#ifndef NOCRYPT
#define DHBSDK_INCLUDECRYPTINGCODE_IFCRYPTALLOWED
#include "dhbsdkcrypt.h"
#endif

local dhbsdk_linkedlist_datablock_internal* allocate_new_datablock()
{
    dhbsdk_linkedlist_datablock_internal* ldi;
    ldi = (dhbsdk_linkedlist_datablock_internal*)
                 ALLOC(sizeof(dhbsdk_linkedlist_datablock_internal));
    if (ldi!=NULL)
    {
        ldi->next_datablock = NULL ;
        ldi->filled_in_this_block = 0 ;
        ldi->avail_in_this_block = SIZEDATA_INDATABLOCK ;
    }
    return ldi;
}

local void dhbsdk_free_datablock(ldi)
    dhbsdk_linkedlist_datablock_internal* ldi;
{
    while (ldi!=NULL)
    {
        dhbsdk_linkedlist_datablock_internal* ldinext = ldi->next_datablock;
        TRYFREE(ldi);
        ldi = ldinext;
    }
}

local void dhbsdk_init_linkedlist(ll)
    dhbsdk_linkedlist_data* ll;
{
    ll->first_block = ll->last_block = NULL;
}

local void dhbsdk_free_linkedlist(ll)
    dhbsdk_linkedlist_data* ll;
{
    dhbsdk_free_datablock(ll->first_block);
    ll->first_block = ll->last_block = NULL;
}


local int dhbsdk_add_data_in_datablock(ll,buf,len)
    dhbsdk_linkedlist_data* ll;
    const void* buf;
    uLong len;
{
    dhbsdk_linkedlist_datablock_internal* ldi;
    const unsigned char* from_copy;

    if (ll==NULL)
        return ZIP_INTERNALERROR;

    if (ll->last_block == NULL)
    {
        ll->first_block = ll->last_block = allocate_new_datablock();
        if (ll->first_block == NULL)
            return ZIP_INTERNALERROR;
    }

    ldi = ll->last_block;
    from_copy = (unsigned char*)buf;

    while (len>0)
    {
        uInt copy_this;
        uInt i;
        unsigned char* to_copy;

        if (ldi->avail_in_this_block==0)
        {
            ldi->next_datablock = allocate_new_datablock();
            if (ldi->next_datablock == NULL)
                return ZIP_INTERNALERROR;
            ldi = ldi->next_datablock ;
            ll->last_block = ldi;
        }

        if (ldi->avail_in_this_block < len)
            copy_this = (uInt)ldi->avail_in_this_block;
        else
            copy_this = (uInt)len;

        to_copy = &(ldi->data[ldi->filled_in_this_block]);

        for (i=0;i<copy_this;i++)
            *(to_copy+i)=*(from_copy+i);

        ldi->filled_in_this_block += copy_this;
        ldi->avail_in_this_block -= copy_this;
        from_copy += copy_this ;
        len -= copy_this;
    }
    return ZIP_OK;
}



/****************************************************************************/

#ifndef NO_ADDFILEINEXISTINGZIP
/* ===========================================================================
   Inputs a long in LSB order to the given file
   nbByte == 1, 2 or 4 (byte, short or long)
*/

local int dhbsdk_ziplocal_putValue OF((const dhbsdk_zlib_filefunc_def* pzlib_filefunc_def,
                                voidpf filestream, uLong x, int nbByte));
local int dhbsdk_ziplocal_putValue (pzlib_filefunc_def, filestream, x, nbByte)
    const dhbsdk_zlib_filefunc_def* pzlib_filefunc_def;
    voidpf filestream;
    uLong x;
    int nbByte;
{
    unsigned char buf[4];
    int n;
    for (n = 0; n < nbByte; n++)
    {
        buf[n] = (unsigned char)(x & 0xff);
        x >>= 8;
    }
    if (x != 0)
      {     /* data overflow - hack for ZIP64 (X Roche) */
      for (n = 0; n < nbByte; n++)
        {
          buf[n] = 0xff;
        }
      }

    if (DHBSDK_ZWRITE(*pzlib_filefunc_def,filestream,buf,nbByte)!=(uLong)nbByte)
        return ZIP_ERRNO;
    else
        return ZIP_OK;
}

local void dhbsdk_ziplocal_putValue_inmemory OF((void* dest, uLong x, int nbByte));
local void dhbsdk_ziplocal_putValue_inmemory (dest, x, nbByte)
    void* dest;
    uLong x;
    int nbByte;
{
    unsigned char* buf=(unsigned char*)dest;
    int n;
    for (n = 0; n < nbByte; n++) {
        buf[n] = (unsigned char)(x & 0xff);
        x >>= 8;
    }

    if (x != 0)
    {     /* data overflow - hack for ZIP64 */
       for (n = 0; n < nbByte; n++)
       {
          buf[n] = 0xff;
       }
    }
}

/****************************************************************************/


local uLong dhbsdk_ziplocal_TmzDateToDosDate(ptm,dosDate)
    const dhbsdk_tm_zip* ptm;
    uLong dosDate;
{
    uLong year = (uLong)ptm->tm_year;
    if (year>=1980)
        year-=1980;
    else if (year>=80)
        year-=80;
    return
      (uLong) (((ptm->tm_mday) + (32 * (ptm->tm_mon+1)) + (512 * year)) << 16) |
        ((ptm->tm_sec/2) + (32* ptm->tm_min) + (2048 * (uLong)ptm->tm_hour));
}


/****************************************************************************/

local int dhbsdk_ziplocal_getByte OF((
    const dhbsdk_zlib_filefunc_def* pzlib_filefunc_def,
    voidpf filestream,
    int *pi));

local int dhbsdk_ziplocal_getByte(pzlib_filefunc_def,filestream,pi)
    const dhbsdk_zlib_filefunc_def* pzlib_filefunc_def;
    voidpf filestream;
    int *pi;
{
    unsigned char c;
    int err = (int)DHBSDK_ZREAD(*pzlib_filefunc_def,filestream,&c,1);
    if (err==1)
    {
        *pi = (int)c;
        return ZIP_OK;
    }
    else
    {
        if (DHBSDK_ZERROR(*pzlib_filefunc_def,filestream))
            return ZIP_ERRNO;
        else
            return ZIP_EOF;
    }
}


/* ===========================================================================
   Reads a long in LSB order from the given gz_stream. Sets
*/
local int dhbsdk_ziplocal_getShort OF((
    const dhbsdk_zlib_filefunc_def* pzlib_filefunc_def,
    voidpf filestream,
    uLong *pX));

local int dhbsdk_ziplocal_getShort (pzlib_filefunc_def,filestream,pX)
    const dhbsdk_zlib_filefunc_def* pzlib_filefunc_def;
    voidpf filestream;
    uLong *pX;
{
    uLong x ;
    int i = 0;
    int err;

    err = dhbsdk_ziplocal_getByte(pzlib_filefunc_def,filestream,&i);
    x = (uLong)i;

    if (err==ZIP_OK)
        err = dhbsdk_ziplocal_getByte(pzlib_filefunc_def,filestream,&i);
    x += ((uLong)i)<<8;

    if (err==ZIP_OK)
        *pX = x;
    else
        *pX = 0;
    return err;
}

local int dhbsdk_ziplocal_getLong OF((
    const dhbsdk_zlib_filefunc_def* pzlib_filefunc_def,
    voidpf filestream,
    uLong *pX));

local int dhbsdk_ziplocal_getLong (pzlib_filefunc_def,filestream,pX)
    const dhbsdk_zlib_filefunc_def* pzlib_filefunc_def;
    voidpf filestream;
    uLong *pX;
{
    uLong x ;
    int i = 0;
    int err;

    err = dhbsdk_ziplocal_getByte(pzlib_filefunc_def,filestream,&i);
    x = (uLong)i;

    if (err==ZIP_OK)
        err = dhbsdk_ziplocal_getByte(pzlib_filefunc_def,filestream,&i);
    x += ((uLong)i)<<8;

    if (err==ZIP_OK)
        err = dhbsdk_ziplocal_getByte(pzlib_filefunc_def,filestream,&i);
    x += ((uLong)i)<<16;

    if (err==ZIP_OK)
        err = dhbsdk_ziplocal_getByte(pzlib_filefunc_def,filestream,&i);
    x += ((uLong)i)<<24;

    if (err==ZIP_OK)
        *pX = x;
    else
        *pX = 0;
    return err;
}

#ifndef DHBSDK_BUFREADCOMMENT
#define DHBSDK_BUFREADCOMMENT (0x400)
#endif
/*
  Locate the Central directory of a zipfile (at the end, just before
    the global comment)
   Fix from Riccardo Cohen
*/
local uLong dhbsdk_ziplocal_SearchCentralDir OF((
    const dhbsdk_zlib_filefunc_def* pzlib_filefunc_def,
    voidpf filestream));

local uLong dhbsdk_ziplocal_SearchCentralDir(pzlib_filefunc_def,filestream)
     const dhbsdk_zlib_filefunc_def* pzlib_filefunc_def;
     voidpf filestream;
{
     unsigned char* buf;
     uLong uSizeFile;
     uLong uBackRead;
     uLong uMaxBack=0xffff; /* maximum size of global comment */
     uLong uPosFound=0;

     if (DHBSDK_ZSEEK(*pzlib_filefunc_def,filestream,0,DHBSDK_ZLIB_FILEFUNC_SEEK_END) != 0)
         return 0;


     uSizeFile = DHBSDK_ZTELL(*pzlib_filefunc_def,filestream);

     if (uMaxBack>uSizeFile)
         uMaxBack = uSizeFile;

     buf = (unsigned char*)ALLOC(DHBSDK_BUFREADCOMMENT+4);
     if (buf==NULL)
         return 0;

     uBackRead = 4;
     while (uBackRead<uMaxBack)
     {
         uLong uReadSize,uReadPos ;
         int i;
         if (uBackRead+DHBSDK_BUFREADCOMMENT>uMaxBack)
             uBackRead = uMaxBack;
         else
             uBackRead+=DHBSDK_BUFREADCOMMENT;
         uReadPos = uSizeFile-uBackRead ;

         uReadSize = ((DHBSDK_BUFREADCOMMENT+4) < (uSizeFile-uReadPos)) ?
                      (DHBSDK_BUFREADCOMMENT+4) : (uSizeFile-uReadPos);
         if (DHBSDK_ZSEEK(*pzlib_filefunc_def,filestream,uReadPos,DHBSDK_ZLIB_FILEFUNC_SEEK_SET)!=0)
             break;

         if (DHBSDK_ZREAD(*pzlib_filefunc_def,filestream,buf,uReadSize)!=uReadSize)
             break;

         for (i=(int)uReadSize-3; (i--)>0;)
             if (((*(buf+i))==0x50) && ((*(buf+i+1))==0x4b) &&
                 ((*(buf+i+2))==0x05) && ((*(buf+i+3))==0x06))
             {
                 uPosFound = uReadPos+i;
                 break;
             }

         if (uPosFound!=0)
             break;
     }
     TRYFREE(buf);
     return uPosFound;
}

#endif /* !NO_ADDFILEINEXISTINGZIP*/

/************************************************************/
extern zipFile ZEXPORT dhbsdk_zipOpen2 (pathname, append, globalcomment, pzlib_filefunc_def)
    const char *pathname;
    int append;
    dhbsdk_zipcharpc* globalcomment;
    dhbsdk_zlib_filefunc_def* pzlib_filefunc_def;
{
    dhbsdk_zip_internal ziinit;
    dhbsdk_zip_internal* zi;
    int err=ZIP_OK;


    if (pzlib_filefunc_def==NULL)
        dhbsdk_fill_fopen_filefunc(&ziinit.z_filefunc);
    else
        ziinit.z_filefunc = *pzlib_filefunc_def;

    ziinit.filestream = (*(ziinit.z_filefunc.zopen_file))
                 (ziinit.z_filefunc.opaque,
                  pathname,
                  (append == APPEND_STATUS_CREATE) ?
                  (DHBSDK_ZLIB_FILEFUNC_MODE_READ | DHBSDK_ZLIB_FILEFUNC_MODE_WRITE | DHBSDK_ZLIB_FILEFUNC_MODE_CREATE) :
                    (DHBSDK_ZLIB_FILEFUNC_MODE_READ | DHBSDK_ZLIB_FILEFUNC_MODE_WRITE | DHBSDK_ZLIB_FILEFUNC_MODE_EXISTING));

    if (ziinit.filestream == NULL)
        return NULL;
    if (append == APPEND_STATUS_CREATEAFTER)
        DHBSDK_ZSEEK(ziinit.z_filefunc,ziinit.filestream,0,SEEK_END);
    ziinit.begin_pos = DHBSDK_ZTELL(ziinit.z_filefunc,ziinit.filestream);
    ziinit.in_opened_file_inzip = 0;
    ziinit.ci.stream_initialised = 0;
    ziinit.number_entry = 0;
    ziinit.add_position_when_writting_offset = 0;
    dhbsdk_init_linkedlist(&(ziinit.central_dir));


    zi = (dhbsdk_zip_internal*)ALLOC(sizeof(dhbsdk_zip_internal));
    if (zi==NULL)
    {
        DHBSDK_ZCLOSE(ziinit.z_filefunc,ziinit.filestream);
        return NULL;
    }

    /* now we add file in a zipfile */
#    ifndef NO_ADDFILEINEXISTINGZIP
    ziinit.globalcomment = NULL;
    if (append == APPEND_STATUS_ADDINZIP)
    {
        uLong byte_before_the_zipfile;/* byte before the zipfile, (>0 for sfx)*/

        uLong size_central_dir;     /* size of the central directory  */
        uLong offset_central_dir;   /* offset of start of central directory */
        uLong central_pos,uL;

        uLong number_disk;          /* number of the current dist, used for
                                    spaning ZIP, unsupported, always 0*/
        uLong number_disk_with_CD;  /* number the the disk with central dir, used
                                    for spaning ZIP, unsupported, always 0*/
        uLong number_entry;
        uLong number_entry_CD;      /* total number of entries in
                                    the central dir
                                    (same than number_entry on nospan) */
        uLong size_comment;

        central_pos = dhbsdk_ziplocal_SearchCentralDir(&ziinit.z_filefunc,ziinit.filestream);
/* disable to allow appending to empty ZIP archive
        if (central_pos==0)
            err=ZIP_ERRNO;
*/
        if (DHBSDK_ZSEEK(ziinit.z_filefunc, ziinit.filestream,
                                        central_pos,DHBSDK_ZLIB_FILEFUNC_SEEK_SET)!=0)
            err=ZIP_ERRNO;

        /* the signature, already checked */
        if (dhbsdk_ziplocal_getLong(&ziinit.z_filefunc, ziinit.filestream,&uL)!=ZIP_OK)
            err=ZIP_ERRNO;

        /* number of this disk */
        if (dhbsdk_ziplocal_getShort(&ziinit.z_filefunc, ziinit.filestream,&number_disk)!=ZIP_OK)
            err=ZIP_ERRNO;

        /* number of the disk with the start of the central directory */
        if (dhbsdk_ziplocal_getShort(&ziinit.z_filefunc, ziinit.filestream,&number_disk_with_CD)!=ZIP_OK)
            err=ZIP_ERRNO;

        /* total number of entries in the central dir on this disk */
        if (dhbsdk_ziplocal_getShort(&ziinit.z_filefunc, ziinit.filestream,&number_entry)!=ZIP_OK)
            err=ZIP_ERRNO;

        /* total number of entries in the central dir */
        if (dhbsdk_ziplocal_getShort(&ziinit.z_filefunc, ziinit.filestream,&number_entry_CD)!=ZIP_OK)
            err=ZIP_ERRNO;

        if ((number_entry_CD!=number_entry) ||
            (number_disk_with_CD!=0) ||
            (number_disk!=0))
            err=ZIP_BADZIPFILE;

        /* size of the central directory */
        if (dhbsdk_ziplocal_getLong(&ziinit.z_filefunc, ziinit.filestream,&size_central_dir)!=ZIP_OK)
            err=ZIP_ERRNO;

        /* offset of start of central directory with respect to the
            starting disk number */
        if (dhbsdk_ziplocal_getLong(&ziinit.z_filefunc, ziinit.filestream,&offset_central_dir)!=ZIP_OK)
            err=ZIP_ERRNO;

        /* zipfile global comment length */
        if (dhbsdk_ziplocal_getShort(&ziinit.z_filefunc, ziinit.filestream,&size_comment)!=ZIP_OK)
            err=ZIP_ERRNO;

        if ((central_pos<offset_central_dir+size_central_dir) &&
            (err==ZIP_OK))
            err=ZIP_BADZIPFILE;

        if (err!=ZIP_OK)
        {
            DHBSDK_ZCLOSE(ziinit.z_filefunc, ziinit.filestream);
            free( zi );
            return NULL;
        }

        if (size_comment>0)
        {
            ziinit.globalcomment = (char*)ALLOC(size_comment+1);
            if (ziinit.globalcomment)
            {
               size_comment = DHBSDK_ZREAD(ziinit.z_filefunc, ziinit.filestream,ziinit.globalcomment,size_comment);
               ziinit.globalcomment[size_comment]=0;
            }
        }

        byte_before_the_zipfile = central_pos -
                                (offset_central_dir+size_central_dir);
        ziinit.add_position_when_writting_offset = byte_before_the_zipfile;

        {
            uLong size_central_dir_to_read = size_central_dir;
            size_t buf_size = SIZEDATA_INDATABLOCK;
            void* buf_read = (void*)ALLOC(buf_size);
            if (DHBSDK_ZSEEK(ziinit.z_filefunc, ziinit.filestream,
                  offset_central_dir + byte_before_the_zipfile,
                  DHBSDK_ZLIB_FILEFUNC_SEEK_SET) != 0)
                  err=ZIP_ERRNO;

            while ((size_central_dir_to_read>0) && (err==ZIP_OK))
            {
                uLong read_this = SIZEDATA_INDATABLOCK;
                if (read_this > size_central_dir_to_read)
                    read_this = size_central_dir_to_read;
                if (DHBSDK_ZREAD(ziinit.z_filefunc, ziinit.filestream,buf_read,read_this) != read_this)
                    err=ZIP_ERRNO;

                if (err==ZIP_OK)
                    err = dhbsdk_add_data_in_datablock(&ziinit.central_dir,buf_read,
                                                (uLong)read_this);
                size_central_dir_to_read-=read_this;
            }
            TRYFREE(buf_read);
        }
        ziinit.begin_pos = byte_before_the_zipfile;
        ziinit.number_entry = number_entry_CD;

        if (DHBSDK_ZSEEK(ziinit.z_filefunc, ziinit.filestream,
                  offset_central_dir+byte_before_the_zipfile,DHBSDK_ZLIB_FILEFUNC_SEEK_SET)!=0)
            err=ZIP_ERRNO;
    }

    if (globalcomment)
    {
      *globalcomment = ziinit.globalcomment;
    }
#    endif /* !NO_ADDFILEINEXISTINGZIP*/

    if (err != ZIP_OK)
    {
#    ifndef NO_ADDFILEINEXISTINGZIP
        TRYFREE(ziinit.globalcomment);
#    endif /* !NO_ADDFILEINEXISTINGZIP*/
        TRYFREE(zi);
        return NULL;
    }
    else
    {
        *zi = ziinit;
        return (zipFile)zi;
    }
}

extern zipFile ZEXPORT dhbsdk_zipOpen (pathname, append)
    const char *pathname;
    int append;
{
    return dhbsdk_zipOpen2(pathname,append,NULL,NULL);
}

extern int ZEXPORT dhbsdk_zipOpenNewFileInZip4 (file, filename, zipfi,
                                         extrafield_local, size_extrafield_local,
                                         extrafield_global, size_extrafield_global,
                                         comment, method, level, raw,
                                         windowBits, memLevel, strategy,
                                         password, crcForCrypting, versionMadeBy, flagBase)
    zipFile file;
    const char* filename;
    const dhbsdk_zip_fileinfo* zipfi;
    const void* extrafield_local;
    uInt size_extrafield_local;
    const void* extrafield_global;
    uInt size_extrafield_global;
    const char* comment;
    int method;
    int level;
    int raw;
    int windowBits;
    int memLevel;
    int strategy;
    const char* password;
    uLong crcForCrypting;
    uLong versionMadeBy;
    uLong flagBase;
{
    dhbsdk_zip_internal* zi;
    uInt size_filename;
    uInt size_comment;
    uInt i;
    int err = ZIP_OK;

#    ifdef NOCRYPT
    if (password != NULL)
        return ZIP_PARAMERROR;
#    endif

    if (file == NULL)
        return ZIP_PARAMERROR;
    if ((method!=0) && (method!=Z_DEFLATED))
        return ZIP_PARAMERROR;

    zi = (dhbsdk_zip_internal*)file;

    if (zi->in_opened_file_inzip == 1)
    {
        err = dhbsdk_zipCloseFileInZip (file);
        if (err != ZIP_OK)
            return err;
    }


    if (filename==NULL)
        filename="-";

    if (comment==NULL)
        size_comment = 0;
    else
        size_comment = (uInt)strlen(comment);

    size_filename = (uInt)strlen(filename);

    if (zipfi == NULL)
        zi->ci.dosDate = 0;
    else
    {
        if (zipfi->dosDate != 0)
            zi->ci.dosDate = zipfi->dosDate;
        else zi->ci.dosDate = dhbsdk_ziplocal_TmzDateToDosDate(&zipfi->tmz_date,zipfi->dosDate);
    }

    zi->ci.flag = flagBase;
    if ((level==8) || (level==9))
      zi->ci.flag |= 2;
    if (level==2)
      zi->ci.flag |= 4;
    if (level==1)
      zi->ci.flag |= 6;
    if (password != NULL)
      zi->ci.flag |= 1;

    zi->ci.crc32 = 0;
    zi->ci.method = method;
    zi->ci.encrypt = 0;
    zi->ci.stream_initialised = 0;
    zi->ci.pos_in_buffered_data = 0;
    zi->ci.raw = raw;
    zi->ci.pos_local_header = DHBSDK_ZTELL(zi->z_filefunc,zi->filestream) ;
    zi->ci.size_centralheader = SIZECENTRALHEADER + size_filename +
                                      size_extrafield_global + size_comment;
    zi->ci.central_header = (char*)ALLOC((uInt)zi->ci.size_centralheader);

    dhbsdk_ziplocal_putValue_inmemory(zi->ci.central_header,(uLong)CENTRALHEADERMAGIC,4);
    /* version info */
    dhbsdk_ziplocal_putValue_inmemory(zi->ci.central_header+4,(uLong)versionMadeBy,2);
    dhbsdk_ziplocal_putValue_inmemory(zi->ci.central_header+6,(uLong)20,2);
    dhbsdk_ziplocal_putValue_inmemory(zi->ci.central_header+8,(uLong)zi->ci.flag,2);
    dhbsdk_ziplocal_putValue_inmemory(zi->ci.central_header+10,(uLong)zi->ci.method,2);
    dhbsdk_ziplocal_putValue_inmemory(zi->ci.central_header+12,(uLong)zi->ci.dosDate,4);
    dhbsdk_ziplocal_putValue_inmemory(zi->ci.central_header+16,(uLong)0,4); /*crc*/
    dhbsdk_ziplocal_putValue_inmemory(zi->ci.central_header+20,(uLong)0,4); /*compr size*/
    dhbsdk_ziplocal_putValue_inmemory(zi->ci.central_header+24,(uLong)0,4); /*uncompr size*/
    dhbsdk_ziplocal_putValue_inmemory(zi->ci.central_header+28,(uLong)size_filename,2);
    dhbsdk_ziplocal_putValue_inmemory(zi->ci.central_header+30,(uLong)size_extrafield_global,2);
    dhbsdk_ziplocal_putValue_inmemory(zi->ci.central_header+32,(uLong)size_comment,2);
    dhbsdk_ziplocal_putValue_inmemory(zi->ci.central_header+34,(uLong)0,2); /*disk nm start*/

    if (zipfi==NULL)
        dhbsdk_ziplocal_putValue_inmemory(zi->ci.central_header+36,(uLong)0,2);
    else
        dhbsdk_ziplocal_putValue_inmemory(zi->ci.central_header+36,(uLong)zipfi->internal_fa,2);

    if (zipfi==NULL)
        dhbsdk_ziplocal_putValue_inmemory(zi->ci.central_header+38,(uLong)0,4);
    else
        dhbsdk_ziplocal_putValue_inmemory(zi->ci.central_header+38,(uLong)zipfi->external_fa,4);

    dhbsdk_ziplocal_putValue_inmemory(zi->ci.central_header+42,(uLong)zi->ci.pos_local_header- zi->add_position_when_writting_offset,4);

    for (i=0;i<size_filename;i++)
        *(zi->ci.central_header+SIZECENTRALHEADER+i) = *(filename+i);

    for (i=0;i<size_extrafield_global;i++)
        *(zi->ci.central_header+SIZECENTRALHEADER+size_filename+i) =
              *(((const char*)extrafield_global)+i);

    for (i=0;i<size_comment;i++)
        *(zi->ci.central_header+SIZECENTRALHEADER+size_filename+
              size_extrafield_global+i) = *(comment+i);
    if (zi->ci.central_header == NULL)
        return ZIP_INTERNALERROR;

    /* write the local header */
    err = dhbsdk_ziplocal_putValue(&zi->z_filefunc,zi->filestream,(uLong)LOCALHEADERMAGIC,4);

    if (err==ZIP_OK)
        err = dhbsdk_ziplocal_putValue(&zi->z_filefunc,zi->filestream,(uLong)20,2);/* version needed to extract */
    if (err==ZIP_OK)
        err = dhbsdk_ziplocal_putValue(&zi->z_filefunc,zi->filestream,(uLong)zi->ci.flag,2);

    if (err==ZIP_OK)
        err = dhbsdk_ziplocal_putValue(&zi->z_filefunc,zi->filestream,(uLong)zi->ci.method,2);

    if (err==ZIP_OK)
        err = dhbsdk_ziplocal_putValue(&zi->z_filefunc,zi->filestream,(uLong)zi->ci.dosDate,4);

    if (err==ZIP_OK)
        err = dhbsdk_ziplocal_putValue(&zi->z_filefunc,zi->filestream,(uLong)0,4); /* crc 32, unknown */
    if (err==ZIP_OK)
        err = dhbsdk_ziplocal_putValue(&zi->z_filefunc,zi->filestream,(uLong)0,4); /* compressed size, unknown */
    if (err==ZIP_OK)
        err = dhbsdk_ziplocal_putValue(&zi->z_filefunc,zi->filestream,(uLong)0,4); /* uncompressed size, unknown */

    if (err==ZIP_OK)
        err = dhbsdk_ziplocal_putValue(&zi->z_filefunc,zi->filestream,(uLong)size_filename,2);

    if (err==ZIP_OK)
        err = dhbsdk_ziplocal_putValue(&zi->z_filefunc,zi->filestream,(uLong)size_extrafield_local,2);

    if ((err==ZIP_OK) && (size_filename>0))
        if (DHBSDK_ZWRITE(zi->z_filefunc,zi->filestream,filename,size_filename)!=size_filename)
                err = ZIP_ERRNO;

    if ((err==ZIP_OK) && (size_extrafield_local>0))
        if (DHBSDK_ZWRITE(zi->z_filefunc,zi->filestream,extrafield_local,size_extrafield_local)
                                                                           !=size_extrafield_local)
                err = ZIP_ERRNO;

    zi->ci.stream.avail_in = (uInt)0;
    zi->ci.stream.avail_out = (uInt)Z_BUFSIZE;
    zi->ci.stream.next_out = zi->ci.buffered_data;
    zi->ci.stream.total_in = 0;
    zi->ci.stream.total_out = 0;
    zi->ci.stream.data_type = Z_BINARY;

    if ((err==ZIP_OK) && (zi->ci.method == Z_DEFLATED) && (!zi->ci.raw))
    {
        zi->ci.stream.zalloc = (alloc_func)0;
        zi->ci.stream.zfree = (free_func)0;
        zi->ci.stream.opaque = (voidpf)0;

        if (windowBits>0)
            windowBits = -windowBits;

        err = deflateInit2(&zi->ci.stream, level,
               Z_DEFLATED, windowBits, memLevel, strategy);

        if (err==Z_OK)
            zi->ci.stream_initialised = 1;
    }
#    ifndef NOCRYPT
    zi->ci.crypt_header_size = 0;
    if ((err==Z_OK) && (password != NULL))
    {
        unsigned char bufHead[DHBSDK_RAND_HEAD_LEN];
        unsigned int sizeHead;
        zi->ci.encrypt = 1;
        zi->ci.pcrc_32_tab = get_crc_table();
        /*dhbsdk_init_keys(password,zi->ci.keys,zi->ci.pcrc_32_tab);*/

        sizeHead=dhbsdk_crypthead(password,bufHead,DHBSDK_RAND_HEAD_LEN,zi->ci.keys,zi->ci.pcrc_32_tab,crcForCrypting);
        zi->ci.crypt_header_size = sizeHead;

        if (DHBSDK_ZWRITE(zi->z_filefunc,zi->filestream,bufHead,sizeHead) != sizeHead)
                err = ZIP_ERRNO;
    }
#    endif

    if (err==Z_OK)
        zi->in_opened_file_inzip = 1;
    return err;
}

extern int ZEXPORT dhbsdk_zipOpenNewFileInZip2(file, filename, zipfi,
                                        extrafield_local, size_extrafield_local,
                                        extrafield_global, size_extrafield_global,
                                        comment, method, level, raw)
    zipFile file;
    const char* filename;
    const dhbsdk_zip_fileinfo* zipfi;
    const void* extrafield_local;
    uInt size_extrafield_local;
    const void* extrafield_global;
    uInt size_extrafield_global;
    const char* comment;
    int method;
    int level;
    int raw;
{
    return dhbsdk_zipOpenNewFileInZip4 (file, filename, zipfi,
                                 extrafield_local, size_extrafield_local,
                                 extrafield_global, size_extrafield_global,
                                 comment, method, level, raw,
                                 -MAX_WBITS, DEF_MEM_LEVEL, Z_DEFAULT_STRATEGY,
                                 NULL, 0, VERSIONMADEBY, 0);
}

extern int ZEXPORT dhbsdk_zipOpenNewFileInZip3 (file, filename, zipfi,
                                         extrafield_local, size_extrafield_local,
                                         extrafield_global, size_extrafield_global,
                                         comment, method, level, raw,
                                         windowBits, memLevel, strategy,
                                         password, crcForCrypting)
    zipFile file;
    const char* filename;
    const dhbsdk_zip_fileinfo* zipfi;
    const void* extrafield_local;
    uInt size_extrafield_local;
    const void* extrafield_global;
    uInt size_extrafield_global;
    const char* comment;
    int method;
    int level;
    int raw;
    int windowBits;
    int memLevel;
    int strategy;
    const char* password;
    uLong crcForCrypting;
{
    return dhbsdk_zipOpenNewFileInZip4 (file, filename, zipfi,
                                 extrafield_local, size_extrafield_local,
                                 extrafield_global, size_extrafield_global,
                                 comment, method, level, raw,
                                 windowBits, memLevel, strategy,
                                 password, crcForCrypting, VERSIONMADEBY, 0);
}


extern int ZEXPORT dhbsdk_zipOpenNewFileInZip (file, filename, zipfi,
                                        extrafield_local, size_extrafield_local,
                                        extrafield_global, size_extrafield_global,
                                        comment, method, level)
    zipFile file;
    const char* filename;
    const dhbsdk_zip_fileinfo* zipfi;
    const void* extrafield_local;
    uInt size_extrafield_local;
    const void* extrafield_global;
    uInt size_extrafield_global;
    const char* comment;
    int method;
    int level;
{
    return dhbsdk_zipOpenNewFileInZip4 (file, filename, zipfi,
                                 extrafield_local, size_extrafield_local,
                                 extrafield_global, size_extrafield_global,
                                 comment, method, level, 0,
                                 -MAX_WBITS, DEF_MEM_LEVEL, Z_DEFAULT_STRATEGY,
                                 NULL, 0, VERSIONMADEBY, 0);
}

local int dhbsdk_zipFlushWriteBuffer(zi)
  dhbsdk_zip_internal* zi;
{
    int err=ZIP_OK;

    if (zi->ci.encrypt != 0)
    {
#ifndef NOCRYPT
        uInt i;
        int t;
        for (i=0;i<zi->ci.pos_in_buffered_data;i++)
            zi->ci.buffered_data[i] = dhbsdk_zencode(zi->ci.keys, zi->ci.pcrc_32_tab,
                                       zi->ci.buffered_data[i],t);
#endif
    }
    if (DHBSDK_ZWRITE(zi->z_filefunc,zi->filestream,zi->ci.buffered_data,zi->ci.pos_in_buffered_data)
                                                                    !=zi->ci.pos_in_buffered_data)
      err = ZIP_ERRNO;
    zi->ci.pos_in_buffered_data = 0;
    return err;
}

extern int ZEXPORT dhbsdk_zipWriteInFileInZip (file, buf, len)
    zipFile file;
    const void* buf;
    unsigned len;
{
    dhbsdk_zip_internal* zi;
    int err=ZIP_OK;

    if (file == NULL)
        return ZIP_PARAMERROR;
    zi = (dhbsdk_zip_internal*)file;

    if (zi->in_opened_file_inzip == 0)
        return ZIP_PARAMERROR;

    zi->ci.stream.next_in = (Bytef*)buf;
    zi->ci.stream.avail_in = len;
    zi->ci.crc32 = crc32(zi->ci.crc32,buf,(uInt)len);

    while ((err==ZIP_OK) && (zi->ci.stream.avail_in>0))
    {
        if (zi->ci.stream.avail_out == 0)
        {
            if (dhbsdk_zipFlushWriteBuffer(zi) == ZIP_ERRNO)
                err = ZIP_ERRNO;
            zi->ci.stream.avail_out = (uInt)Z_BUFSIZE;
            zi->ci.stream.next_out = zi->ci.buffered_data;
        }


        if(err != ZIP_OK)
            break;

        if ((zi->ci.method == Z_DEFLATED) && (!zi->ci.raw))
        {
            uLong uTotalOutBefore = zi->ci.stream.total_out;
            err=deflate(&zi->ci.stream,  Z_NO_FLUSH);
            zi->ci.pos_in_buffered_data += (uInt)(zi->ci.stream.total_out - uTotalOutBefore) ;

        }
        else
        {
            uInt copy_this,i;
            if (zi->ci.stream.avail_in < zi->ci.stream.avail_out)
                copy_this = zi->ci.stream.avail_in;
            else
                copy_this = zi->ci.stream.avail_out;
            for (i=0;i<copy_this;i++)
                *(((char*)zi->ci.stream.next_out)+i) =
                    *(((const char*)zi->ci.stream.next_in)+i);
            {
                zi->ci.stream.avail_in -= copy_this;
                zi->ci.stream.avail_out-= copy_this;
                zi->ci.stream.next_in+= copy_this;
                zi->ci.stream.next_out+= copy_this;
                zi->ci.stream.total_in+= copy_this;
                zi->ci.stream.total_out+= copy_this;
                zi->ci.pos_in_buffered_data += copy_this;
            }
        }
    }

    return err;
}

extern int ZEXPORT dhbsdk_zipCloseFileInZipRaw (file, uncompressed_size, crc32)
    zipFile file;
    uLong uncompressed_size;
    uLong crc32;
{
    dhbsdk_zip_internal* zi;
    uLong compressed_size;
    int err=ZIP_OK;

    if (file == NULL)
        return ZIP_PARAMERROR;
    zi = (dhbsdk_zip_internal*)file;

    if (zi->in_opened_file_inzip == 0)
        return ZIP_PARAMERROR;
    zi->ci.stream.avail_in = 0;

    if ((zi->ci.method == Z_DEFLATED) && (!zi->ci.raw))
        while (err==ZIP_OK)
    {
        uLong uTotalOutBefore;
        if (zi->ci.stream.avail_out == 0)
        {
            zi->ci.stream.avail_out = (uInt)Z_BUFSIZE;
            zi->ci.stream.next_out = zi->ci.buffered_data;
        }
        uTotalOutBefore = zi->ci.stream.total_out;
        err=deflate(&zi->ci.stream,  Z_FINISH);
        zi->ci.pos_in_buffered_data += (uInt)(zi->ci.stream.total_out - uTotalOutBefore) ;
    }

    if (err==Z_STREAM_END)
        err=ZIP_OK; /* this is normal */

    if ((zi->ci.pos_in_buffered_data>0) && (err==ZIP_OK))
        if (dhbsdk_zipFlushWriteBuffer(zi)==ZIP_ERRNO)
            err = ZIP_ERRNO;

    if ((zi->ci.method == Z_DEFLATED) && (!zi->ci.raw))
    {
        int tmp_err=deflateEnd(&zi->ci.stream);
        if (err == ZIP_OK)
            err = tmp_err;
        zi->ci.stream_initialised = 0;
    }

    if (!zi->ci.raw)
    {
        crc32 = (uLong)zi->ci.crc32;
        uncompressed_size = (uLong)zi->ci.stream.total_in;
    }
    compressed_size = (uLong)zi->ci.stream.total_out;
#    ifndef NOCRYPT
    compressed_size += zi->ci.crypt_header_size;
#    endif

    dhbsdk_ziplocal_putValue_inmemory(zi->ci.central_header+16,crc32,4); /*crc*/
    dhbsdk_ziplocal_putValue_inmemory(zi->ci.central_header+20,
                                compressed_size,4); /*compr size*/
    if (zi->ci.stream.data_type == Z_ASCII)
        dhbsdk_ziplocal_putValue_inmemory(zi->ci.central_header+36,(uLong)Z_ASCII,2);
    dhbsdk_ziplocal_putValue_inmemory(zi->ci.central_header+24,
                                uncompressed_size,4); /*uncompr size*/

    if (err==ZIP_OK)
        err = dhbsdk_add_data_in_datablock(&zi->central_dir,zi->ci.central_header,
                                       (uLong)zi->ci.size_centralheader);
    free(zi->ci.central_header);

    if (err==ZIP_OK)
    {
        long cur_pos_inzip = DHBSDK_ZTELL(zi->z_filefunc,zi->filestream);
        if (DHBSDK_ZSEEK(zi->z_filefunc,zi->filestream,
                  zi->ci.pos_local_header + 14,DHBSDK_ZLIB_FILEFUNC_SEEK_SET)!=0)
            err = ZIP_ERRNO;

        if (err==ZIP_OK)
            err = dhbsdk_ziplocal_putValue(&zi->z_filefunc,zi->filestream,crc32,4); /* crc 32, unknown */

        if (err==ZIP_OK) /* compressed size, unknown */
            err = dhbsdk_ziplocal_putValue(&zi->z_filefunc,zi->filestream,compressed_size,4);

        if (err==ZIP_OK) /* uncompressed size, unknown */
            err = dhbsdk_ziplocal_putValue(&zi->z_filefunc,zi->filestream,uncompressed_size,4);

        if (DHBSDK_ZSEEK(zi->z_filefunc,zi->filestream,
                  cur_pos_inzip,DHBSDK_ZLIB_FILEFUNC_SEEK_SET)!=0)
            err = ZIP_ERRNO;
    }

    zi->number_entry ++;
    zi->in_opened_file_inzip = 0;

    return err;
}

extern int ZEXPORT dhbsdk_zipCloseFileInZip (file)
    zipFile file;
{
    return dhbsdk_zipCloseFileInZipRaw (file,0,0);
}

extern int ZEXPORT dhbsdk_zipClose (file, global_comment)
    zipFile file;
    const char* global_comment;
{
    dhbsdk_zip_internal* zi;
    int err = 0;
    uLong size_centraldir = 0;
    uLong centraldir_pos_inzip;
    uInt size_global_comment;
    if (file == NULL)
        return ZIP_PARAMERROR;
    zi = (dhbsdk_zip_internal*)file;

    if (zi->in_opened_file_inzip == 1)
    {
        err = dhbsdk_zipCloseFileInZip (file);
    }

#ifndef NO_ADDFILEINEXISTINGZIP
    if (global_comment==NULL)
        global_comment = zi->globalcomment;
#endif
    if (global_comment==NULL)
        size_global_comment = 0;
    else
        size_global_comment = (uInt)strlen(global_comment);

    centraldir_pos_inzip = DHBSDK_ZTELL(zi->z_filefunc,zi->filestream);
    if (err==ZIP_OK)
    {
        dhbsdk_linkedlist_datablock_internal* ldi = zi->central_dir.first_block ;
        while (ldi!=NULL)
        {
            if ((err==ZIP_OK) && (ldi->filled_in_this_block>0))
                if (DHBSDK_ZWRITE(zi->z_filefunc,zi->filestream,
                           ldi->data,ldi->filled_in_this_block)
                              !=ldi->filled_in_this_block )
                    err = ZIP_ERRNO;

            size_centraldir += ldi->filled_in_this_block;
            ldi = ldi->next_datablock;
        }
    }
    dhbsdk_free_linkedlist(&(zi->central_dir));

    if (err==ZIP_OK) /* Magic End */
        err = dhbsdk_ziplocal_putValue(&zi->z_filefunc,zi->filestream,(uLong)ENDHEADERMAGIC,4);

    if (err==ZIP_OK) /* number of this disk */
        err = dhbsdk_ziplocal_putValue(&zi->z_filefunc,zi->filestream,(uLong)0,2);

    if (err==ZIP_OK) /* number of the disk with the start of the central directory */
        err = dhbsdk_ziplocal_putValue(&zi->z_filefunc,zi->filestream,(uLong)0,2);

    if (err==ZIP_OK) /* total number of entries in the central dir on this disk */
        err = dhbsdk_ziplocal_putValue(&zi->z_filefunc,zi->filestream,(uLong)zi->number_entry,2);

    if (err==ZIP_OK) /* total number of entries in the central dir */
        err = dhbsdk_ziplocal_putValue(&zi->z_filefunc,zi->filestream,(uLong)zi->number_entry,2);

    if (err==ZIP_OK) /* size of the central directory */
        err = dhbsdk_ziplocal_putValue(&zi->z_filefunc,zi->filestream,(uLong)size_centraldir,4);

    if (err==ZIP_OK) /* offset of start of central directory with respect to the
                            starting disk number */
        err = dhbsdk_ziplocal_putValue(&zi->z_filefunc,zi->filestream,
                                (uLong)(centraldir_pos_inzip - zi->add_position_when_writting_offset),4);

    if (err==ZIP_OK) /* zipfile comment length */
        err = dhbsdk_ziplocal_putValue(&zi->z_filefunc,zi->filestream,(uLong)size_global_comment,2);

    if ((err==ZIP_OK) && (size_global_comment>0))
        if (DHBSDK_ZWRITE(zi->z_filefunc,zi->filestream,
                   global_comment,size_global_comment) != size_global_comment)
                err = ZIP_ERRNO;

    if (DHBSDK_ZCLOSE(zi->z_filefunc,zi->filestream) != 0)
        if (err == ZIP_OK)
            err = ZIP_ERRNO;

#ifndef NO_ADDFILEINEXISTINGZIP
    TRYFREE(zi->globalcomment);
#endif
    TRYFREE(zi);

    return err;
}
