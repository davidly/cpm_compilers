

/*
	This file contains the source for the following
	library functions:

	printf	fprintf	sprintf
	scanf	fscanf	sscanf
	gets	fgets
	puts	fputs

	Note that all the upper-level formatted I/O functions
	("printf", "fprintf", "scanf", and "fscanf") now use
	"sprintf" and "sscanf" for doing conversions. While
	this leads to very structured source code, it also
	means that calls to "scanf" and "fscanf" must process
	ALL the information on a line of text; if the format
	string runs out and there is still text left in the
	line being processed, the text will be lost (i.e., the
	NEXT scanf or fscanf call will NOT find it.)

	Also note that temporary work space is declared within
	each of the high-level functions as a one-dimensional
	character array. The length limit on this array is
	presently set to 132 by the #define MAXLINE statement;
	if you intend to create longer lines through printf,
	fprintf, scanf, or fscanf calls, be SURE to raise this
	limit by changing the #define statement.

	Some misc. comments on hacking text files with CP/M:
	The conventional CP/M text format calls for each
	line to be terminated by a CR-LF combination. In the
	world of C programming, though, we like to just use
	a single LF (also called a newline) to terminate
	lines. AND SO, the functions which deal with reading
	and writing text from disk files to memory and vice-
	versa ("fgets", "fputs") take special pains to convert
	CR-LF combinations into single '\n' characters when
	reading from disk ("fgets"), and convert '\n' char-
	acters to CR-LF combinations when writing TO disk
	("fputs"). This allows the C programmer to do things
	in style, dealing only with a single line terminator,
	while maintaining compatibility with the CP/M text
	format (so that, for example, a text file can be
	"type"d under the CCP.)
	To confuse matters further, the "gets" function
	(which simply buffers up a line of console input)
	terminates a line with '\0' (a zero byte) instead
	of CR or LF. Thus, if you wanted to read in lines
	of input from the console and write them to a file,
	you'd have to manually put out the CR and LF at the
	end of every line. Oh, and don't forget the 0x1a
	(control-Z) at the end of the file! Hey, kiddies,
	isn't CP/M fun to work with???
	Also, watch out when reading in text files using
	"getc". While a text file is USUALLY terminated
	with a control-Z, it MAY NOT BE if the file ends
	on an even sector boundary. This means that there
	are two possible return values from "getc" which
	signal and EOF: 0x1a (control-Z), and -1 (or 255
	if you assign it to a char variable.)
*/


#define RAM 0		/* start of CP/M RAM area */
#define MAXLINE 132	/* maximum length of text line */
#define EOF -1		/* End of file val returned by getc */
#define NULL 0		/* Returned by fgets on EOF */

char toupper(), isdigit();

struct buf {
	int fd;
	int nleft;
	char *nextp;
	char buff[128];
 };

/*
	The standard (almost) formatted print function.
	This version differs from the UNIX C version in
	that all values come out LEFT justified within
	their fields, instead of right justified. Note
	that this version (new for BDS C v1.3) does have
	the %o (octal) conversion character. 
	usage:
		printf(format, arg1, arg2, ...);
*/

printf(format)
char *format;
{
	char line[MAXLINE];
	_mvl();
	sprintf(line,format);
	puts(line);
}


/*
	Like printf, except that the first argument is
	a pointer to a buffered I/O buffer, and the text
	is written to the file described by the buffer:
	(-1 returned on error)
	usage:
		fprintf(iobuf, format, arg1, arg2, ...);
*/

fprintf(iobuf,format)
char *format;
struct buf *iobuf;
{
	char text[MAXLINE];
	sprintf(text);
	return fputs(text,iobuf);
}


/*
	Like scanf, except that the first argument is
	a pointer to a buffered input file buffer, and
	the text is taken from the file instead of from
	the console.
	Usage:
		fscanf(iobuf, format, ptr1, ptr2, ...);
	Returns number of items matched (zero on EOF.)
	Note that any unprocessed text is lost forever. Each
	time scanf is called, a new line of input is gotten
	from the file, and any information left over from
	the last call is wiped out. Thus, the text in the
	file must be arranged such that a single call to
	fscanf will always get all the required data on a
	line.
*/

int fscanf(iobuf,format,arg1)
char *format;
struct buf *iobuf;
{
	char text[MAXLINE];
	if (!fgets(text,iobuf)) return 0;
	return sscanf(text,format,arg1);
}


/*
	This one accepts a line of input text from the
	console, and converts the text to the required
	binary or alphanumeric form (see Kernighan &
	Ritchie for a more thorough description):
	Usage:
		scanf(format, ptr1, ptr2, ...);
	Returns number of items matched.
	Since a new line of text must be entered from the
	console each time scanf is called, any unprocessed
	text left over from the last call is lost forever.
	This is a difference between BDS scanf and UNIX
	scanf. Another is that the field width specification
	is not supported here.
*/

scanf(format)
char *format;
{
	char line[MAXLINE];
	_mvl();
	gets(line);
	sscanf(line,format);
}


/*
	Internal function to move all function arguments
	over one place to the right, to make room for
	a new argument in the first position. This is
	necessary so that, for example, "sprintf" can
	be called from within "printf" without clobbering
	one of the arguments. This is NOT a portable
	feature of BDS C, and in fact represents one of
	the biggest kludges in the package. Oh well; live
	and learn.
*/

_mvl()
{
	int count, *ptr;
	ptr = (RAM + 0x3f7 + 0x2e);
	count = 23;
	while (count--) *ptr = *--ptr;
}


/*
	Like fprintf, except a string pointer is specified
	instead of a buffer pointer. The text is written
	to where the string pointer points.
	Usage:
		sprintf(string,format,arg1, arg2, ...);
*/

sprintf(line,format)
char *line, *format;
{
	char _uspr();
	int width, w2, *args;
	char c, base, *sptr;

	args = (RAM + 0x3fb);
	while ( c = *format++) if (c == '%') {
	   width = 1;
	   if (isdigit(c = *format)) {
		width = 0;
		while (isdigit(c = *format++))
			width = width * 10 + c - '0';
	    }
	   else format++;

	   switch (toupper(c)) {
		case 'D': if (*args < 0) {
			    *line++ = '-';
			    *args = -*args;
			    width--;
			  }
		case 'U': base = 10; goto val;
		case 'X': base = 16; goto val;
		case 'O': base =  8;
		    val:  w2 = _uspr(&line,*args++,base);
			  goto pad;
		case 'C': w2 = 1;
			  *line++ = *args++;
			  goto pad;
		case 'S': w2 = 0;
			  sptr = *args++;
			  while (*sptr) {
				*line++ = *sptr++;
				w2++;
			  }
		    pad:  w2 = width - w2;
			  while (w2-- > 0) *line++ = ' ';
			  break;
		default:  *line++ = c;
	   }
	}
	else *line++ = c;
	*line = '\0';
}


/*
	Internal function which converts n into an ASCII
	base `base' representation and places the text
	at the location pointed to by the pointer pointed
	to by `string'. Yes, you read that correctly.
*/

char _uspr(string, n, base)
char **string;
unsigned n;
{
	char length;
	if (n<base) {
		*(*string)++ = (n < 10) ? n + '0' : n + 87;
		return 1;
	}
	length = _uspr(string, n/base, base);
	_uspr(string, n%base, base);
	return length + 1;
}


/*
	Accept an input line from the console, and
	store it at the location pointed to by the
	character pointer argument.
	The newline is NOT included as part of the
	returned text; i.e., typing "abc" and hitting
	carriage-return will result in the string:
	"abc\0"
*/

gets(s)
char *s;
{
	char c, *temp;
	int count, i;
	temp = s;
start:	count = 0;
	s = temp;
	while ((c=getchar()) != '\n') 
	switch(c) {
	 case 0x15:
		putchar('\n');
		goto start;
	 case 0x7f:
		if (!count) break;
		--count;
		--s;
		putchar(0x08); putchar(' '); putchar(0x08);
		break;
	 case 0x12:
		putchar('\n');
		for (i=0; i<count; ++i) putchar(temp[i]);
		break;
	 default:
		*s++ = c;
		++count;
	}
	*s = 0;
	return temp;
}


/*
	Write out the given string to the console:
*/

puts(s)
char *s;
{
	while (*s) putchar(*s++);
}


/*
	This next function is like "gets", except that
	the line is taken from a buffered input file instead
	of from the console. This one is a little tricky
	due to the CP/M convention of having a carriage-
	return AND a linefeed character at the end of every
	text line. In order to make text easier to deal with
	under C programs, this function (fgets) automatically
	strips off the CR from any CR-LF combinations that
	come in from the file. Any CR characters not im-
	mediately followed by LF are left intact. The LF
	is included as part of the string, and is followed
	by a null byte.
	Note that there is no limit to how long a line
	can be here; care should be taken to make sure the
	string pointer passed to fgets points to an area
	large enough to accept any possible line length
	(a line must be terminated by a newline (LF, or '\n')
	character before it is considered complete.)

	The value NULL (defined to be 0 here) is returned
	on EOF, but only on PHYSICAL EOF (after the entire
	last sector has been processed.) Because there is
	no push-back mechanism for simple buffered I/O in
	BDS C, remembering that a control-Z has been hit
	so that EOF can be returned on the next call to
	fgets would require some external state information;
	If you want this feature (and it IS kinda useful),
	I suggest you create a new version of fgets that
	stores logical-EOF information in an external
	variable, and put the new function into the "main"
	source file of the program that needs to use it.
	The other library functions that use fgets should
	still work OK with the new version you create.
	An alternative approach to this problem might be to
	just keep the first line of the file reserved for
	a line count, so you know exactly how many lines of
	text there are in the file.
	(Actually, this problem would go away if I had
	 static variables to play with...time to go to
	 work on version 2.0....)
*/

char *fgets(s,iobuf)
char *s;
struct buf *iobuf;
{
	int count, c;
	char *cptr;
	count = (MAXLINE + 1);
	cptr = s;
	while (count-- && (c = getc(iobuf)) != EOF
		       && (c != 0x1a))
		if ((*cptr++ = c) == '\n') {
		  if (cptr>s+1 && *(cptr-2) == '\r') {
			*(cptr-2) = '\n';
			cptr--;
		   }
		  break;
		}
	*cptr = '\0';
	return (( c == EOF && cptr == s) ? NULL : s);
}



/*
	This function writes a string out to a buffered
	output file. The '\n' character is expanded into
	a CR-LF combination, in keeping with the CP/M
	convention.
	If a null ('\0') byte is encountered before a
	newline is encountered, then there will be NO
	automatic termination character appended to the
	line.
	-1 returned on error.
*/

fputs(s,iobuf)
char *s;
struct buf *iobuf;
{
	char c;
	while (c = *s++) {
		if (c == '\n') putc('\r',iobuf);
		if (putc(c,iobuf) == -1) return -1;
	}
	return 0;
}

/*
	This is the formatted input scanner, taking a
	text string, a format string and a list of pointer
	arguments, appropriate data is picked up from the
	text string and stored where the pointer arguments
	point according to the format string. See K&R.
	Note that the field width specification is not
	supported by this version.
*/

sscanf(line,format)
char *line, *format;
{
	char sf, c, base, n, *sptr;
	int sign, val, **args;
	args = (RAM + 0x3fb);
	n = 0;
	while (c = *format++) {
	   if (isspace(c)) continue;
	   if (c != '%') {
		if (c != _igs(&line)) return n;
		else line++;
	    }
	   else {
		sign = 1;
		base = 10;
		sf = 0;
		if ((c = *format++) == '*') {
			sf++;
			c = *format++;
		 }
		switch (toupper(c)) {
		   case 'X': base = 16;
			     goto doval;
		   case 'O': base = 8;
			     goto doval;
		   case 'D': if (_igs(&line) == '-') {
				sign = -1;
				line++;
			      }
	   doval:  case 'U': val = 0;
			     if (_bc(_igs(&line),base)== -1)
				return n;
			     while ((c=_bc(*line++,base))!=255)
				val = val * base + c;
			     line--;
			     break;
		   case 'S': _igs(&line);
			     sptr = *args;
			     while ((c=*line++)&& !isspace(c))
				if (!sf) *sptr++ = c;
			     if (!sf) {
				n++;
				*sptr = '\0';
				args++;
				continue;
			      }
		   case 'C': if (!sf) {
				poke(*args++, *line);
				n++;
			     }
			     line++;
			     continue;
		   default:  return n;
		 }
		if (!sf) {
			**args++ = val * sign;
			n++;
		 }
	}}
	return n;
}

/*
	Internal function to position the character
	pointer argument to the next non white-space
	character in the string:
*/

_igs(sptr)
char **sptr;
{
	char c;
	while (isspace(c = **sptr)) ++*sptr;
	return (c);
}


/*
	Internal function to convert character c to value
	in base b , or return -1 if illegal character for that
	base:
*/

_bc(c,b)
char c,b;
{
	if ((c = toupper(c)) > '9') c -= 55;
			     else   c -= 0x30;
	return (c > b-1) ? -1 : c;
}

