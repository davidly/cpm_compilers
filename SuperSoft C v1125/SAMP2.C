#include "crunt2.c"

main()
{
	register int t;
	char	q;
	int	r;
	int	count;

	puts("\n\nSample program #2 : execution speed of variable types\n");
	puts("\n\nThis program will illustrate the speed differences\n");
	puts("between types register, char and int. Nested for loops\n");
	puts("each counting to 255 will be executed.\n");
	puts("In each case, the outer loop is controlled by\n");
	puts("type int and the inside loop is the type under study\n");
	puts("You should time each loop. (type register is quite fast)\n\n");
	puts("Hit return to start register loop: ");
	getchar();
	putchar(7); putchar('*');
	for(count=0;count<255;++count) 
		for(t=0;t<255;++t);
	putchar(7);putchar('*');

	puts("\nHit return to start char loop: ");
	getchar();
	putchar(7);putchar('*');
	for(count=0;count<255;++count) 
		for(q=0;q<255;++q);
	putchar(7);putchar('*');

	puts("\nHit return to start int loop: ");
	getchar();
	putchar(7);putchar('*');
	for(count=0;count<255;++count) 
		for(r=0;r<255;++r);
	putchar(7);putchar('*');
}
register int t;
	char	q;
	int	r;
	int	count;

	puts("\n\nSample program #2 : execution s