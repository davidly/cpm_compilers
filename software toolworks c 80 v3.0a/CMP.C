/* cmp - compare two files */

#include printf.c

main(argc,argv)
int argc; char *argv[];
{	static int f1,f2,c,d;
	static int line = 1, block = 0, lflag = 0, charn = -1;

	if (argv[1][0] == '-' && (argv[1][1] == 'l' || argv[1][1] == 'L')) {
		lflag++; argc--; argv++; }
	if (argc != 3) {
		printf("Usage: cmp [-l] file1 file2\n"); 
		exit(); }
	f1 = file(argv[1]);
	f2 = file(argv[2]);
	while (1) {
		if (++charn == 256) { block++ ;charn = 0; }
		c = getc(f1); d = getc(f2);
		if (c == '\n') line++;
		if (c == d) {
			if (c < 0) {
				if (lflag <= 1) 
					printf("Files are identical.\n");
				exit(); }
			continue; }
		if (c < 0) {printf("%s is shorter.\n",argv[1]); exit(); }
		if (d < 0) {printf("%s is shorter.\n",argv[2]); exit(); }
		if (lflag) {
			printf("%s char %d block %d line %d = %3o; %s = %3o\n",
				argv[1],charn,block,line,c,argv[2],d);
			lflag = 2;
			continue; }
		printf("Files differ at character %d, block %d, line %d.\n",
							      charn,block,line);
		exit(); }
}

file(fname)
char *fname;
{	int i;
	i = fopen(fname,"rb");
	if (i > 0) return i;
	printf("Can't open: %s\n",fname);
	exit();
}
