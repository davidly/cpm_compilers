#include "crunt2.c"
#include "func.c"

#define COL 6

main()
{

	int n,i,j,space;
	int aa[30],bb[30];
	char instr[80];

	puts("\n\nSample program #4 : Constructs Pascal's triangle\n");

	do {
		puts("Enter a number < 15 : ");
		gets(instr);
		n=atoi(instr);
	
	} while (n<0 || n>15);
	puts("\n");

	space = n*COL/2;
	aa[0]=0; aa[1]=1;
	for(j=1;j<=n;++j) {
		space=space-COL/2;
		for(i=0;i<=space;++i) putchar(' ');
		for(i=1;i<=j;++i) {
			bb[i]=aa[i-1]+aa[i];
		}
		aa[j+1]=0;
		for(i=1;i<=j;++i) {
			print(bb[i],COL);
			aa[i]=bb[i];
		}
		puts("\n");
	}
}




print(num,ic)
 int num,ic;
{
	int i,j;

	j=num;
	i=0;
	do {
		i=i+1;
		j=j/10;
	} while(j!=0);

	if(i>ic)
		for(i=1;i<=ic;++i) putchar('*');
	else
		for(j=1;j<=ic-i;++j) putchar(' ');
	putdec(num);
}
num,bc,de)	/* This version of bios() recognizes that SELDSKŠ			 * and S