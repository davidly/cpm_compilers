/*
	name...
		printf

	purpose...
		formatted I/O

	authors...
		Original program by J. E. Hendrix, floating
		point functions added by J. R. Van Zandt.

	history...
		11 Sept 84 Calling _outc() rather than putc(),
			_outc() calls putc() or putchar().
		9 Sept 84  Calling putc() rather than putchar(),
			1st parameter can be device #.
		11 Aug 84  ftoe() handles argument of 0.
		3 Aug 84   Calling putchar() directly rather
			than through cout().
		Aug 84  Added atof()
		12 Aug 83  Added 'e' format.
		10 Aug 83  changed back to &argcnt+i-1.
			Added 'f' format.
		8 Aug 83  Changed addr of first arg to
			&argcnt + i + 1.
*/

#include printf2.h
#include iolib.h
#include float.h

#define NULL 0
#define ERR -1

int device;

/*
** printf(controlstring, arg, arg, ...) -- formatted print
**        operates as described by Kernighan & Ritchie
**        only d, x, c, s, f, e, and u specs are supported.
*/
printf(argcnt) int argcnt; {
  int i, width, prec, preclen, len, *nxtarg;
  char *ctl, *cx, c, right, str[128], *sptr, pad;
  double *pd;
  i = argc();   /* fetch arg count from A reg first */
  nxtarg = &argcnt + i - 1;
  ctl = device = *nxtarg;
  if (device==(device&31))	/* *small* value must be device # */
	{ctl=*--nxtarg;}
  else device=0;
  while(c=*ctl++) {
    if(c!='%') {_outc(c); continue;}
    if(*ctl=='%') {_outc(*ctl++); continue;}
    cx=ctl;
    if(*cx=='-') {right=0; ++cx;} else right=1;
    if(*cx=='0') {pad='0'; ++cx;} else pad=' ';
    if((i=utoi(cx, &width)) >= 0) cx=cx+i; else continue;
    if(*cx=='.') {
      if((preclen=utoi(++cx, &prec)) >= 0) cx=cx+preclen;
      else continue;
      }
    else preclen=0;
    sptr=str; c=*cx++; i=*(--nxtarg);
    if(c=='d') itod(i, str, 7);
    else if(c=='x') itox(i, str, 7);
    else if(c=='c') {str[0]=i; str[1]=NULL;}
    else if(c=='s') sptr=i;
    else if(c=='u') itou(i, str, 7);
    else
	{if(preclen==0)prec=6;
	if(c=='f')
	    {nxtarg=nxtarg-2; pd=nxtarg; ftoa(*pd,prec,str);
	    }
	else if(c=='e')
	    {nxtarg=nxtarg-2; pd=nxtarg; ftoe(*pd,prec,str);
	    }
	else continue;
	}
    ctl=cx; /* accept conversion spec */
    if(c!='s') while(*sptr==' ') ++sptr;
    len=-1; while(sptr[++len]); /* get length */
    if((c=='s')&(len>prec)&(preclen>0)) len=prec;
    if(right) while(((width--)-len)>0) _outc(pad);
    while(len) {_outc(*sptr++); --len; --width;}
    while(((width--)-len)>0) _outc(pad);
    }
  }


/*
** utoi -- convert unsigned decimal string to integer nbr
**          returns field size, else ERR on error
*/
utoi(decstr, nbr)  char *decstr;  int *nbr;  {
  int d,t; d=0;
  *nbr=0;
  while((*decstr>='0')&(*decstr<='9')) {
    t=*nbr;t=(10*t) + (*decstr++ - '0');
    if ((t>=0)&(*nbr<0)) return ERR;
    d++; *nbr=t;
    }
  return d;
  }


/*
** itod -- convert nbr to signed decimal string of width sz
**         right adjusted, blank filled; returns str
**
**        if sz > 0 terminate with null byte
**        if sz = 0 find end of string
**        if sz < 0 use last byte for data
*/
itod(nbr, str, sz)  int nbr;  char str[];  int sz;  {
  char sgn;
  if(nbr<0) {nbr = -nbr; sgn='-';}
  else sgn=' ';
  if(sz>0) str[--sz]=NULL;
  else if(sz<0) sz = -sz;
  else while(str[sz]!=NULL) ++sz;
  while(sz) {
    str[--sz]=(nbr%10+'0');
    if((nbr=nbr/10)==0) break;
    }
  if(sz) str[--sz]=sgn;
  while(sz>0) str[--sz]=' ';
  return str;
  }


/*
** itou -- convert nbr to unsigned decimal string of width sz
**         right adjusted, blank filled; returns str
**
**        if sz > 0 terminate with null byte
**        if sz = 0 find end of string
**        if sz < 0 use last byte for data
*/
itou(nbr, str, sz)  int nbr;  char str[];  int sz;  {
  int lowbit;
  if(sz>0) str[--sz]=NULL;
  else if(sz<0) sz = -sz;
  else while(str[sz]!=NULL) ++sz;
  while(sz) {
    lowbit=nbr&1;
    nbr=(nbr>>1)&32767;  /* divide by 2 */
    str[--sz]=((nbr%5)<<1)+lowbit+'0';
    if((nbr=nbr/5)==0) break;
    }
  while(sz) str[--sz]=' ';
  return str;
  }


/*
** itox -- converts nbr to hex string of length sz
**         right adjusted and blank filled, returns str
**
**        if sz > 0 terminate with null byte
**        if sz = 0 find end of string
**        if sz < 0 use last byte for data
*/
itox(nbr, str, sz)  int nbr;  char str[];  int sz;  {
  int digit, offset;
  if(sz>0) str[--sz]=NULL;
  else if(sz<0) sz = -sz;
  else while(str[sz]!=NULL) ++sz;
  while(sz) {
    digit=nbr&15; nbr=(nbr>>4)&4095;
    if(digit<10) offset=48; else offset=55;
    str[--sz]=digit+offset;
    if(nbr==0) break;
    }
  while(sz) str[--sz]=' ';
  return str;
  }
/*
	name...
		putf

	purpose...
		to convert from double precision floating
		point to ASCII string

	history...
		10 Aug 82  Adapted from 'putf': output into
			a string, no padding.
		11 Oct 82 'int' => 'floor'
		4 Oct 82  Using floating point constants,
			not scaling x down before printing
			digits before decimal point.
*/
ftoa(x,f,str)
double x;	/* the number to be converted */
int f;		/* number of digits to follow decimal point */
char *str;	/* output string */
{	double scale;	/* scale factor */
	int i,		/* copy of f, and # digits before
			decimal point */
	minus,		/* nonzero if x<0 */
	d;		/* a digit */
	if(x>=0.) minus=0;
	else	{minus=1; x=-x;}
	if(minus)*str++ = '-';
			/* round off the number */
	i=f;
	scale=2.;
	while(i--)scale=scale*10.;
	x=x+1./scale;
	/* count places before decimal & scale the number */
	i=0;
	scale=1.;
	while(x>=scale) {scale=scale*10.; i++;}
	while(i--)	/* output digits before decimal */
		{scale=floor(.5+scale*.1);
		d=ifix(x/scale);
		*str++ = d+'0';
		x=x-float(d)*scale;
		}
	if(f<=0) {*str=NULL;return;}
	*str++ = '.';
	while(f--)	/* output digits after decimal */
		{x=x*10.; d=ifix(x);
		*str++ = d+'0'; x=x-float(d);
		}
	*str=NULL;
}
/*	e format conversion			*/
ftoe(x,prec,str)
double x;	/* number to be converted */
int prec;	/* # digits after decimal place */
char *str;	/* output string */
{	double scale;	/* scale factor */
	int i,		/* counter */
	d,		/* a digit */
	expon;		/* exponent */
	scale=1.;		/* scale = 10 ** prec */
	i=prec; while(i--) scale=scale*10.;
	if(x==0.) {expon=0; scale=scale*10.;}
	else	{expon=prec;
		if(x<0.) {*str++='-'; x=-x;}
		if(x>scale)	/* need: scale<x<scale*10 */
			{scale=scale*10.;
			while(x>=scale) {x=x/10.; ++expon;}
			}
		else	{while(x<scale) {x=x*10.; --expon;}
			scale=scale*10.;
			}
		/* at this point, .1*scale <= x < scale */
		x=x+.5;			/* round */
		if(x>=scale) {x=x/10.; ++expon;}
		}
	i=0;
	while(i<=prec)
		{scale=floor(.5+scale*.1);
		/* now, scale <= x < 10*scale */
		d=ifix(x/scale);
		*str++ = d+'0';
		x=x-float(d)*scale;
		if(i++) continue;
		*str++ ='.';
		}
	*str++='e';
	if(expon<0) {*str++='-'; expon=-expon;}
	if(expon>9) *str++ ='0'+expon/10;
	*str++='0'+expon%10;
	*str=NULL;
}

	/* decimal to (double) binary conversion */

atof(s) char s[]; /* s points to a character string */
{	double sum,	/* the partial result */
	scale;		/* scale factor for the next digit */
	char *start,	/* copy if input pointer */
	*end,		/* points to end of number */
	c;		/* character from input line */
	int minus,	/* nonzero if number is negative */
	dot,		/* nonzero if *s is decimal point */
	decimal;	/* nonzero if decimal point found */
	if(*s=='-') {minus=1; s++;}
	else minus=0;
	start=s;
	decimal=0;  /* no decimal point seen yet */
	while(((*s<='9')&(*s>='0'))|(dot=(*s=='.')))
		{if(dot)decimal++;
		s++;	/* scan to end of string */
		}
	end=s;
	sum=0.;	/* initialize answer */
	if(decimal)  /* handle digits to right of decimal */
		{s--;
		while(*s!='.')
			sum=(sum+float(*(s--)-'0'))/10.;
		}
	scale=1.;	/* initialize scale factor */
	while(--s>=start)	/* handle remaining digits */
		{sum=sum+scale*float(*s-'0'); scale=scale*10.;}
	c=*end++;
	if((c=='e')|(c=='E'))	/* interpret exponent */
		{int neg,	/* nonzero if exp negative */
		expon,		/* absolute value of exp */
		k;		/* mask */
		neg=expon=0;
		if(*end=='-')	/* negative exponent */
			{neg=1; end++;}
		while(1)	/* read an integer */
			{if((c=*end++)>='0')
				{if(c<='9')
					{expon=expon*10+c-'0';
					continue;
					}
				}
			break;
			}
		if(expon>38) {puts("overflow"); expon=0;}
		k=32;	/* set one bit in mask */
		scale=1.;
		while(k)
			{scale=scale*scale;
			if(k&expon) scale=scale*10.;
			k=k>>1;
			}
		if(neg) sum=sum/scale;
		else    sum=sum*scale;
		}
	if(minus)sum=-sum;
	return sum;
}

_outc(c) char c;
{	if(device) putc(c,device);
	else putchar(c);
}
                                                                          