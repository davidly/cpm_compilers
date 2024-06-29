/* Printf et al			  */
/* Copyright SuperSoft, Inc. 1982 */

#include "stdio.h"

#define STD	0	/* standard input */
#define NSTD	1	/* bufferred stream */
#define STR	2	/* string is the argument */
#define NDELIMS 97	/* number of delimiters in %[ */
int stdin;
#define EOF	-1


/*
 * Xrscanf is the formatted input scanner. It takes an input
 * kind, a pointer to the input medium (either a string pointer or
 * a FILE pointer, a format string and a list of pointer
 * arguments, appropriate data is picked up from the
 * text string and stored where the pointer arguments
 * point according to the format string. See the Unix Programmer's Manual
 * Seventh Edition.  Note that the arguments to this routine are in the
 * reverse order of the standard SSC calling sequence.
 */

Xrscanf(kind, where, format, args)
int kind, where;
char *format;
int *args;
{
	char suppress, c, base, nconv, *sptr;
	int sign, val, xc, width, *target;
	char delim[NDELIMS], ndelim, gotit;

	if (Xnextfield(kind, &where) == EOF)
		return (EOF);

	nconv = 0;
	while (c = *format++) {
		if (iswhite(c)) {
			if (Xnextfield(kind, &where) == EOF)
				return (nconv);
			else
				continue;	/* check and see if a match should be don first */
		}

		if (c != '%') {
			xc = Xnextch(kind, &where);
			if (c == xc)
				continue;
			return(nconv);
	 	}

		width = Xgv2(&format);	/* get field width */

		sign = 0;
		base = 10;
		suppress = 0;
		gotit = 0;
		if ((c = *format++) == '*') {
			suppress++;
			c = *format++;
		}

		if (c == 'l' || c == 'h') {
			c = *format++;			/* ignore short and long modifiers */
			if (c != 'x' && c != 'o' && c != 'd')
				return(nconv);
		}

		switch (toupper(c)) {

		case 'X': base = 16;
			if (Xnextfield(kind, &where)==EOF)
				return (nconv);
			goto doval;

		case 'O': base = 8;
			if (Xnextfield(kind, &where)==EOF)
				return (nconv);
			goto doval;

		case 'D':
			if (Xnextfield(kind, &where)==EOF)
				return (nconv);

			if ((xc = Xnextch(kind, &where)) == '-') {
				sign = -1;
				width--;
			}
			else
				Xpushback(kind, &where, xc);
			goto doval;

		case 'U':
			if (Xnextfield(kind, &where)==EOF)
				return (nconv);

		doval:
			val = 0;
			if (width == 0)	/* %d is arbitrary length integer */
				width = 32767;

			while (width--) { /* go until end of field */
				xc = Xnextch(kind, &where);
				if (xc == EOF)
					if (gotit)
						break;
					else
						return (nconv);
				if (!Xvalid(xc, base)) {
					Xpushback(kind, &where, xc);
					break;
				}
				val = val * base + Xconv(xc);
				gotit = 1;
			}
			if (sign)
				val = -val;

			if (!suppress) {
				target = *args++;
				*target = val;
				nconv++;
			}
			break;

		case 'S':
			if (Xnextfield(kind, &where)==EOF)
				return (nconv);
			if (!suppress)
				sptr = *args;
			if (width == 0)	/* %s is arbitrary length string */
				width = 32767;

			while (width--) {	/* go until end of field */
				xc = Xnextch(kind, &where);
				if (xc == EOF)
					if (gotit)
						break;
					else
						return (nconv);
				if (iswhite(xc)) {
					Xpushback(kind, &where, xc);
					break;
				}
				if (!suppress)
					*sptr++ = xc;
				gotit = 1;
			}
			if (!suppress) {
				nconv++;
				*sptr = '\0';
				args++;
			}
			break;

		case '[':		/* special string format */
			if (*format == '^') {
				ndelim = 1;
				format++;
			}
			else
				ndelim = 0;

			sptr = delim;
			while (*format != ']' && *format != '\0')
				*sptr++ = *format++;
			if (*format == ']')
				++format;
			*sptr = '\0';

			if (!suppress)
				sptr = *args;
			if (width == 0)	/* %[ is arbitrary length string */
				width = 32767;

			while (width--) {	/* go until end of field */
				xc = Xnextch(kind, &where);
				if (xc == EOF)
					if (gotit)
						break;
					else
						return (nconv);
				if (Xisterm(xc, delim, ndelim) != 0) {
					Xpushback(kind, &where, xc);
					break;
				}
				if (!suppress)
					*sptr++ = xc;
				gotit = 1;
			}
			if (!suppress) {
				nconv++;
				*sptr = '\0';
				args++;
			}
			break;

		case 'C':
			if (!suppress)
				sptr = *args;
			if (width == 0)	/* %c is one character */
				width = 1;
			while (width--) {	/* go until end of field */
				xc = Xnextch(kind, &where);
				if (xc == EOF)
					if (gotit)
						break;
					else
						return (nconv);
				if (!suppress)
					*sptr++ = xc;
				gotit = 1;
			}
			if (!suppress) {
				args++;
				nconv++;
			}
			break;

		default:  return (nconv);
		 }

	}
	return (nconv);
}

/*
 * Xvalid is a local function for determining whether a character
 * is a valid digit in the given base.
 */
Xvalid(c, base)
char c, base;
{
	register int i;

	i = c;
	if (isdigit(i))
		i -= '0';
	else if (isalpha(i)) {
		i = toupper(i);
		i -= ('A' - 10);
	} else
		return(0);
	if (i < base)
		return(1);
	else
		return(0);
}

/*
 * Xconv is a local routine to convert a character to a number.
 */
Xconv(c)
char c;
{
	register int i;

	i = c;

	if (isdigit(i))
		i -= '0';
	else 
		i = (toupper(i)) - ('A' - 10);

	return(i);
}

/*
 * Xnextfield is an internal routine for advancing to the next
 * field in whichever input medium is being used by Xrscanf.
 */
Xnextfield(kind, where)
int kind, *where;
{
	register int xc;

	while (1) {	/* skip white space */
		xc = Xnextch(kind, where);
		if (xc == EOF)
			return EOF;
		if (iswhite(xc))
			continue;
		Xpushback(kind, where, xc);	/* at next field */
		return SUCCESS;
	}
}

/*
 * Xisterm is an internal routine for determining whether a
 * character is in a list of terminators or not.
 */
Xisterm(c, delim, flag)
char c, *delim, flag;
{
	register char *s;

	for (s = delim; *s != '\0'; s++)
		if (c == *s)
			return(flag);
	return(!flag);
}

/*
 * Xnextch fetches the next character from whichever input
 * medium is specified by kind.  Where is a pointer to
 * that medium.
 */
Xnextch(kind, where)
int kind, *where;
{
	register char *p;
	int c;

	if (kind == STD)
		return(getchar());
	if (kind == NSTD) {
		c = getc(*where);

		if (c == 26) {	/* control - z */
			ungetc(c, *where);
			c = EOF;
		}
		return (c);
	}
	/* where points to a string pointer */

	p = *where;
	c = (*p) & 0xFF;
	if (c == '\0')		/* end of string so indicate EOF */
		return(EOF);
	++p;
	*where = p;		/* update the string pointer */

	return(c);
}

/*
 * Xpushback is an internal routine for pushing a character
 * back onto the input stream.
 */
Xpushback(kind, where, c)
int kind, *where;
char c;
{
	register char *p;

	if (kind == STD)
		ugetchar(c);
	else if (kind == NSTD)
		ungetc(c, *where);
	else {		/* where points to a string pointer */
		p = *where;
		--p;
		*p = c;
		*where = p;
	}
}

/*
 * scanf - just reverse the argument string and call
 * Xrscanf with the correct argument list.
 */
scanf(nargs)
int nargs;
{
	register int *p;
	int *q;
	int *temp;
	char *s;

	if (nargs < 1)
		return(EOF);

	q = p = &nargs;

	for (p += *p; p >= q; --p) { /* reverse the list */
		temp = *p;
		*p = *q;
		*q++ = temp;
	}

	p = &nargs;
	s = *p;
	p++;

	return(Xrscanf(STD, stdin, s, p));
}

/*
 * sscanf - just reverse the argument list and call Xrscanf
 */
sscanf(nargs)
int nargs;
{
	register int *p;
	int *q;
	int *temp;
	char *s1;

	if (nargs < 2)
		return(EOF);

	q = p = &nargs;

	for (p += *p; p >= q; --p) {	/* reverse the list */
		temp = *p;
		*p = *q;
		*q++ = temp;
	}

	p = &nargs;
	q = p;
	p++;
	s1 = *p;
	p++;
	return(Xrscanf(STR, *q, s1, p));
}

/*
 * fscanf - just call Xrscanf after reversing the argument list.
 */
fscanf(nargs)
int nargs;
{
	register int *p;
	int *q;
	int *temp;
	char *s1;

	if (nargs < 2)
		return(EOF);

	q = p = &nargs;

	for (p += *p; p >= q; --p) {	/* reverse the list */
		temp = *p;
		*p = *q;
		*q++ = temp;
	}

	p = &nargs;
	q = p;
	p++;
	s1 = *p;
	p++;
	return(Xrscanf(NSTD, *q, s1, p));
}

#define	unsigned char *

#define MAXLINE 132	/* maximum length of text line */


/*
 *	Xrprintf -- does the formating work given the buffer
 *		AND the arguments in the proper order (reverse of SCC
 *		normal order).
 */

Xrprintf(line,args)
 char *line;
 int *args;
{
	register char * wptr;
	char Xuspr();
	char c, base, *sptr;
	char wbuf[MAXLINE], pf, ljflag;
	int width, precision;
	char leadch;
	char *format, *backup;
	char * wptr1;

	format = *args++;

	while ((c = *format++)) /* step through the format */
		if (c!='%')
			*line++ = c; /* just print normal characters */
		else {
			backup = format;
			wptr = wbuf;
			precision = 6;
			ljflag = pf = 0;

			if (*format == '-') { /* left justify this field */
			   ++format;
			   ++ljflag;
			}
			leadch = (*format=='0')? '0': ' '; /* normally blank-padding */



			width = Xgv2(&format);

			if ((c = *format++) == '.') {
				precision = Xgv2(&format);
				++pf;
				c = *format++;
			}
			c = toupper(c);
			if (c != 'S' && width == 0)
				++width;

			switch(c) { /* format type */

			case 'D':  if (*args < 0) { /* signed decimal */
				*wptr++ = '-';
				*args = -*args;
				--width;
			}

			case 'U':  base = 10; goto val; /* unsigned decimal */

			case 'X':  base = 16; goto val;

			case 'O':  base = 8;  /* note that arbitrary bases can be
				         added easily before this line */

				 val:
					wptr1 = wptr;
					width -= Xuspr(&wptr1,*args++,base);
					wptr = wptr1;
					goto pad;

			case 'C':  *wptr++ = *args++; /* character */
					--width;
					goto pad;

			case 'S':  if (!pf||precision>=MAXLINE) precision = MAXLINE-1;

					
					for(sptr = *args++;;--precision){
						if (*sptr==0)
							break;

						if (precision==0)
							break;

						if (wptr<wbuf+MAXLINE)
							*wptr++ = *sptr++;
						else
							++sptr;

						--width;
			  		}

			     pad:  *wptr = '\0';
			    		wptr = wbuf;
					if (!ljflag)
						while (--width >= 0)
							*line++ = leadch;

					while (*line++ = *wptr++);
						--line;

					if (ljflag)
						while (width-- > 0)
							*line++ = ' ';
					break;

			 default: *line++ = '%';
			 		format = backup;

		     }
	  }

	*line = '\0';
}

/*
	Internal routine used by "sprintf" to perform ascii-
	to-decimal conversion and update an associated pointer:
*/

int Xgv2(sptr)
int *sptr;
{
	register int n;
	char *ptr;

	n = 0;
	ptr = *sptr;
	while (isdigit(*ptr)) n = 10 * n + *ptr++ - '0';
	*sptr = ptr;
	return n;
}


/*
	Internal function which converts n into an ASCII
	base `base' representation and places the text
	at the location pointed to by the pointer pointed
	to by `string'. Yes, you read that correctly.
*/

char Xuspr(string, n, base)
 /*char **string*/
 int *string;
 unsigned n;
 char * base;
{
	register char * p;

	if (n<base) {
		p=*string;
		*p++ = n + ((n < 10) ? '0' : 'A'-10);
		*string = p;
		return 1;
	}

	return
	Xuspr(string, n/base, base)
		+
	Xuspr(string, n%base, base);
}

printf(nargs)
	int nargs;
{
	register int * p;
	int * q;
	int * temp;
	char line[MAXLINE];

	if (nargs < 1)
		return;
	q = p = &nargs;
	for (p += *p; p >= q; --p){
		temp = *p;
		*p = *q;
		*q++ = temp;
	}
	Xrprintf(line,&nargs);
	return puts(line);
}

/*
 * standard sprintf, reverse the arguments on the stack and call rprintf
 */

sprintf(nargs)
int nargs;
{
	register int *p;
	int *q;
	int *temp;
	char *l;

	if (nargs < 2)
		return;

	q = p = &nargs;	/* p and q point to start of argument list */

	for (p += *p; p >= q; --p) {	 /* set p to end of argument list */
		temp = *p;
		*p = *q;
		*q++ = temp;
	}

	p = &nargs;
	l = *p;
	Xrprintf(l, p+1);
}

/*
 * fprintf -- formatted print on output stream
 * just reverse the arguments and let rprintf do the work
 */

fprintf(nargs)
int nargs;
{
	register int *p;
	int *q;
	int *temp;
	char line[MAXLINE];

	if (nargs < 2)
		return;

	q = p = &nargs; /* start of argument list */

	for (p += *p; p >= q; --p) {  /* set p to end of list */
		temp = *p;
		*p = *q;
		*q++ = temp;
	}

	p = &nargs;
	Xrprintf(line, p+1);

	p = &nargs;
	return fputs(line, *p);
}

fputs(s, stream)
 char *s;
 FILE *stream;
{
	register char *ss;

	for(ss=s;*ss;)
		if(pputc(*ss++, stream)==ERROR)
			return ERROR;
	return s;
}

fgets(s, n, fd)
 char *s;
 unsigned n;
 FILE *fd;
{
	register int c;
	register char *cs;

	for(cs=s; --n>0;) {
		if((c=getc(fd))==EOF)
			return cs==s? NULL: s;

		if((*cs++=c)=='\n')
			break;
	}

	*cs = '\0';
	return s;
}
{	 /* set p to end of argument list */
		temp = *p;
		*p = *q;
		*q++ = temp;
	}