/*
TITLE           read CPM format file from floppy dirve to standard output.
AUTHOR          Robert A. Van Valzah   7/31/80
LAST REVISOR    R. A. V.  04/03/80
DISCLAIMER      This code was hacked together quickly and is far from
                optimal.  Correctness has been tested, but is not
                guaranteed!
*/

#include <stdio.h>

#define OSTRKS 2

int fd;  /* floppy disk file descriptor */
int stt[26] = {                 /* sector translation (skew factor) table */
         1,  7, 13, 19,
        25,  5, 11, 17,
        23,  3,  9, 15,
        21,  2,  8, 14,
        20, 26,  6, 12,
        18, 24,  4, 10,
        16, 22
        };
struct FCB {
        char filetype;
        char name[8];
        char ext[3];
        char reel;
        char xx[2];
        char rcnt;
        char dm[16];
};
struct FCB dirbuf[4];
int dbi;        /* dirbuf index to desired file */
char buf[128];  /* disk data buffer */
int nr;         /* next record number to read */
struct FCB sfcb;

main(argc, argv)
int argc;
char *argv[];
{
int i, rs;
char *sp, *dp;  /* source and destination pointers */

        if (argc!=2) {
                printf("Usage:  %s CPMfilename\n", argv[0]);
                exit(1);
        }
        fd=open("/dev/floppy",0);
        argv++;
        strcpy(sfcb.name, "           ");
        sp = *argv;
        dp = sfcb.name;
        while (*sp && *sp!='.') {       /* pack name into sfcb */
                *dp++ = *sp<'a' ? *sp++ : (*sp++)-040 ;
        }
        if (*sp++ == '.') {             /* pack in ext if present */
                dp = sfcb.ext;
                while (*sp) {
                        *dp++ = *sp<'a' ? *sp++ : (*sp++)-040 ;
                }
        }
        sfcb.reel = 0;
        cpmOpen(sfcb);
        if (dbi==-1) {
                printf("not found\n");
                exit (1);
        }
        rs = -1;
        while (rs) {
                rs = cpmRead(buf);
                if (rs)
                        for (i=0 ; i<=127 ; i++) {
                                if (buf[i]==26) exi t(0);
                                if (buf[i]==13) continue;
                                putchar(buf[i]);
                        }
        }
}

/* simulate CPM read buffer call */
cpmRead(buf)
char *buf;
{
int dmap;
        dmap = dirbuf[dbi].dm[nr/8];
        if (dmap<0) dmap += 256;        /***HACK to get around sign extention */
        if (dmap) {
                rdsec(dmap, nr%8, buf);
                nr++;
                if (nr == 128) {
                        nr = 0;
                        sfcb.reel++;
                        cpmOpen(sfcb);
                }
                return (-1);
        } else {
                return (0);
        }
}

/* simulate CPM open file function */
cpmOpen(sfcb)
struct FCB sfcb;
{
int grp, rec;
        nr = 0;
        for (grp=0 ; grp<2 ; grp++) {
                for (rec=0 ; rec <8 ; rec++) {
                        rdsec(grp, rec, dirbuf);
                        srchSec(sfcb);
                        if (dbi!=-1) {
                                return;
                        }
                }
        }
        return;
}

srchSec(sfcb)
struct FCB sfcb;
{
        for (dbi=0 ; dbi<=3 ; dbi++) {
                if  (srchFcb(sfcb, dirbuf[dbi]) == 0) {
                        return;
                }
        }
        dbi = -1;
        return;
}

srchFcb(sfcb, fcb)
struct FCB sfcb, fcb;
{
int i;
        if (fcb.filetype==0) {
                for (i=0 ; i<=11 ; i++)         /* match name and reel */
                        if (fcb.name[i]!=sfcb.name[i])
                                return (-1);
                return (0);
        } else
                return (-1);
}

rdsec(group, rec, buf)
int group, rec;
char *buf;
{
int offset, voffset, sec, trk;
        voffset = group*8+rec;
        sec = stt[voffset % 26];
        trk = voffset / 26 + OSTRKS;
        offset = (trk*26+sec-1)*128;
        lseek(fd, offset, 0);
        read(fd, buf, 128);
}
