int x;
int d[7], i[7];

main(argc, argv)
char *argv[];
int  argc;
{
        for (x=0 ; x<=6 ; x++) {
                d[x] = (*argv[1]++)-'0';
                i[x] = 0;
        }
        do {
                for (x=0 ; x<=6 ; x++) {
                        printf("%c", "000111ABCDEFGHIJKLMNOPRSTUVWXY"
                                     [d[x]*3+i[x]]);
                }
                printf("   ");
                for (x=6 ; x>=0 ; x--) {
                        if (d[x]==0 || d[x]==1) continue;
                        if (++i[x]<=2) break;
                        i[x]=0;
                }
        } while (x!= -1);
}
