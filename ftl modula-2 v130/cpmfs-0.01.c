/*
  cpmfs.c Copyright 2017 Greg Sydney-Smith

  2017-10-30. gss. Initial version.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:

  1. Redistributions of source code must retain the above copyright notice,
     this list of conditions and the following disclaimer.

  2. Redistributions in binary form must reproduce the above copyright notice,
     this list of conditions and the following disclaimer in the documentation
     and/or other materials provided with the distribution.

  THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
  INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
  FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
  DEVELOPERS AND CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
  OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define toupper(c) (('a'<=c && c<='z')? c+'A'-'a' : c)

typedef struct {
    int tracks;
    int sectors;
    int secsize;
    int rsvd;   // system tracks
    int spb;    // sectors per block i.e block size
    int dir;    // dir size in blocks
    int skew;   // skew factor 6 -> 1,7,
    int *trans; // translate table lsn -> phys
    }  DSKFMT;

typedef unsigned char byte;


char *trim(char *s) {
    int i;

    for (i=strlen(s)-1; i>=0; i--)
        if (s[i]==' ')
            s[i]='\0';
    return s;
}

int sayhex(int n, char *s) {    // for debugging
    int i, j;
    char *hex = "0123456789ABCDEF";

    for (i=0; i<n; i+=16) {
        for (j=0; j<16 && i+j<n; j++)
            printf("%c%c ",hex[(s[i+j] & 0xF0)>>4],hex[s[i+j] & 0x0F]);
        for (; j<16; j++) printf("   ");
        for (j=0; j<16 && i+j<n; j++)
            printf("%c",(' '<=s[i+j] && s[i+j]<='~')? s[i+j] : '.');
        printf("\n");
    }
    return 0;
}

int type8sssd(DSKFMT *d) {  // standard cpm 8" disk type
    int i;
    int trans[] = {
         1, 7,13,19, 25, 5,11,17, 23, 3, 9,15, 21, 2, 8,14, // sectors 1-16
        20,26, 6,12, 18,24, 4,10, 16,22 };                  // sectors 17-26

    d->tracks = 77;
    d->sectors = 26;
    d->secsize = 128;
    d->rsvd = 2;
    d->spb = 8;  // 1K blocks
    d->dir = 1;  // 8x4 = 32 directory entries
    d->skew = 6;
    d->trans= (int *)malloc(d->sectors*sizeof(int));
    for (i=0; i<d->sectors; i++) {
        d->trans[i]= trans[i]; // (i*6)%d->sectors;  // skew of 6
    }
    return 0;
}

///////

int _fsmake(DSKFMT *d, char *imgfn) {
    FILE *fp;
    int i, j;
    char *buf;

    if ((fp=fopen(imgfn,"w"))==NULL) {
        printf("Error: can't write to %s\n",imgfn);
        return 1;
    }

    buf= malloc(d->secsize);
    for (i=0; i<d->secsize; i++) buf[i]= 0xE5;
    for (i=0; i<d->tracks; i++) {
        for (j=0; j<d->sectors; j++) {
            fwrite(buf,d->secsize,1,fp);
        }
    }
    free(buf);

    printf("OK.\n");
    return 0;
}

///////

int _fsReadLSN(DSKFMT *d, FILE *imgfp, int lsn, char *buf) {
    int track, sector, phys;
    long offs;  // offset from start of disk / image

    track  = lsn / d->sectors; // eg 0..76
    sector = lsn - (track * d->sectors); // eg 0..25

    phys   = sector; // no sector translation / skew
    if (track >= d->rsvd) phys= d->trans[sector] - 1; // skewed

    offs= ((track * d->sectors) + phys) * d->secsize;

    if (fseek(imgfp,offs,SEEK_SET) != 0) {
        printf("Error: Seeking Track %d Sector %d\n",track,1+phys);
        return 1;
    }

    if (fread(buf,d->secsize,1,imgfp) != 1) {
        printf("Error: Reading Track %d Sector %d\n",track,1+phys);
        return 1;
    }
    return 0;
}

int _fsWriteLSN(DSKFMT *d, FILE *imgfp, int lsn, char *buf) {
    int track, sector, phys;
    long offs;  // offset from start of disk / image
    
    track  = lsn / d->sectors; // eg 0..76
    sector = lsn - (track * d->sectors); // eg 0..25

    phys   = sector; // no sector translation / skew
    if (track >= d->rsvd) phys= d->trans[sector] - 1; // skewed
    
    offs= ((track * d->sectors) + phys) * d->secsize;

    if (fseek(imgfp,offs,SEEK_SET) != 0) {
        printf("Error: Seeking Track %d Sector %d\n",track,1+phys);
        return 1;
    }

    if (fwrite(buf,d->secsize,1,imgfp) != 1) {
        printf("Error: Writing Track %d Sector %d\n",track,1+phys);
        return 1;
    }
    return 0;
}

int _fsReadBlock(DSKFMT *d, FILE *imgfp, int bno, char *buf) {
    int lsn, i;

    lsn= (d->rsvd * d->sectors) + (bno * d->spb);
    for (i=0; i<d->spb; i++)
        if (_fsReadLSN(d,imgfp,lsn+i,buf+(i*d->secsize)) != 0)
            return 1;
    return 0;
}

int _fsWriteBlock(DSKFMT *d, FILE *imgfp, int bno, char *buf) {
    int lsn, i;

    lsn= (d->rsvd * d->sectors) + (bno * d->spb);
    for (i=0; i<d->spb; i++)
        if (_fsWriteLSN(d,imgfp,lsn+i,buf+(i*d->secsize)) != 0)
            return 1;
    return 0;
}

char *_fsReadDir(DSKFMT *d, FILE *imgfp) {
    char *buf;
    int blocksize, i;

    blocksize= d->spb * d->secsize;
    if ((buf = malloc(d->dir * blocksize)) == NULL) {
        printf("Error: can't allocate memory for the directory\n");
        return NULL;
    }

    for (i=0; i<d->dir; i++) // for each directory block
        if (_fsReadBlock(d,imgfp, i, buf+(i*blocksize)) != 0)
            return NULL;

    return buf;
}

int _fsWriteDir(DSKFMT *d, FILE *imgfp, char *buf) {
    int blocksize, i;

    blocksize= d->spb * d->secsize;
    for (i=0; i<d->dir; i++) // for each directory block
        if (_fsWriteBlock(d,imgfp, i, buf+(i*blocksize)) != 0)
            return 1;

    return 0;
}

int _toCpmFn(char *fn, char *fn2) { // convert win fn to CP/M FCB format
    int i, j;

    for (i=0; i<11; i++) fn2[i]=' ';            // fill with spaces
    for (i=0; i<8 && fn[i] && fn[i]!='.'; i++)  // copy 8 chars
        fn2[  i]= toupper(fn[i  ]);
    while (fn[i] && fn[i]!='.') i++;            // find '.' if present
    if (fn[i]=='.') i++;                        // move past it
    for (j=0; j<3 && fn[i+j]; j++)              // copy 3 chars
        fn2[8+j]= toupper(fn[i+j]);
    return 0;
}

int _fsFindBlocksInFile(DSKFMT *d, char *dir, char *cpmfn, int *blocks) {
    int fcbs, i, j, blocksize, extent;
    char *buf, *fcb, fnext[8+3+1];

    // 1. set blocks to 0
    for (i=0; i<256; i++) blocks[i]=0;

    // 2. filename to FCB style
    _toCpmFn(cpmfn,fnext); fnext[11]='\0';

    // 3. search through directory to find file blocks
    fcbs= d->dir * d->spb * d->secsize / 0x20; // number of directory entries
    for (i=0, fcb=dir; i<fcbs; fcb+=0x20, i++) {
        if ((fcb[0]==0x00) && strncmp(fcb+1,fnext,11)==0) { // match, not deleted
            extent= fcb[12]&0xFF;
            if (extent>15) { printf("Error: too big\n"); return 1; } // should never happen
            for (j=0; j<16; j++) blocks[16*extent+j]= fcb[0x10+j]&0xFF;
        }
    }
    return 0;
}

int _fsFindBlocksInUse(DSKFMT *d, char *dir, int *blocks) {
    int blocksize, fcbs, i, recs, nblocks, j, bno;
    char *buf, *fcb, fnext[8+3+1];

    // 1. set blocks to 0
    for (i=0; i<256; i++) blocks[i]=0;

    // 2. set directory blocks in use
    for (i=0; i<d->dir; i++) blocks[i]=1;

    // 3. search through directory to find other blocks in use
    blocksize = d->spb;                    // in records
    fcbs= d->dir * d->spb * d->secsize / 0x20; // number of directory entries
    for (i=0, fcb=dir; i<fcbs; fcb+=0x20, i++) {
        if ((fcb[0]&0xFF) == 0xE5) continue; // deleted. skip this one
        recs   = fcb[0x0F]&0xFF;
        nblocks= (recs+blocksize-1)/blocksize; // rounded up
        for (j=0; j<nblocks; j++) {
            bno= fcb[0x10+j]&0xFF;
            blocks[bno] += 1;         // >1 is cross linked s/where - fs error
        }
    }
    return 0;
}

int _fsFindFilesize(DSKFMT *d, char *dir, char *cpmfn) {
    int fcbs, recs, i, extent, rc, n;
    char *fcb, fnext[8+3+1];

    // 1. filename to FCB style
    _toCpmFn(cpmfn,fnext); fnext[11]='\0';

    // 2. search through directory to find file extents and sizes
    recs= -1;
    fcbs= d->dir * d->spb * d->secsize / 0x20; // number of directory entries
    for (i=0, fcb=dir; i<fcbs; fcb+=0x20, i++) {
        if ((fcb[0]==0x00) && strncmp(fcb+1,fnext,11)==0) { // match, not deleted
            extent= fcb[0x0C]&0xFF; // extent number
            rc    = fcb[0x0F]&0xFF; // record count in the extent. eg 80H for full 16K 
            // given we're this many extents in, and have this many records here
            // we think the filesize is ...
            n= extent*16*d->spb + rc; 
            if (n>recs) recs=n;
        }
    }
    return recs;
}

int _fsEra(DSKFMT *d, char *dir, char *cpmfn) { // common bit used by ERA and W
    int err, fcbs, i;
    char fnext[8+3+1], *fcb;

    // 2. filename to FCB style
    _toCpmFn(cpmfn,fnext); fnext[11]='\0';

    // 3. for each entry, if it matches, mark as deleted
    err=1;
    fcbs= d->dir * d->spb * d->secsize / 0x20; // number of directory entries
    for (i=0, fcb=dir; i<fcbs; fcb+=0x20, i++) {
        if ((fcb[0]==0x00) && strncmp(fcb+1,fnext,11)==0) { // match, not deleted
            fcb[0]= 0xE5;
            err= 0;
        }
    }
    return err; // 0 if no error, 1 if not found
}

char *_CreateExtent(DSKFMT *d, char *dir, char *cpmfn, int eno) {
    int fcbs, i;
    char fnext[8+3+1], *fcb;
    
    // 1. find a free slot
    fcbs= d->dir * d->spb * d->secsize / 0x20; // number of directory entries
    for (i=0, fcb=dir; i<fcbs; fcb+=0x20, i++)
        if ((fcb[0]&0xFF) == 0xE5)
            break;
    if (i>=fcbs) { printf("Error: directory full\n"); return NULL; }
    
    // 2. fill in the FCB
    _toCpmFn(cpmfn,fnext); fnext[11]='\0';
    for (i=0; i<0x20; i++) fcb[i]=0;    // no blocks alloc'd, no recs, no flags ...
    strncpy(fcb+1,fnext,11);    // add file name and extension
    fcb[12]= eno;               // add extension number (might be 0)

    return fcb;
}

int _GetFreeBlock(int *blocks) {
    int i;

    for (i=0; i<256; i++) // dir blocks should already be marked as in use
        if (blocks[i]==0) {
            blocks[i]=1; // mark as now allocated
            return i;
        }
    printf("Error: no free space\n");
    return -1;
}


//////

int fsMake(DSKFMT *d, char *imgfn) {
    FILE *fp;

    if ((fp=fopen(imgfn,"r"))!=NULL) {
      fclose(fp);
      printf("Error: %s already exists\n",imgfn);
      return 1;
    }

    return _fsmake(d,imgfn);
}

int fsInit(DSKFMT *d, char *imgfn) {
    FILE *fp;

    if ((fp=fopen(imgfn,"r"))==NULL) {
      printf("Error: can't find %s\n",imgfn);
      return 1;
    }
    fclose(fp);

     // All files will be erased. Continue (Y/N)?
    return _fsmake(d,imgfn);
}

int fsReadSys(DSKFMT *d, char *imgfn, char *winfn) {
    FILE *fp, *fpout;
    int i, j;
    char *buf;

    // 0. Open disk image
    if ((fp=fopen(imgfn,"rb"))==NULL) {
        printf("Error: can't find %s\n",imgfn);
        return 1;
    }

    if ((fpout=fopen(winfn,"wb"))==NULL) {
        printf("Error: can't create %s\n",winfn);
        return 1;
    }

    buf= malloc(d->secsize);
    for (i=0; i<d->rsvd; i++) {
        for (j=0; j<d->sectors; j++) {
            if (fread( buf,d->secsize,1,fp) != 1) {
                printf("Error: Reading Track %d Sector %d\n",i,1+j);
                return 1;
            }
            fwrite(buf,d->secsize,1,fpout);
        }
    }
    free(buf);
    fclose(fpout);
    fclose(fp);

    printf("OK.\n");
    return 0;
}

int fsWriteSys(DSKFMT *d, char *imgfn, char *winfn) {
    FILE *fp, *fpin;
    int i, j;
    char *buf;

    // 0. Open disk image
    if ((fp=fopen(imgfn,"r+b"))==NULL) {
        printf("Error: can't find %s\n",imgfn);
        return 1;
    }

    if ((fpin =fopen(winfn,"rb"))==NULL) {
        printf("Error: can't find %s\n",winfn);
        return 1;
    }

    buf= malloc(d->secsize);
    for (i=0; i<d->rsvd; i++) {
        for (j=0; j<d->sectors; j++) {
            if (fread( buf,d->secsize,1,fpin) != 1) {
                printf("Error: Reading Track %d Sector %d\n",i,1+j);
                return 1;
            }
            fwrite(buf,d->secsize,1,fp);
        }
    }
    free(buf);
    fclose(fpin);
    fclose(fp);

    printf("OK.\n");
    return 0;
}

int fsDir(DSKFMT *d, char *imgfn) {
    FILE *fp;
    int fcbs, i;
    char *buf, *fcb, fn[8+1], ext[3+1];

    // 0. Open disk image
    if ((fp=fopen(imgfn,"rb"))==NULL) {
        printf("Error: can't find %s\n",imgfn);
        return 1;
    }

    // 1. read entire directory in
    if ((buf = _fsReadDir(d,fp)) == NULL) return 1;

    // 2. for each entry, print
    fcbs= d->dir * d->spb * d->secsize / 0x20; // number of directory entries
    for (i=0, fcb=buf; i<fcbs; fcb+=0x20, i++) {
        if ((fcb[0]==0x00) && (fcb[12]==0)) { // normal file, extent 0
            strncpy(fn ,fcb+1,8); fn[ 8]='\0'; trim(fn);
            strncpy(ext,fcb+9,3); ext[3]='\0'; trim(ext);
            printf("%s.%s\n",fn,ext);
        }
    }
    
    fclose(fp);
    return 0;
}

int fsEra(DSKFMT *d, char *imgfn, char *cpmfn) {
    FILE *fp;
    char *dir;

    // 0. Open disk image
    if ((fp=fopen(imgfn,"r+b"))==NULL) {
        printf("Error: can't find %s\n",imgfn);
        return 1;
    }

    // 1. read entire directory in
    if ((dir = _fsReadDir(d,fp)) == NULL) return 1;

    // 2. delete all user 0, non-sys/ro file extents matching this name
    if (_fsEra(d,dir,cpmfn) != 0) {
        printf("Error: file not found\n");
        return 1;
    }
    
    // 3. write entire directory back out
    if (_fsWriteDir(d,fp,dir) != 0) return 1;

    free(dir); fclose(fp);
    printf("OK.\n");
    return 0;
}

int fsRead(DSKFMT *d, char *imgfn, char *cpmfn, char *winfn) {
    FILE *fp, *outfp;
    char *buf, *buf2;
    int blocks[256], recs, blocksize, nblocks, n, i, j;

    // 0. Open disk image
    if ((fp=fopen(imgfn,"rb"))==NULL) {
        printf("Error: can't find %s\n",imgfn);
        return 1;
    }

    // 1. read entire directory in
    if ((buf = _fsReadDir(d,fp)) == NULL) return 1;

    // 2. find blocks in file
    if (_fsFindBlocksInFile(d,buf,cpmfn,blocks) != 0) return 1;

    // 3. find size
    if ((recs= _fsFindFilesize(d,buf,cpmfn)) < 0) {
        printf("Error: file not found\n");
        return 1;
    }

    blocksize = d->spb;                    // in records
    nblocks= (recs+blocksize-1)/blocksize; // rounded up

    // 4. write to out file
    buf2= malloc(blocksize*d->secsize);
    if ((outfp=fopen(winfn,"wb"))==NULL) {
        printf("Error: can't create %s\n",winfn);
        return 1;
    }
    for (n=0, i=0; i<nblocks; i++) {
        if (_fsReadBlock(d,fp,blocks[i],buf2) != 0) return 1;
        for (j=0; j<blocksize && n<recs; j++, n++)
            fwrite(buf2+j*d->secsize,d->secsize,1,outfp);
    }

    fclose(outfp);
    printf("OK.\n");
    return 0;
}

int fsWrite(DSKFMT *d, char *imgfn, char *cpmfn, char *winfn) {
    FILE *fp, *fp2;
    char *dir, *buf, *fcb;
    int blocks[256], dataarea, blocksize, eno, nrecs, i, j, bno, lsn, n;

    // 0. Open disk image
    if ((fp=fopen(imgfn,"r+b"))==NULL) {
        printf("Error: can't find %s\n",imgfn);
        return 1;
    }

    // 1. open input file
    if ((fp2=fopen(winfn,"rb"))==NULL) {
        printf("Error: can't find %s\n",winfn);
        return 1;
    }

    // 2. read entire directory in
    if ((dir = _fsReadDir(d,fp)) == NULL) return 1;

    // 3. delete all user 0 file extents matching this name
    _fsEra(d,dir,cpmfn); // continue after deleted or if none

    // 4. find all blocks in use
    if (_fsFindBlocksInUse(d,dir,blocks) != 0) return 1;

    // 5. create extents as needed
    buf= malloc(d->secsize);
    dataarea = d->rsvd * d->sectors; // in records
    blocksize= d->spb;               // in records
    for (eno=0; eno<16 && !feof(fp2); eno++) { // eno= extent number
        if ((fcb= _CreateExtent(d,dir,cpmfn,eno)) == NULL) return 1;
        for (nrecs=0, i=0; i<16 && !feof(fp2); i++) {
            if ((bno= _GetFreeBlock(blocks)) < 0) return 1; 
            fcb[0x10+i]= bno; // add it to this extent 
            lsn= dataarea + bno*blocksize;
            for (j=0; j<blocksize && !feof(fp2); j++, nrecs++, lsn++) {
                if ((n=fread(buf,1,d->secsize,fp2)) == 0) break;
                while (n<d->secsize) buf[n++]=0x1A; // pad record out with 0x1A
                if (_fsWriteLSN(d,fp,lsn,buf) != 0) return 1; // write record
            }
        }
        fcb[0x0F]= nrecs;
    }

    // 6. write entire dir
    if (_fsWriteDir(d,fp,dir) != 0) return 1;

    free(buf); free(dir); fclose(fp2); fclose(fp);
    printf("OK.\n");
    return 0;
}

void Usage(void) {
    printf("\n");
    printf("CP/M File System Utility Ver 0.01\n");
    printf("Copyright 2017 Sydneysmith.com\n\n");
    printf("Usage: cpmfs [-t type] imagefile cmd [fn1 [fn2]]\n");
    printf("cmd: make        : create imagefile\n");
    printf("     init        : reset  imagefile to empty\n");
    printf("     rsys fn1    : read   system tracks -> win fn1\n");
    printf("     wsys fn1    : write  system tracks <- win fn1\n");
    printf("     dir         : list   cpm files in imagefile\n");
    printf("     era fn1     : erase  cpm file fn1\n");
    printf("     r fn1 [fn2] : read   cpm fn1 -> win fn2\n");
    printf("     w fn1 [fn2] : write  cpm fn1 <- win fn2\n");
    printf("Default fn2 is same name as fn1\n");
}

int main(int argc, char *argv[]) {
    int i;
    DSKFMT d;
    char *cmds[] = {
        "make", "init", "rsys", "wsys", "dir", "era", "r", "w", NULL };
    
    type8sssd(&d);
    if (argc>2 && strcmp(argv[1],"-t")==0) {
        ; // change type
        argc-=2;
        argv+=2;
    }
    
//printf("argc=%d\n",argc);
    if (argc<3) { Usage(); return 1; }
    for (i=0; cmds[i]!=NULL && stricmp(argv[2],cmds[i])!=0; i++) ;
    switch (i) {
    case  0: if (argc==3) return fsMake(    &d,argv[1]); break;
    case  1: if (argc==3) return fsInit(    &d,argv[1]); break;
    case  2: if (argc==4) return fsReadSys( &d,argv[1],argv[3]); break;
    case  3: if (argc==4) return fsWriteSys(&d,argv[1],argv[3]); break;
    case  4: if (argc==3) return fsDir(     &d,argv[1]); break;
    case  5: if (argc==4) return fsEra(     &d,argv[1],argv[3]); break;
    case  6: if (argc==5) return fsRead(    &d,argv[1],argv[3],argv[4]);
             if (argc==4) return fsRead(    &d,argv[1],argv[3],argv[3]);
             break;
    case  7: if (argc==5) return fsWrite(   &d,argv[1],argv[3],argv[4]);
             if (argc==4) return fsWrite(   &d,argv[1],argv[3],argv[3]);
             break;
    }
    
    Usage();
    return 1;
}

