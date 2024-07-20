/*
	STDLIB2.C -- for BDS C v1.50 	12/29/82
	Copyright (c) 1982 by Leor Zolman

	This file contains the following library functions sources:

	printf 		lprintf	*	fprintf		sprintf		_spr
	scanf		fscanf		sscanf		_scn
	fgets
	puts		fputs
	swapin

	* --  << Not yet documented in the v1.50 User's Guide. >>

	Note:	The maximum output line length for all formatted output
		functions is now unlimited, due to some new technology,
		although the limit of any one "format conversion" is still
		MAXLINE characters.

*/

#include <bdscio.h>

#define DEV_LST 2		/* List device for lprintf */

char toupper(), isdigit();

printf(format)
char *format;
{
	int putchar();
	return _spr(&format, &putchar);	/* use "_spr" to form the output */
}

int lprintf(format)
char *format;
{
	int _fputc();
	return _spr(&format, &_fputc, DEV_LST);
}

sprintf(buffer,format)
char *buffer, *format;
{
	int _sspr();
	_spr(&format, &_sspr, &buffer);	/* call _spr to do all the work */
	*buffer = '\0';
}

_sspr(c,strptr)
char **strptr;
{
	*(*strptr)++ = c;
}

int fprintf(iobuf,format)
char *format;
FILE *iobuf;
{
	int _fputc();
	return _spr(&format, &_fputc, iobuf);
}

int _fputc(c,iobuf)
{
	if (c == '\n')
		if (putc('\r',iobuf) == ERROR)
			return ERROR;
	if (putc(c,iobuf) == ERROR)
		return ERROR;
	return OK;
}	

int scanf(format)
char *format;
{
	char line[MAXLINE];
	gets(line);			/* get a line of input from user */
	return _scn(line,&format);	/* and scan it with "_scn"	 */
}

int sscanf(line,format)
char *line, *format;
{
	return _scn(line,&format);	/* let _scn do all the work */
}


int fscanf(iobuf,format)
char *format;
FILE *iobuf;
{
	char text[MAXLINE];
	if (!fgets(text,iobuf))
		return ERROR;
	return _scn(text,&format);
}


_spr(fmt,putcf,arg1)
int (*putcf)();
char **fmt;
{
	char _uspr(), c, base, *sptr, *format;
	char wbuf[MAXLINE], *wptr, pf, ljflag, zfflag;
	int width, precision,  *args;

	format = *fmt++;    /* fmt first points to the format string	*/
	args = fmt;	    /* now fmt points to the first arg value	*/

	while (c = *format++)
	  if (c == '%') {
	    wptr = wbuf;
	    precision = 6;
	    ljflag = pf = zfflag = 0;

	    if (*format == '-') {
		    format++;
		    ljflag++;
	     }


	    if (*format == '0') zfflag++;	/* test for zero-fill */

	    width = (isdigit(*format)) ? _gv2(&format) : 0;

	    if ((c = *format++) == '.') {
		    precision = _gv2(&format);
		    pf++;
		    c = *format++;
	     }

	    switch(toupper(c)) {

		case 'D':  if (*args < 0) {
				*wptr++ = '-';
				*args = -*args;
				width--;
			    }

		case 'U':  base = 10; goto val;

		case 'X':  base = 16; goto val;

		case 'O':  base = 8;  /* note that arbitrary bases can be
				         added easily before this line */

		     val:  width -= _uspr(&wptr,*args++,base);
			   goto pad;

		case 'C':  *wptr++ = *args++;
			   width--;
			   goto pad;

		case 'S':  if (!pf) precision = 200;
			   sptr = *args++;
			   while (*sptr && precision) {
				*wptr++ = *sptr++;
				precision--;
				width--;
			    }

		     pad:  *wptr = '\0';
		     pad2: wptr = wbuf;
			   if (!ljflag)
				while (width-- > 0)
					if ((*putcf)(zfflag ? '0' : ' ',arg1)
						== ERROR) return ERROR;;

			   while (*wptr)
				if ((*putcf)(*wptr++,arg1) == ERROR) 
					return ERROR;

			   if (ljflag)
				while (width-- > 0)
					if ((*putcf)(' ',arg1) == ERROR)
						return ERROR;
			   break;

		case NULL:
			   return OK;

		default:   if ((*putcf)(c,arg1) == ERROR)
				return ERROR;
	     }
	  }
	  else if ((*putcf)(c,arg1) == ERROR)
			return ERROR;
	return OK;
}

/*
	Internal routine used by "_spr" to perform ascii-
	to-decimal conversion and update an associated pointer:
*/

int _gv2(sptr)
char **sptr;
{
	int n;
	n = 0;
	while (isdigit(**sptr)) n = 10 * n + *(*sptr)++ - '0';
	return n;
}

char _uspr(string, n, base)
char **string;
unsigned n;
{
	char length;
	if (n<base) {
		*(*string)++ = (n < 10) ? n + '0' : n + 55;
		return 1;
	}
	length = _uspr(string, n/base, base);
	_uspr(string, n%base, base);
	return length + 1;
}


/*
	General formatted input conversion routine:
*/

int _scn(line,fmt)
char *line, **fmt;
{
	char sf, c, base, n, *sptr, *format;
	int sign, val, **args;

	format = *fmt++;	/* fmt first points to the format string */
	args = fmt;		/* now it points to the arg list */

	n = 0;
	while (c = *format++)
	{
	   if (isspace(c)) continue;	/* skip white space in format string */
	   if (c != '%')		/* if not %, must match text */
	    {
		if (c != _igs(&line)) return n;
		else line++;
	    }
	   else		/* process conversion */
	    {
		sign = 1;
		base = 10;
		sf = 0;
		if ((c = *format++) == '*')
		 {
			sf++;		/* if "*" given, supress assignment */
			c = *format++;
		 }
		switch (toupper(c))
		 {
		   case 'X': base = 16;
			     goto doval;

		   case 'O': base = 8;
			     goto doval;

		   case 'D': if (_igs(&line) == '-') {
				sign = -1;
				line++;
			      }

	   doval:  case 'U': val = 0;
			     if (_bc(_igs(&line),base) == ERROR)
				return n;
			     while ((c = _bc(*line++,base)) != 255)
				val = val * base + c;
			     line--;
			     break;

		   case 'S': _igs(&line);
			     sptr = *args;
			     while (c = *line++)   {
				if (c == *format) {
					format++;
					break;
				 }
				if (!sf) *sptr++ = c;
			      }				
			     if (!sf) {
				n++;
				*sptr = '\0';
				args++;
			      }
			     continue;

		   case 'C': if (!sf) {
				poke(*args++, *line);
				n++;
			     }
			     line++;
			     continue;

		   default:  return n;
		 }
		if (!sf)
		 {
			**args++ = val * sign;
			n++;
		 }
	    }
	   if (!*line) return n;	/* if end of input string, return */
	}
	return n;
}

char _igs(sptr)
char **sptr;
{
	char c;
	while (isspace(c = **sptr)) ++*sptr;
	return (c);
}

int _bc(c,b)
char c,b;
{
	if (isalpha(c = toupper(c))) c -= 55;
         else  if (isdigit(c))  c -= 0x30;
	 else return ERROR;
	if (c > b-1) return ERROR;
		else return c;
}

puts(s)
char *s;
{
	while (*s) putchar(*s++);
}


char *fgets(s,iobuf)
char *s;
FILE *iobuf;
{
	int count, c;
	char *cptr;
	count = MAXLINE - 2;
	cptr = s;
	if ( (c = getc(iobuf)) == CPMEOF || c == EOF) return NULL;

	do {
		if ((*cptr++ = c) == '\n') {
		  if (cptr>s+1 && *(cptr-2) == '\r')
			*(--cptr - 1) = '\n';
		  break;
		}
	 } while (count-- && (c=getc(iobuf)) != EOF && c != CPMEOF);

	if (c == CPMEOF) ungetc(c,iobuf);	/* push back control-Z */
	*cptr = '\0';
	return s;
}


fputs(s,iobuf)
char *s;
FILE *iobuf;
{
	char c;
	while (c = *s++) {
		if (c == '\n') putc('\r',iobuf);
		if (putc(c,iobuf) == ERROR) return ERROR;
	}
	return OK;
}

swapin(name,addr)
char *name;
{
	int fd;
	if (( fd = open(name,0)) == ERROR)
		return ERROR;

	if ((read(fd,addr,512)) < 0) {
		close(fd);
		return ERROR;
	}

	close(fd);
	return OK;
}

