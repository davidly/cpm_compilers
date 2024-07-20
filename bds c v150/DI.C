/*
	DI.C

	Find simple differences between two binary or text files.
	Written by Leor Zolman. This command is useful for quick comparisons,
	as to determine whether two files are identical, or else to find the
	first area of divergence.

	The addresses printed for binary files assumes they are being examined
	using DDT or SID (i.e., offset by 100h from the start of the file.)

	Usage: 
		di <file1> <file2> [-a]
	  or	di <file1> { <user#/> or <d:> or <user#/d:> } [-a]

	The second form allows for omission of the second filename if is to be
	identical to the first.

	(use -a for ASCII files; else binary assumed)

	Compile by:
		cc di.c -e2000 -o
		clink di -n
*/

#include <bdscio.h>

int i, j;
char ascii;
unsigned count;
unsigned lineno;
char buf1[BUFSIZ], buf2[BUFSIZ];
char nam2[20];
char perfect;

main(argc,argv)
char **argv;
{
	if (argc < 3) {
	   printf("Usage:\tdi file1 file2 [-a]\n");
	   printf("or:\tdi file1 { <user#/> or <d:> or <user#/d:> } [-a]\n");
	   exit();
	}

	if (fopen(argv[1],buf1) == ERROR) {
		printf("Can't open %s\n",argv[1]);
		exit();
	}

	strcpy(nam2,argv[2]);		/* construct second filename */
	if ((j = nam2[strlen(nam2)-1]) == ':' || j == '/')
	{
		for (i = strlen(argv[1])-1; i >= 0; i--)
			if (argv[i][i] == '/' || argv[1][i] == ':')
				break;
		strcat(nam2, &argv[1][i+1]);
	}


	if (fopen(nam2,buf2) == ERROR) {
		printf("Can't open %s\n",nam2);
		exit();
	}

	printf("Comparing %s to %s:\n",argv[1],nam2);

	lineno = 1;
	ascii = 0;
	perfect = TRUE;
	if (argc > 3 && argv[3][1] == 'A') ascii++;

	for (count = 0x100 ; ; count++) {
		if (kbhit())		/* flow control */
			getchar();

		i = getc(buf1);
		if (i == '\n') lineno++;
		if (i == EOF || (ascii && i == CPMEOF)) {
			j = getc(buf2);			 /* first file ended */
			if (j == EOF || (ascii && j == CPMEOF)) { /* did 2nd?*/
				if (perfect)
					printf("Perfect match!\n");   /* yes */
				exit();
			 } else {				       /* no */
				printf("%s ends at %04x",argv[1],count);
				if (ascii) printf(" [line %d]",lineno);
				printf(", but %s goes on...\n",nam2);
				exit();
			}
		} else {			     /* 1st file didn't end  */
			j = getc(buf2);
			if (j == EOF || (ascii && j == CPMEOF)) { /* did 2nd?*/
				printf("%s ends at %04x",nam2,count);
				if (ascii) printf(" [line %d]",lineno);
				printf(", but %s goes on...\n",argv[1]);
				exit();
			} else if (i != j) {
				printf("Mismatch at location %04x",count);
				if (ascii) printf(" [line %d]",lineno);
				putchar('\n');
				perfect = FALSE;
			}
		}
	}
}
