
/* 
	This program is a simple example of how to use
	Bob Mathias's floating point package. To compile it,
	first compile (but do not link) both this file
	and FPFUNCS.C.
	Then, give the CLINK command:

	A>clink floatsum fpfuncs float <cr>

	and run the thing by saying:

	A>floatsum
*/

main()
{
	char s1[5], s2[5], s3[5];
	char string[30];
	char sb[30];
	int i;
	atof(s1,"0");
	while (1) {
		printf("sum = ");
		puts(ftoa(sb, s1));
		printf("\nEnter a floating number: ");
		fpadd(s3,s1,atof(s2,gets(string)));
		for (i=0; i<5; i++) s1[i] = s3[i];
	}
}

