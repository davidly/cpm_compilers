
/*

	The files STDLIB*.C contain source for all DEFF.CRL
	functions which are written in C; Any functions which
	appear in DEFF.CRL but have no corresponding source
	were written in machine code and hand-converted to
	.CRL format (as described in the User's Guide.)
	Conversely, any functions whose source appears
	in one of these files but for which there are no
	entries in DEFF.CRL must be compiled before using.
	There wasn't enough space in the DEFF.CRL directory
	for all of them, and this package has got enough
	separate files as it is.
	All functions written by Leor Zolman....who is
	soley responsible for their kludginess.

	Functions appearing in this file:

	fopen	getc	getw
	fcreat	putc	putw
	fflush
	atoi
	strcat	strcmp	strcpy	strlen
	isalpha	isupper	islower	isdigit
	isspace	toupper	tolower
	qsort
	initw	initb	getval
	abs

*/

#define RAM 0x0000	/* CP/M lowest RAM address */

/* Buffered I/O for C  */

struct buf {
	int fd;
	int nleft;
	char *nextp;
	char buff[128];
 };


fopen(filename,iobuf)
struct buf *iobuf;
char *filename;
{
	int fd2;
	if ((fd2= open(filename,0))<0) return -1;
	iobuf -> fd = fd2;
	iobuf -> nleft = 0;
	return fd2;
}


getc(iobuf)
struct buf *iobuf;
{
	if (iobuf==0) return getchar();
	if (iobuf -> nleft--) return *iobuf -> nextp++;
	if ((read(iobuf -> fd, iobuf -> buff, 1)) <= 0)
				return -1;
	iobuf -> nleft = 127;
	iobuf -> nextp = iobuf -> buff;
	return *iobuf -> nextp++;
}

getw(iobuf)
struct buf *iobuf;
{
	int a,b;	
	if (((a=getc(iobuf)) >= 0) && ((b= getc(iobuf)) >=0))
			return 256*b+a;
	return -1;
}


fcreat(name,iobuf)
char *name;
struct buf *iobuf;
{
	int fd2;
	unlink(name);
	if ((fd2 = creat(name))<0 ) return -1;
	iobuf -> fd = fd2;
	iobuf -> nextp = iobuf -> buff;
	iobuf -> nleft = 128;
	return fd2;
}


putc(c,iobuf)
int c;
struct buf *iobuf;
{
	if (iobuf == 1) return putchar(c);
	if (iobuf -> nleft--) return *iobuf->nextp++ =c;
	if ((write(iobuf -> fd, iobuf -> buff,1)) <=0)
			return -1;
	iobuf -> nleft = 127;
	iobuf -> nextp = iobuf -> buff;
	return *iobuf -> nextp++ = c;
}


putw(w,iobuf)
unsigned w;
struct buf *iobuf;
{
	if ((putc(w%256,iobuf) >=0)&&(putc(w/256,iobuf)>=0))
				return w;
	return -1;
}


fflush(iobuf)
struct buf *iobuf;
{
	if (iobuf==1) return 0;
	if (iobuf -> nleft == 128) return 0;
	if ((write(iobuf -> fd, iobuf -> buff,1)) <=0)
			return -1;
	if (iobuf -> nleft != 0)
		return seek(iobuf->fd, -1, 1);
	iobuf -> nleft = 128;
	iobuf -> nextp = iobuf -> buff;
	return 0;
}

/*
	Some string functions
*/


atoi(n)
char *n;
{
	int val; 
	char c;
	int sign;
	val=0;
	sign=1;
	while ((c = *n) == '\t' || c== ' ') ++n;
	if (c== '-') {sign = -1; n++;}
	while (  isdigit(c = *n++)) val = val * 10 + c - '0';
	return sign*val;
}


strcat(s1,s2)
char *s1, *s2;
{
	char *temp; temp=s1;
	while(*s1) s1++;
	do *s1++ = *s2; while (*s2++);
	return temp;
}


strcmp(s,t)
char s[], t[];
{
	int i;
	i = 0;
	while (s[i] == t[i])
		if (s[i++] == '\0')
			return 0;
	return s[i] - t[i];
}


strcpy(s1,s2)
char *s1, *s2;
{
	char *temp; temp=s1;
	while (*s1++ = *s2++);
	return temp;
}


strlen(s)
char *s;
{
	int len;
	len=0;
	while (*s++) len++;
	return(len);
}


/*
	Some character diddling functions
*/

isalpha(c)
char c;
{
	return isupper(c) || islower(c);
}


isupper(c)
char c;
{
	return c>='A' && c<='Z';
}


islower(c)
char c;
{
	return c>='a' && c<='z';
}


isdigit(c)
char c;
{
	return c>='0' && c<='9';
}


isspace(c)
char c;
{
	return c==' ' || c=='\t' || c=='\n';
}


char toupper(c)
char c;
{
	return islower(c) ? c-32 : c;
}


char tolower(c)
char c;
{
	return isupper(c) ? c+32 : c;
}


/*
	Other stuff...
*/


qsort(base,nel,width,compar)
char *base;
int(*compar)();
int nel;
int width;
{
	unsigned i,j,x;
	x=base+nel*width;
	for (i=base; i<x; i+=width)
		for (j=i+width; j<x; j+=width)
			if((*compar)(i,j)<0) _swp(width,i,j);
}

_swp(w,a,b)
char *a,*b;
int w;
{
	char tmp;
	while(w--) {tmp=*a; *a++=*b; *b++=tmp;}
}


/* 	initialization functions */


initw(var,string)
int *var;
char *string;
{
	int n;
	while ((n = getval(&string)) != -32760) *var++ = n;
}

initb(var,string)
char *var, *string;
{
	int n;
	while ((n = getval(&string)) != -32760) *var++ = n;
}

getval(strptr)
char **strptr;
{
	int n;
	if (!**strptr) return -32760;
	n = atoi(*strptr);
	while (**strptr && *(*strptr)++ != ',');
	return n;
}

/*
	One lone little last function:
*/

abs(n)
{
	return (n<0) ? -n : n;
}

"�Y��4FILE LINE LONGER THAN ENTIRE SCRN ??? :�&!�&��q:�&!�&����q:�&��q����t�2�&>
��$:�&���!�&5��4!�&����!�&~��*SIDE)-1;
	do p2->board[i] = p1->board[i];
		while(i--);
	p2->star = p1->star;
	p2->red = p1->red;
	p2->blue = p1->blue;
 