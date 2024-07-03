/* func.c	misc. functions written in c.
 *		MQH 2/82
 *		RB  4/82 -- efficiency mods
 *	All of these functions are machine independent, with the exception
 *	of bios.
 */
#define _TRUE	(1/*1 == 1*/)
#define _FALSE	(0/*!_TRUE*/)

isalnum(c)
char c;
{
	register char cc;

	return isalpha(cc = c) || isdigit(cc);
}

isascii(c)
char c;
{
	return c < 0x80;
}

iscntrl(c)
char c;
{
	return c < ' ';
}

ispunct(c)
char c;
{
	register char cc;

	return isascii(cc = c) && !iscntrl(cc) && !isalnum(cc);
}

isprint(c)
char c;
{
	register char cc;

	return (cc = c) >= ' ' && cc <= '~';
}

isspace(c)
char c;
{
	switch(c)
	{
	case ' ':
	case '\t':
	case '\n':
		return _TRUE;
	default:
		return _FALSE;
	}
}

isnumeric(c,radix)
char	c;
int	radix;
{
	register char cc;

	cc = toupper(c);
	if(radix <= 10)
		return cc >= '0' && cc <= '0' + (radix - 1);
	else
		return (cc >='0' && cc <='9')
			|| (cc >= 'A' && cc <= 'A' + (radix - 11));
}

tolower(c)
char c;
{
	register char cc;

	if(isupper(cc = c))
		return cc + ' ';
	else
		return cc;
}

strncpy(d,s,n)
char *d,*s;
int n;
{
	register char *dd;

	for(dd = d; n; --n) {
		if(*s)
			*dd++ = *s++;
		else
			*s++ = 0;
	}
	return d;
}

strcat(d,s)
char *d, *s;
{
	register char *dd;

	for(dd = d; *dd; ++dd)
		;
	while(*dd++ = *s++)
		;
	return d;
}

strncat(d,s,n)
char *d,*s;
int n;
{
	register char *dd;

	for(dd = d; *dd; ++dd)
		;
	for(;n && (*dd++ = *s++);--n)
		;
	if(!n)
		*dd = 0;
	return d;
}

strcmp(s,t)
char *s, *t;
{
	register char *ss;

	for(ss = s; *ss == *t; ++ss, ++t)
		if (*ss == '\0')
			return 0;
	return *ss - *t;
}

index(s,c)
char *s,c;
{
	register char *ss;

	for(ss = s; *ss ; ++ss)
		if(*ss==c)
			return ss;
	return _FALSE;
}

rindex(s,c)
char *s,c;
{
	register char *ss;
	char match;

	for(match = 0, ss = s; *ss ; ++ss)
		if(*ss==c)
			match = ss;
	return match;
}

atoi(n)
char *n;
{
	register int val; 
	char c;
	char sign;

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

#define MHZ	4
sleep(n)	/* n = tenths of seconds on Z80 with speed of MHZ */
char *n;
{
	register char *i;
	char *tick;

	for(tick = MHZ * 0x800; n--; )
		for(i = tick; --i; )
			;
	return _TRUE;
}


abs(n)
int	n;
{
	register int nn;

	if((nn = n) < 0)
		return -nn;
	else
		return nn;
}

kbhit()
{
	return cconst();
}

pause()
{
	for(;!kbhit();)
		;	
}


/* Excuse me please, but ...	*/
peek(a) char *a; {	return *a; }
poke(a,c) char *a,c; {	return *a = c; }

initw(var,string)
int *var;
char *string;
{
	while(string)
		*var++ = getval(&string);
}

initb(var,string)
char *var, *string;
{
	while(string)
		*var++ = getval(&string);
}

getval(strptr)
int *strptr;
{
	register char *p;
	int n;

	p = *strptr;
	if(*p == 0)
		return *strptr = 0;
	for(n = 0; isdigit(*p); )
		n = n * 10 + *p++ - '0';
	while(*p && !isdigit(*p))
		++p;
	*strptr = p;
	return n;
}

qsort(base, nel, width, compar)
int nel, width;
char *base; int (*compar)();
{	int gap,ngap, i, j;
	int jd, t1, t2;
	t1 = nel * width;
	for (ngap = nel / 2; ngap > 0; ngap /= 2) {
		gap = ngap * width;
		t2 = gap + width;
		jd = base + gap;
		for (i = t2; i <= t1; i += width)
		for (j =  i - t2; j >= 0; j -= gap) {
			if ((*compar)(base+j, jd+j) <=0)
				break;
			Xswp(width, base+j, jd+j);
		}
	}
}

Xswp(w,a,b)
char *a,*b;
int w;
{
	register char tmp;
	while(w--) {
		tmp=*a; *a++=*b; *b++=tmp;
	}
}

int ccrand;
srand(seed)
int seed;
{
	register int i;

	if(!seed) {
		puts("Wait a moment, then strike a key");
		for(;!kbhit();++i)
			;
		ccrand = i;
	}
	else
		ccrand = seed;
}

#define M	32749
#define A	32719
#define C	3

rand()
{
	return ccrand = (ccrand * A + C) % M;
}

putdec(nn)		/* display decimal number w/out printf's overhead */
 int nn;
{
	register unsigned n;

	n = nn>=0? nn: (putchar('-'), -nn);

	if(nn = n/10)
		putdec(nn);

	putchar(n%10+'0');
}
l, width, compar)
int nel, width;
char *base; int (*compar)();
{	int gap,ngap, i, j;