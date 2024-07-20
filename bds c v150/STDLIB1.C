/*
	STDLIB1.C -- for BDS C v1.50 -- 12/29/82
	Copyright (c) 1982 by Leor Zolman

	The files STDLIB1.C and STDLIB2.C contain the source for
	all functions in the DEFF.CRL library file.

	Functions appearing in this source file:

	fopen		getc		ungetc		getw
	fcreat		fappend		putc		putw
	fflush		fclose
	atoi
	strcat		strcmp		strcpy		strlen
	isalpha		isupper		islower		isdigit
	isspace		toupper		tolower
	qsort *
	initw		initb		getval
	alloc		free
	abs		max		min

	* - The symbolic constant "MAX_QSORT_WIDTH" must be enlarged when
	    sorting objects of greater width than in the definition below.
*/


#include <bdscio.h>

#define 	MAX_QSORT_WIDTH	513		/* Largest object "qsort"
						   can sort	          */

/*
	Buffered I/O for C:
*/

#define STD_IN	0
#define STD_OUT 1
#define STD_ERR 4

#define DEV_LST 2
#define DEV_RDR 3
#define DEV_PUN 3


int fopen(filename,iobuf)
FILE *iobuf;
char *filename;
{
	if ((iobuf -> _fd = open(filename,0))<0) return ERROR;
	iobuf -> _nleft = 0;
	iobuf -> _flags = _READ;
	return iobuf -> _fd;
}


int getc(iobuf)
FILE *iobuf;
{
	int nsecs;
	if (iobuf == STD_IN) return getchar();
	if (iobuf == DEV_RDR) return bdos(3);
	if (!iobuf->_nleft--)		/* if buffer empty, fill it up first */
	 {
		if ((nsecs = read(iobuf -> _fd, iobuf -> _buff, NSECTS)) <= 0)
			return iobuf -> _nleft++;
		iobuf -> _nleft = nsecs * SECSIZ - 1;
		iobuf -> _nextp = iobuf -> _buff;
	 }
	return *iobuf->_nextp++;
}

int ungetc(c, iobuf)
FILE *iobuf;
char c;
{
	if (iobuf == STD_IN) return ungetch(c);
	if ((iobuf < 7) || iobuf -> _nleft == (NSECTS * SECSIZ)) return ERROR;
	*--iobuf -> _nextp = c;
	iobuf -> _nleft++;
	return OK;
}
	

int getw(iobuf)
FILE *iobuf;
{
	int a,b;	
	if (((a=getc(iobuf)) >= 0) && ((b= getc(iobuf)) >=0))
			return 256*b+a;
	return ERROR;
}


int fcreat(name,iobuf)
char *name;
FILE *iobuf;
{
	if ((iobuf -> _fd = creat(name)) < 0 ) return ERROR;
	iobuf -> _nextp = iobuf -> _buff;
	iobuf -> _nleft = (NSECTS * SECSIZ);
	iobuf -> _flags = _WRITE;
	return iobuf -> _fd;
}


/*
	Fappend: Open a text file for buffered output, appending onto the end:
*/

int fappend(name, iobuf)
char *name;
FILE *iobuf;
{
	int i, fd;
	if ((fd = open(name,2)) == ERROR)
		return fcreat(name, iobuf);
	if (!(i = cfsize(fd)))
	{
		close(fd);
		return fcreat(name, iobuf);
	}
	if (seek(fd, -1, 2) == ERROR || read(fd, iobuf->_buff, 1) < 1)
	{
		close(fd);
		return ERROR;
	}
	seek(fd, -1, 2);
	for (i = 0; i < SECSIZ; i++)
		if (iobuf->_buff[i] == CPMEOF)
			break;
	iobuf -> _fd = fd;
	iobuf -> _nextp = iobuf -> _buff + i;
	iobuf -> _nleft = (NSECTS * SECSIZ) - i;
	iobuf -> _flags = _WRITE;
	return fd;
}


int putc(c,iobuf)
char c;
FILE *iobuf;
{
	if (iobuf <= 4)			/* handle special device codes: */
	 {
		switch (iobuf)
		 {
			case STD_OUT: return putchar(c);  /* std output */
			case DEV_LST: return (bdos(5,c)); /* list dev.  */
			case DEV_PUN: return (bdos(4,c)); /* to punch   */
			case STD_ERR: if (c == '\n')	  /* to std err */
						bdos(2,'\r');
				      return bdos(2,c);
		 }	
	 }
	if (!iobuf -> _nleft--)		/*   if buffer full, flush it 	*/
	 {
		if ((write(iobuf -> _fd, iobuf -> _buff, NSECTS)) != NSECTS)
			return ERROR;
		iobuf -> _nleft = (NSECTS * SECSIZ - 1);
		iobuf -> _nextp = iobuf -> _buff;
	 }
	return *iobuf -> _nextp++ = c;
}


int putw(w,iobuf)
unsigned w;
FILE *iobuf;
{
	if ((putc(w%256,iobuf) >=0 ) && (putc(w / 256,iobuf) >= 0))
				return w;
	return ERROR;
}


int fflush(iobuf)
FILE *iobuf;
{
	int i;
	if (iobuf < 4) return OK;
	if (!(iobuf->_flags & _WRITE))
		return OK;
	if (iobuf -> _nleft == (NSECTS * SECSIZ)) return OK;

	i = NSECTS - iobuf->_nleft / SECSIZ;
	if (write(iobuf -> _fd, iobuf -> _buff, i) != i)
			return ERROR;
	i = (i-1) * SECSIZ;

	if (iobuf -> _nleft) {
		movmem(iobuf->_buff + i, iobuf->_buff, SECSIZ);
		iobuf -> _nleft += i;
		iobuf -> _nextp -= i;
		return seek(iobuf->_fd, -1, 1);
	 }

	iobuf -> _nleft = (NSECTS * SECSIZ);
	iobuf -> _nextp = iobuf -> _buff;
	return OK;
}

int fclose(iobuf)
FILE *iobuf;
{
	if (iobuf < 4) return OK;
	fflush(iobuf);
	return close(iobuf -> _fd);
}


/*
	Some string functions
*/

int atoi(n)
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


char *strcat(s1,s2)
char *s1, *s2;
{
	char *temp; temp=s1;
	while(*s1) s1++;
	do *s1++ = *s2; while (*s2++);
	return temp;
}


int strcmp(s,t)
char s[], t[];
{
	int i;
	i = 0;
	while (s[i] == t[i])
		if (s[i++] == '\0')
			return 0;
	return s[i] - t[i];
}


char *strcpy(s1,s2)
char *s1, *s2;
{
	char *temp; temp=s1;
	while (*s1++ = *s2++);
	return temp;
}


int strlen(s)
char *s;
{
	int len;
	len=0;
	while (*s++) len++;
	return len;
}


/*
	Some character diddling functions
*/

int isalpha(c)
char c;
{
	return isupper(c) || islower(c);
}


int isupper(c)
char c;
{
	return c>='A' && c<='Z';
}


int islower(c)
char c;
{
	return c>='a' && c<='z';
}


int isdigit(c)
char c;
{
	return c>='0' && c<='9';
}


int isspace(c)
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



qsort(base, nel, width, compar)
char *base; int (*compar)();
unsigned width,nel;
{	int i, j;
	unsigned gap, ngap, t1;
	int jd, t2;

	t1 = nel * width;
	for (ngap = nel / 2; ngap > 0; ngap /= 2) {
	   gap = ngap * width;
	   t2 = gap + width;
	   jd = base + gap;
	   for (i = t2; i <= t1; i += width)
	      for (j =  i - t2; j >= 0; j -= gap) {
		if ((*compar)(base+j, jd+j) <=0) break;
			 _swp(width, base+j, jd+j);
	      }
	}
}

_swp(w,a,b)
char *a,*b;
unsigned w;
{
	char swapbuf[MAX_QSORT_WIDTH];
	movmem(a,swapbuf,w);
	movmem(b,a,w);
	movmem(swapbuf,b,w);
}


/*
 	Initialization functions
*/


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

int getval(strptr)
char **strptr;
{
	int n;
	if (!**strptr) return -32760;
	n = atoi(*strptr);
	while (**strptr && *(*strptr)++ != ',');
	return n;
}


/*
	Storage allocation functions:
*/

char *alloc(nbytes)
unsigned nbytes;
{
	struct _header *p, *q, *cp;
	int nunits; 
	nunits = 1 + (nbytes + (sizeof (_base) - 1)) / sizeof (_base);
	if ((q = _allocp) == NULL) {
		_base._ptr = _allocp = q = &_base;
		_base._size = 0;
	 }
	for (p = q -> _ptr; ; q = p, p = p -> _ptr) {
		if (p -> _size >= nunits) {
			_allocp = q;
			if (p -> _size == nunits)
				_allocp->_ptr = p->_ptr;
			else {
				q = _allocp->_ptr = p + nunits;
				q->_ptr = p->_ptr;
				q->_size = p->_size - nunits;
				p -> _size = nunits;
			 }
			return p + 1;
		 }
		if (p == _allocp) {
			if ((cp = sbrk(nunits *	 sizeof (_base))) == ERROR)
				return NULL;
			cp -> _size = nunits; 
			free(cp+1);	/* remember: pointer arithmetic! */
			p = _allocp;
		}
	 }
}


free(ap)
struct _header *ap;
{
	struct _header *p, *q;

	p = ap - 1;	/* No need for the cast when "ap" is a struct ptr */

	for (q = _allocp; !(p > q && p < q -> _ptr); q = q -> _ptr)
		if (q >= q -> _ptr && (p > q || p < q -> _ptr))
			break;
	if (p + p -> _size == q -> _ptr) {
		p -> _size += q -> _ptr -> _size;
		p -> _ptr = q -> _ptr -> _ptr;
	 }
	else p -> _ptr = q -> _ptr;

	if (q + q -> _size == p) {
		q -> _size += p -> _size;
		q -> _ptr = p -> _ptr;
	 }
	else q -> _ptr = p;

	_allocp = q;
}


/*
	Now some really hairy functions to wrap things up:
*/

int abs(n)
{
	return (n<0) ? -n : n;
}

int max(a,b)
{
	return (a > b) ? a : b;
}

int min(a,b)
{
	return (a <= b) ? a : b;
}

