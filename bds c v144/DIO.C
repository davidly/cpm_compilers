/*
	Directed I/O package for use with BDS C v1.4x.   LZ -- 4/81

	The following functions make up the directed I/O library:

	1. dioinit(&argc,argv)		Make this the first thing you do in
					your "main" function, to process
					redirection commands on the CP/M
					command line.

	2. getchar()			Gets a character from the keyboard,
					or from a directed input file if one
					was specified on the command line.

	3. putchar(c)			Puts a character out to the console,
					or to a directed output file if one
					was specified on the command line.

	4. dioflush()			Flushes directed output file, if open,
					and closes all directed I/O files (if
					any.) This must be called before your
					program exits or returns to CP/M.

	To activate redirection: Four special arguments may be given
	on the command line to the generated COM file...

		>foo	causes "putchar" to place characters into the file
			named "foo" instead of to the console.

		+foo	like >foo except that the characters are ALSO sent
			to the console.

		<foo	causes "getchar" to return characters from the file
			named "foo" instead of from the keyboard.

	 command |prog	causes the standard output of the command specified in
			"command" to be fed into the standard input of another
			program, "prog". (BOTH "command" and "prog" must be
			compiled with DIO)

	 (Note that there must never be any spaces between >,+,< or | and the
	  corresponding filename.)

	Thus, a C program using redirection has the following form:

		#include "bdscio.h"		/* standard header file	*/
		#include "dio.h"		/* directed I/O header	*/

		...				/* other externals, if any */

		main(argc,argv)
		char **argv;
		{
			...			/* declarations		*/
			dioinit(&argc,argv)	/* initialize redirection */
			...			/* body of program	*/
			dioflush();
		}
			
	NOTES:

	0. Redirection and pipes work only for TEXT. This mechanism should
	   not be used for binary data.

	1. The "getchar" and "putchar" functions should each be used EXPLICITLY
	   at least once in your main source file, so that the correct versions
	   are picked off from DIO.CRL instead of the incorrect ones from
	   DEFF2.CRL (because of the way the linker works.)

	2. The "putc" library function should be modified so that an iobuf
	   value of 4 sends a character to the CP/M console via a "bdos"
	   call (as opposed to using "putchar"), and that a '\n' character
	   thus sent should be expanded into a CR-LF combination. This
           is easily accomplished by adding the following clause to the "putc"
	   function, recompiling STDLIB1.C, and updating DEFF.CRL by
	   transferring in the new "putc" with CLIB.COM:

		if (_iobuf == 4) {
			if (c == '\n') bdos(2,'\r');
			bdos(2,c);
		}			
	   (This may already have been done in the version you have.)

	3. The "execv" function, used by this package, is available in the
	   file EXECV.ASM; it should be assembled, renamed EXECV.CRL, and
	   then transferred into DEFF2.CRL using CLIB.COM.
	   (This may already have been done in the version you have.)

*/

#include "bdscio.h"
#include "dio.h"

#define CON_INPUT 1			/* BDOS call to read console	   */
#define CON_OUTPUT 2			/* BDOS call to write to console   */
#define CON_STATUS 11			/* BDOS call to interrogate status */

#define CONTROL_C 3			/* Quit character		   */
#define STDERR 4			/* Standard Error descriptor (sorry,
					   Unix fans, 2 was already used.) */
#define INPIPE 2			/* bit setting to indicate directed
					   input from a temp. pipe fil     */
#define VERBOSE 2			/* bit setting to indicate output is to
					   go to console AND directed output */

/* 
	The "dioinit" function must be called at the beginning of the
	"main" function:
*/

#define argc *argcp

dioinit(argcp,argv)
int *argcp;
char **argv;
{
	int i,j, argcount;

	_diflag = _doflag = _pipef = FALSE;  /* No directed I/O by default   */
	_nullpos = &argv[argc];
	argcount = 1;

	for (i = 1; i < argc; i++)	/* Scan the command line for > and < */
	{
		if (_pipef) break;
		switch(*argv[i]) {

		   case '<':		/* Check for directed input: */
			if (!argv[i][1]) goto barf;
			if (fopen(&argv[i][1], _dibuf) == ERROR)
			{
				fprintf(STDERR,"Can't open %s\n",&argv[i][1]);
				exit();
			}
			_diflag = TRUE;
			if (strcmp(argv[i],"<TEMPIN.$$$") == 0)
				 _diflag |= INPIPE;
			goto movargv;

		   case '|':	/* Check for pipe: */
			_pipef++;
			_pipedest = &argv[i][1]; /* save prog name for execl */
			if (argv[i][1]) 
			{
				argv[i] = ".TEMPOUT.$$$";  /* temp. output */
				_savei = &argv[i];
			}
			goto foo;

		   case '+': 
			_doflag |= VERBOSE;
			
	     foo:   case '>':	/* Check for directed output	*/
		
			if (!argv[i][1]) 
			{
		    barf:   fprintf(STDERR,"Bad redirection/pipe specifier");
			    exit();
			}
			unlink(&argv[i][1]);
			if (fcreat(&argv[i][1], _dobuf) == ERROR)
			{
			       fprintf(STDERR,"Can't create %s\n",&argv[i][1]);
			       exit();
			}
			_doflag++;

	     movargv:	if (!_pipef) {
				for (j = i; j < argc; j++) argv[j] = argv[j+1];
				(argc)--;
				i--;
				_nullpos--;
			 } else {
				argc = argcount;
				argv[argc] = 0;
			 }
			break;

		    default:	/* handle normal arguments: */
			argcount++;
		}
	}
}


#undef argc

/*
	The "dioflush" function must be called before exiting the program:
*/

dioflush()
{
	if (_diflag)
	{
		fclose(_dibuf);
		if (_diflag & INPIPE) unlink("tempin.$$$");
	}

	if (_doflag)
	{
		putc(CPMEOF,_dobuf);
		fflush(_dobuf);
		fclose(_dobuf);
		rename("tempout.$$$","tempin.$$$");
		if (_pipef) 
		{
			*_savei = "<TEMPIN.$$$";
			*_nullpos = NULL;
			execv(_pipedest,_savei);
		}
	}
}


/*
	This version of "getchar" replaces the regular version when using
	directed I/O:
*/

getchar()
{
	char c;

	if (_diflag) {
		if ((c = getc(_dibuf)) == '\r') c = getc(_dibuf);
	} else
		if ((c = bdos(CON_INPUT)) == CONTROL_C) exit();

	if (c == CPMEOF) return EOF;	     /* Control-Z is EOF key 	*/
	if (c == '\r') 
	{
		c = '\n';
		if (!_diflag) bdos(2,'\n');  /* echo LF after CR to console */
	}
	return c;
}


/*
	This version of "putchar" replaces the regular version when using
	directed I/O:
*/

putchar(c)
char c;
{
	if (_doflag)
	{
		if (c == '\n') putc('\r',_dobuf);
		if(putc(c,_dobuf) == ERROR)
		{
			fprintf(STDERR,"File output error; disk full?\n");
			exit();
		}
		if (!(_doflag & VERBOSE)) return;
	}

	if (bdos(CON_STATUS) && bdos(CON_INPUT) == CONTROL_C) exit();
	if (c == '\n') bdos(CON_OUTPUT,'\r');
	bdos(CON_OUTPUT,c);
}
