#define OSTRKS 2

int fd;  /* floppy disk file descriptor */
int stt[26] = {
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

main()
{
        fd=open("/dev/floppy",0);
        cpmDir();
}

cpmDir()
{
int grp, rec;
        for (grp=0 ; grp<2 ; grp++) {
                for (rec=0 ; rec <8 ; rec++) {
                        rdsec(grp, rec, dirbuf);
                        printsec();
                }
        }
}

printsec()
{
int i;
        for (i=0 ; i<=3 ; i++) {
                printfn(dirbuf[i]);
        }
}

printfn(fcb)
struct FCB fcb;
{
int i;
        if (fcb.filetype==0) {
                for (i=0 ; i<=10 ; i++)
                        printf("%c", fcb.name[i]);
                printf("\n");
        }
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
