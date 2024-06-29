#include	"crunt2.c"
#include	"func.c"

main()
{
	char ch, instring[80];
	char secstr[80];

	puts("\nSample program #1 : the string and characater functions\n");
	puts("\n   The following functions will be demonstrated:\n\n");
	puts("   toupper   	tolower		isalpha		isdigit\n");
	puts("   gets		puts		strcpy		strcat\n");
	puts("   strcmp       isupper         islower\n");

	puts("\n\nEnter a string: ");
	gets(instring);
	puts("Here is the string you entered: ");
	puts(instring);
	puts("\n");
	puts("Enter a second string to compare with the first\n");
	puts(": ");
	gets(secstr);
	if(!strcmp(secstr,instring)) puts("strings are equal\n");
	else puts("strings differ\n");
	puts("\nNow let's put the first string together with the second\n");
	strcat(instring,secstr);
	puts(instring);
	puts("\n\nNext lets copy the second string into the first:\n");
	strcpy(instring,secstr);
	puts(instring);
	puts("\n\n");
	
	puts("Next we will demonstrate the character commands\n");
	do{
		puts("\ntype a 0 to move on: ");
		ch=getchar();
		if(islower(ch)) 
			dolower(ch);
		else if(isupper(ch))
			doupper(ch);
		else if(isdigit(ch))
			dodigit(ch);
		if(isalpha(ch)) puts(" character is alpha");
	} while (ch!='0');
}

dolower(ch)
char ch;
{
		puts(" lower case char --> upper: ");
		ch=toupper(ch);
		putchar(ch);
}

doupper(ch)
char ch;
{
			puts(" upper case char --> lower: ");
			ch=tolower(ch);
			putchar(ch);
}

dodigit(ch)
char ch;
{
	int tt;
	puts(" squared is ");
	tt=ch-'0';
	tt=tt*tt;
	putdec(tt);
}
 with the first\n");
	puts(": ");
	gets(secstr);
	if(!strcmp(secstr,instring)) puts("