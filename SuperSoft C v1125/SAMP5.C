#include "stdio.c"
#include "alloc.c"
#include "crunt2.c"

extern	int	*allocs;

main()
{

	char filename[14];
	int mode;
	int fd;
	int rec;
	char ch, instr[80];
	char buffer[129];

	allocs=0;
	puts("Enter filename : "); gets(filename);
	puts("\n");
	if((fd=open(filename,2))==-1)
	{
		 puts("\ncannot open file: ");
		puts(filename);
		puts("\n");
		exit(0);
	}
	for(;;) {
		puts("Enter record# (-1 to exit): ");
		gets(instr);
		puts("\n");
		rec=atoi(instr);
		if(rec==-1) break;
		if(seek(fd, rec * 128, 0)==-1) {
			puts("record out of range\n\n");
		}
		else
		{
			read(fd,buffer,128);
			buffer[128]=0;
			puts(buffer);
			puts("\n\n");
		}
	}
}

atoi(n)
char *n;
{
	register int val; 
	char c;
	int sign;

	while(iswhite(*n))
		++n;

	switch(*n) {
	case '-':
		sign = 1;
		++n;
		break;
	case '+':
		++n;
	default:
		sign = 0;
	}

	for(val=0; isdigit(c = *n++);)
		val = val*10 + c - '0';

	return sign? -val: val;
}





