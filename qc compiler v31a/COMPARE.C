/********************************************************/
/* COMPARE.C - compare two files			*/
/*	adapted from "Software Tools" page 73		*/
/*	06/06/82: change to allow multiple mismatches	*/
/********************************************************/

#include <qstdio.h>

#define MAXLINE 132
main(argc,argv)
int argc, argv[];
	{
	register int lineno, m1, m2;
	register FILE *fp1, *fp2;
	static	diffcnt = 0,	/* difference count */
		diffmax = 1;	/* max number of differences */

	char line1[MAXLINE], line2[MAXLINE];
	if (argc < 3) {
		puts("usage: compare file1 file2 [+diffmax]");
		exit(1);
		}
	if (argc > 3)
		diffmax = atoi(argv[3]);
	if ((fp1 = fopen(argv[1], "r")) == NULL) {
		printf("can't open:%s\n", argv[1]);
		exit(1);
		}
	if ((fp2 = fopen(argv[2], "r")) == NULL) {
		printf("can't open:%s\n", argv[2]);
		exit(1);
		}
	lineno = 0;
	for (;;) {
		m1 = fgets(line1, MAXLINE, fp1);
		m2 = fgets(line2, MAXLINE, fp2);
		if (m1 == NULL || m2 == NULL)
			break;
		++lineno;
		if (strcmp(line1, line2)) {
			printf("%d:\n%s%s", lineno, line1, line2);
			if (++diffcnt >= diffmax)
				exit(0);
			}
		}
	if (m1 == NULL && m2 != NULL)
		printf("eof on %s\n", argv[1]);
	else if (m1 != NULL && m2 == NULL)
		printf("eof on %s\n", argv[2]);
	/* else they match */
	}
