/* crunt2.c	commonly used functions written in c.
 *	MQH 2/82
 *
 * This file contains runtime support functions not written in
 * assembly language. With they are all machine independent,
 * with the exceptions of:	bios()	inp()	outp().
 * This file should be included or linked into most programs, as
 * it eliminates most dependencies between other files in the package.
 */

#define _T	(1==1)
#define _F	(!_T)


strlen(s)
char * s;
{
	register char *x;

	for(x = s ; *x ; ++x)
		;
	return x-s;
}

isalpha(c)
char c;
{
	register char cc;

	return isupper(cc=c) || islower(cc);
}

isupper(c)
char c;
{
	register char cc;

	return (cc = c) >= 'A' && cc <= 'Z';
}

islower(c)
char c;
{
	register char cc;

	return (cc = c) >= 'a' && cc <= 'z';
}

isdigit(c)
char c;
{
	register char cc;

	return (cc = c) >='0' && c <= '9';
}

iswhite(c)
char	c;
{
	switch(c)
	{
	case ' ':
	case '\t':
	case '\r':
	case '\n':
	case '\f':
		return _T;
	default:
		return _F;
	}
}

toupper(c)
char	c;
{
	register char cc;

	if((cc = c) >= 'a' && cc <= 'z')
		return cc - ' ';
	return cc;
}

strcpy(d,s)
 char *d, *s;
{
	register char *dd;

	for(dd = d; *dd++ = *s++;)
		;
	return d;
}

puts(s)
 char *s;
{
	register char *ss;

	for(ss=s;*ss;)
		putchar(*ss++);
	return s;
}

gets(s)		/* please excuse this function, it knows not what it does */
char *s;
{
	register char c;
	char *temp;
	int count, i;

	temp = s;
start:	count = 0;
	s = temp;
	while ((c=getchar()) != '\n' && c != '\r')
	switch(c)
	{
	case 'U'-'@':
	case 'X'-'@':
		putchar('\n');
		goto start;		/* ugh */
	case 0x7f:
		putchar('\b');
	case '\b':
		putchar(' ');
		putchar('\b');
		if (count) {
			--count;
			--s;
		}
		break;
	 case 'R'-'@':
		putchar('\n');
		for (i = 0; i < count; )
			putchar(temp[i++]);
		break;
	 default:
		*s++ = c;
		++count;
	}
	*s = 0;
	return temp;
}

putchar(c)
char c;
{
	if(c=='\n')
		cconout('\r');
	cconout(c);
}

char *ccungot;			/* points to ungotten character */
				/* We do indeed realize this is */
				/* kludgey, but ...		*/
getchar()
{
	register char c;

	ccungot = "";		/* *ccungot is static, initialized to 0 */
	if(*ccungot) {
		c = *ccungot;
		*ccungot = 0;
	}
	else
		c = cconin();
	if(c == '\r')
		return '\n';
	else
		return c;
}

/*
 * Note: Some linkage editors only use six chars of a symbol. Therefore
 *	ungetchar() is now ugetchar().
 *	Stdio.h contains a #define ungetchar	ugetchar
 */ 

ugetchar(c)
char c;
{
	*ccungot = c;
}

movmem(source,dest,count)
char *dest,*source;
int count;
{
	register char *d;	/* trashed by ccld?r() */ 

	if((d = dest) == source || count == 0)
		return d;
	if(d < source)
		ccldir(d,source,count);
	else
		cclddr(d + count - 1,source + count - 1,count);
	return dest + count;
}

setmem(dest,count,byte)
char *dest;
int count;
char byte;
{
	register char *d;	/* trashed by ccldir() */

	if(count) {
		*(d = dest) = byte;
		ccldir(d + 1, d, count - 1);
	}
	return dest;
}

xmain()
{
	int *gargv;	/* char ** */
	int gargc;

	load_args(&gargc,&gargv);
	main(gargc,gargv);
}

load_args(argc,argv)	/* set up argv and argc for C program */
int *argc,*argv;	/* argv should actually be char **argv */
{
	register int c;
	char *tmp[64];
	char *p, *com_end;

	p = com_line();
	com_end = p + com_len();
	for(tmp[0] = "", c = 1; tmp[c] = nextarg(&p,com_end); ++c)
		;
	*argc = c;
	c = (sizeof "") * (c + 1);
	movmem(tmp, *argv = evnbrk(c), c);
}

nextarg(p2,com_end)
 char **p2;
 char *com_end;
{
	register char *p;
	char *q,dlmt,tmp[128];
	int count;

	for(p = *p2;; ++p){
		if(p>=com_end)
			return _F;
		if(!iswhite(*p))
			break;
	}
	switch(*p) {
	case '\'':
	case '"':
		dlmt = *p++;	break;
	default:
		dlmt = 0;	break;
	}
	for(q=tmp, count=0
		;(dlmt ? *p != dlmt : !iswhite(*p)) && p < com_end; ++count) {
		if(*p == '\\')
			++p; /* should be more elaborate */
		*q++ = *p++;
	}
	*q = 0;
	++count;
	movmem(tmp,q = sbrk(count), count);
	*p2 = p + 1;
	return q;
}

sbrk(p)
 int p;
{
	register char * save;
	extern char * ccedata;

	if(brk((save=ccedata)+p))
		return -1;
	return save;
}

evnbrk(i)
	int i;
{
	sbrk(sbrk(0)&1);
	return sbrk(i);
}

q1(s)
char *s;
{
	puts(s);
	return s;
}
/*
******************************************************************
**								**
**		MACHINE  DEPENDENT  STUFF			**
**								**
******************************************************************
*/
/*	Bios entry points	*/
#define SELDSK		 9
#define SETTRK		10
#define SETSEC		11
#define SETDMA		12
#define READ		13
#define WRITE		14
#define SECTRAN		16
#define JMPLEN		3		/* length of jmp instruction */

int *bios(jmpnum,bc,de)	/* This version of bios() recognizes that SELDSK
			 * and SECTRAN return their values in HL not A and
			 * that SECTRAN is passed DE AND HL.
			 */
char *jmpnum;
int	bc,de;
{
	int *p;

	p = JMPLEN * (jmpnum - 1) + *(p = 1);
	if(jmpnum == SELDSK || jmpnum == SECTRAN)
		return ccall(p,0,0,bc,de);
	else
		return ccalla(p,0,0,bc,0);
}

/*
 * inp() and outp() are machine dependent. these are for 8080,Z80,8085 CPU'
 * They do not work in a split I&D enviornment, though they are ROMable.
 */
inp(port)
char	port;
{
	char	a[3];

	a[0] = 0xDB;		/* 8080 in instr */
	a[1] = port;
	a[2] = 0xC9;		/* 8080 ret instr */
	return ccalla(a, 0, 0, 0, 0);
}

outp(c,port)
char c, port;
{
	char	a[3];

	a[0] = 0xD3;		/* 8080 out instr */
	a[1] = port;
	a[2] = 0xC9;		/* 8080 ret */
	return ccall(a, 0, c, 0, 0);
}

0
#define SETSEC		11
#define SETDMA		12
#define READ		