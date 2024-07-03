#include "stdio.c"
#include "crunt2.c"
#include "alloc.c"

int arr[10][20];

main()
{
	register int i;
	int j;
	int * p;
	extern int *allocs;

	allocs = 0;

	for(j=0;j<20;++j)
		for(i=0;i<10;++i)
			arr[i][j] = -2;

	for(p=arr;p<=&arr[9][19];++p)
		*p = -1;

	for(i=0;i<10;++i)
		for(j=0;j<20;++j)
			arr[i][j] = (j<<8)|i;

	for(p=arr;p<=&arr[9][19];++p)
		if(*p==-1)
			puts("Bad array value\n");

	exec("samp3.com");
	puts("Can't exec samp3.com");
}
