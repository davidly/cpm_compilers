/************************************************/
/*						*/
/*		small-c compiler		*/
/*						*/
/*		  by Ron Cain			*/
/*	      and James Van Zandt		*/
/*						*/
/************************************************/

#define VERSION "     2 August 1984"
/*	history...
		2 Aug 84  Allocating symbol table and literal
			pool from heap.
		31 Jul 84  No GLOBAL directives for macros.
		30 Jul 84  Input file extension capitalized.
 		29 Jul 84  Displaying input file names.
		28 Jul 84  Getting file names and options from
			command line.
		14 Jul 84  outdec() is now recursive & smaller.
			raise() not called, since ZMAC converts
			to upper case. When profiling, the
			appropriate GLOBAL statements are
			automagically emitted.
		28 Jun 84  Adding CR after GLOBAL statement.
		25 Jun 84  In addglb(), generating GLOBAL
	statement. Generating 9 character labels (so 1st 8
	characters in a c symbol name are significant).
	Allowing 800 bytes of literals per function.
		2 Sept 83  In doreturn(), changed 'ccleavin'
	to 'ccleavi'.  Introduced 'leave'. 'numeric' &
	'outbyte' optimized. Optimized: 'nch', 'gch', 'keepch',
	'streq', 'astreq', 'raise'.
		1 Sept 83  Initializing firstfct & lastfct
	after calling ask().  Trace & profile enabled together.
		27 Aug 83  Allowing 3 bytes for call count.
		26 Aug 83  renamed: leaving => ccleavi,
	registe => ccregis. Added code to link the call count
	cells (main, header, trailer, newfunction).
		22 Aug 83  converted "," to "'", corrected
	loading of name pointer.
		21 Aug 83  Trace and profile are available.
	Using clibv.h & a:float.h
		1 Aug 83  6 function names are now
	"nospread", A now set to # words on stack rather
	than adding another parameter. 
		29 Mar 83  "callfunction" now reserves
	symsize bytes rather than namesize bytes for sym.
	When "printf" is called, the top word on the stack
	points to the first argument.
		7 Mar 83  "callfunction" now adds pointer
	to first argument for nospread functions. "nospread"
	introduced (returns true only for "printf").
		10 Nov 82  Rewrote "an" for speed.
		24 Oct 82  In "preprocess", searching macro
	table only with strings beginning with alpha. (Allows
	long numeric literals.) Rewrote "alpha" for speed.
		10 Oct 82  Updated date in signon message.
	Coersing function values to proper type.
		4 Sept 82  Generating colons again.
		3 Sep 82  "#includ"ing floating point
	library.
		30 Aug 82  Changed "number" calling sequence
	back. Colons are optional.
		12 Aug 82  Changed "number" calling sequence.
		11 Aug 82  Allowing typed function
	declarations.
		7 Aug 82  Correct length of double in
	local variables, preserving calling addr when
	calling through TOS & using double argument.
		5 Aug 82 Started installing floating point
		3 Aug 82	generating no colons
	after labels. Generating only 7 character labels.
		20 Jul 82	Removed the unused
	variable "iptr".
		18 Jul 82	Changed comment
	recognizer per J. E. Hendrix (ddj n56 p6).
		17 Jul 82	Implemented \" and
	\' sequences.  Corrected newfunc & getarg per
	P. L. Woods (ddj n52 p32) & J. E. Hendrix (ddj n56 p6).
		14 Jul 82	"#include"ing
	clibv.asm & c80v-2.c
		28 Jun 82	Skipping first byte
	in macro table, so index won't be zero.
		27 Jun 82	Masking out high
	order bits of characters extracted from
	a symbol table entry.
		21 Jun 82	Dumping literals
	at end of each function, per Rodney Black
	(DDJ n61 p51).
		19 Jun 82	Updated symtabsiz.
	Updated dumpglbs to handle new symbol table.
	Placing macro names in global symbol table,
	using smaller macro table.
		16 Jun 82	using hash table
	for global symbols.
		18 Apr 81	Changed names so
	first 5 characters are unique:
	heir10 => heira		heir11 => heirb
	input2 => inpt2		errorsum => errsum
*/
#include iolib.h
#include float.h

#define BANNER  "* * *  Small-C  V1.2  * * *"

#define AUTHOR "       By Ron Cain  and  James Van Zandt"

/*	Define system dependent parameters	*/

/*	Stand-alone definitions			*/

#define NULL 0
#define EOL 13

/*	UNIX definitions (if not stand-alone)	*/

/* #include <stdio.h>	*/
/* #define EOL 10	*/

/*	Define the symbol table parameters	*/

#define	SYMSIZ	14
#define	SYMTBSZ	8008
/*			=14*(NUMGLBS+60)	*/
#define NUMGLBS 512
#define MASKGLBS 511
/*			formerly 300 globals	*/
#define	STARTGLB symtab
#define	ENDGLB	STARTGLB+NUMGLBS*SYMSIZ
#define	STARTLOC ENDGLB+SYMSIZ
#define	ENDLOC	symtab+SYMTBSZ-SYMSIZ

/*	Define symbol table entry format	*/

#define	name	0
#define	ident	9
#define	type	10
#define	storage	11
#define	offset	12

/*	System wide name size (for symbols)	*/

#define	namesize 9
#define namemax  8

/*	Define possible entries for "ident"	*/

#define	variable 1
#define	array	2
#define	pointer	3
#define	function 4
#define MACRO 5
			/* added 6/19/82, JRVZ */

/*	Define possible entries for "type"	*/

#define	cchar	1
#define	cint	2
#define DOUBLE	3

/*	Define possible entries for "storage"	*/

#define	statik	1
#define	stkloc	2

/*	Define the "while" statement queue	*/

#define	wqtabsz	100
#define	wqsiz	4
#define	wqmax	wq+wqtabsz-wqsiz

/*	Define entry offsets in while queue	*/

#define	wqsym	0
#define	wqsp	1
#define	wqloop	2
#define	wqlab	3

/*	Define the literal pool			*/

#define	litabsz 1000
/*		formerly 2000			*/
#define	litmax	litabsz-1

/*	Define the input line			*/

#define	linesize 80
#define	linemax	linesize-1
#define	mpmax	linemax

/*	Define the macro (define) pool		*/

#define	macqsize 500
/*			formerly 1000   JRVZ 6/19/82  */
#define	macmax	macqsize-1

/*	Define statement types (tokens)		*/

#define	stif	1
#define	stwhile	2
#define	streturn 3
#define	stbreak	4
#define	stcont	5
#define	stasm	6
#define	stexp	7

/* Define how to carve up a name too long for the assembler */

#define ASMPREF	8
#define ASMSUFF	0

/*	Now reserve some storage words		*/

char	*symtab;		/* symbol table */
char	*glbptr,*locptr;	/* ptrs to next entries */

int	wq[wqtabsz];		/* while queue */
int	*wqptr;			/* ptr to next entry */

char	*litq;			/* literal pool */
int	litptr;			/* ptr to next entry */

char	macq[macqsize];		/* macro string buffer */
int	macptr;			/* and its index */

char	line[linesize];		/* parsing buffer */
char	mline[linesize];	/* temp macro buffer */
int	lptr,mptr;		/* ptrs into each */

/*	Misc storage	*/

int	nxtlab,		/* next avail label # */
	litlab,		/* label # assigned to literal pool */
	Zsp,		/* compiler relative stk ptr */
	undeclared,	/* # function arguments
			not yet declared  jrvz 8/6/82 */
	ncmp,		/* # open compound statements */
	errcnt,		/* # errors in compilation */
	errstop,	/* stop on error			gtf 7/17/80 */
	eof,		/* set non-zero on final input eof */
	input,		/* iob # for input file */
	output,		/* iob # for output file (if any) */
	inpt2,		/* iob # for "include" file */
	glbflag,	/* non-zero if internal globals */
	ctext,		/* non-zero to intermix c-source */
	cmode,		/* non-zero while parsing c-code */
			/* zero when passing assembly code */
	lastst,		/* last executed statement type */
	mainflg,	/* output is to be first asm filegtf 4/9/80 */
	saveout,	/* holds output ptr when diverted to console	   */
			/*				gtf 7/16/80 */
	fnstart,	/* line# of start of current fn.gtf 7/2/80 */
	lineno,		/* line# in current file	gtf 7/2/80 */
	infunc,		/* "inside function" flag	gtf 7/2/80 */
	savestart,	/* copy of fnstart "	"	gtf 7/16/80 */
	saveline,	/* copy of lineno  "	"	gtf 7/16/80 */
	saveinfn,	/* copy of infunc  "	"	gtf 7/16/80 */
	trace,		/* nonzero if traceback info needed
						jrvz 8/21/83	*/
	profile,	/* nonzero if profile needed	  */
	caller,		/* stack offset for caller links...
		local[caller] points to name of current fct
		local[caller-1] points to link for calling fct,
		where local[0] is 1st word on stack after ret addr  */
	firstfct,	/* label for 1st function */
	lastfct,	/* label for most recent fct  jrvz 8/83 */
	fname;		/* label for name of current fct  */
char   *currfn,		/* ptr to symtab entry for current fn.	gtf 7/17/80 */
       *savecurr;	/* copy of currfn for #include		gtf 7/17/80 */
char	quote[2];	/* literal string for '"' */
char	*cptr;		/* work ptr to any char buffer */

/*	>>>>> start cc1 <<<<<<		*/

/*					*/
/*	Compiler begins execution here	*/
/*					*/
main()
	{
	litq=alloc(litabsz);	/* literal pool */
	symtab=alloc(SYMTBSZ);	/* allocate symbol table */
	glbptr=STARTGLB;
	while(glbptr<ENDGLB){
		*glbptr=0;
		glbptr=glbptr+SYMSIZ;
	}
	glbptr=STARTGLB+SYMSIZ*5; /* clear global symbols */
	locptr=STARTLOC;	/* clear local symbols */
	wqptr=wq;		/* clear while queue */
	litptr=		/* clear literal pool */
  	Zsp =		/* stack ptr (relative) */
	errcnt=		/* no errors */
	errstop=	/* keep going after an error		gtf 7/17/80 */
	eof=		/* not eof yet */
	input=		/* no input file */
	inpt2=		/* or include file */
	output=		/* no open units */
	saveout=	/* no diverted output */
	ncmp=		/* no open compound states */
	lastst=		/* not first file to asm  gtf 4/9/80 */
	fnstart=	/* current "function" started
				at line 0 gtf 7/2/80 */
	lineno=		/* no lines read from file		gtf 7/2/80 */
	infunc=		/* not in function now			gtf 7/2/80 */
	quote[1]=
	0;		/*  ...all set to zero.... */
	quote[0]='"';		/* fake a quote literal */
	currfn=NULL;	/* no function yet			gtf 7/2/80 */
	macptr=		/* clear macro pool   jrvz 6/28/82 */
	cmode=1;	/* enable preprocessing */
	/*				*/
	/*	compiler body		*/
	/*				*/
	ask();			/* get user options */
	lastfct=firstfct=getlabel(); /* jrvz 8/26/83 */
	openout();		/* get an output file */
	openin();		/* and initial input file */
	header();		/* intro code */
	parse(); 		/* process ALL input */
/*	dumplits();		deleted 6/21/82  jrvz */
	dumpglbs();		/* define static variables */
	trailer();		/* follow-up code */
	closeout();		/* close the output (if any) */
	errsummary();		/* summarize errors */
	return;			/* then exit to system */
	}

/*					*/
/*	Abort compilation		*/
/*		gtf 7/17/80		*/
abort()
{
	if(inpt2)
		endinclude();
	if(input)
		fclose(input);
	closeout();
	toconsole();
	pl("Compilation aborted.");  nl();
	exit();
/* end abort */}

/*					*/
/*	Process all input text		*/
/*					*/
/* At this level, only static declarations, */
/*	defines, includes, and function */
/*	definitions are legal...	*/
parse()
	{
	while (eof==0)		/* do until no more input */
		{
		if(amatch("char",4)){declglb(cchar);ns();}
		else if(amatch("int",3)){declglb(cint);ns();}
		else if(amatch("double",6))  /* jrvz 8/5/82 */
			{declglb(DOUBLE);ns();}
		else if(match("#asm"))doasm();
		else if(match("#include"))doinclude();
		else if(match("#define"))addmac();
		else newfunc();
		blanks();	/* force eof if pending */
		}
	}
/*					*/
/*	Dump the literal pool		*/
/*					*/
dumplits()
	{int j,k;
	if (litptr==0) return;	/* if nothing there, exit...*/
	printlabel(litlab);col(); /* print literal label */
	k=0;			/* init an index... */
	while (k<litptr)	/* 	to loop with */
		{defbyte();	/* pseudo-op to define byte */
		j=10;		/* max bytes per line */
		while(j--)
			{outdec((litq[k++]&255));
			/* now masking with 255 instead of 127
			so floating constants can be put
			in the literal pool  jrvz 9/4/82 */
			if ((j==0) | (k>=litptr))
				{nl();		/* need <cr> */
				break;
				}
			outbyte(',');	/* separate bytes */
			}
		}
	}
/*					*/
/*	Dump all static variables	*/
/*					*/
dumpglbs()
	{
	int i,j;
	if(glbflag==0)return;	/* don't if user said no */
	cptr=STARTGLB;
	i=NUMGLBS;
	while(i--){  /* 6/19/82  jrvz */
	    if(*cptr){
		if((cptr[ident]!=function)
		&(cptr[ident]!=MACRO))  /* 6/19/82  jrvz */
			/* do if anything but function
				or macro */
			{outname(cptr);col();
				/* output name as label... */
			defstorage();	/* define storage */
			j=((cptr[offset]&255)+
				((cptr[offset+1]&255)<<8));
					/* calc # bytes */
			if((cptr[type]==cint)|
				(cptr[ident]==pointer))
				j=j+j;
			else if(cptr[type]==DOUBLE)
				j=j*6;  /* jrvz 8/5/82 */
			outdec(j);	/* need that many */
			nl();
			}
		}
	    cptr=cptr+SYMSIZ;
	    }
	}
/*					*/
/*	Report errors for user		*/
/*					*/
errsummary()
	{
	/* see if anything left hanging... */
	if (ncmp) error("missing closing bracket");
		/* open compound statement ... */
	nl();
	outstr("There were ");
	outdec(errcnt);	/* total # errors */
	outstr(" errors in compilation.");
	nl();
	}

int argcnt,		/* # arguments on command line */
filenum,	/* next argument to be used */
argv[20];	/* pointers to arguments in args[] */
char *args;	/* stored arguments */

nextarg(n,s,size) /* places in s the n-th argument (up to "size"
		bytes). If successful, returns s. Returns -1
		if the n-th argument doesn't exist. */
int n; char *s; int size;
{	char *str;
	int i;

	if(n<0|n>=argcnt) return -1;
	i=0;
	str=argv[n];
	while(++i<size)
		{if((*s++=*str++)==NULL) break;
		}
	return s;
}
ask()		/* fetch arguments */
{	char *count,	/* *count is # characters in command line */
	c,	/* an option character */
	*ptr,	/* *ptr is next character in command line */
	*lastc,	/* points to last character in command line */
	*next;	/* where the next byte goes in args[] */

	kill();			/* clear input line */
	pl(BANNER);		/* print banner */
	nl();
	pl(AUTHOR);
/*	nl();nl();
	pl("Distributed by: The Code Works(tm)");
	pl("                Box 550, Goleta, CA 93017");
*/
	nl();
	pl(VERSION);
	nl();
	nl();
	nxtlab =0;	/* start numbers at lowest possible */
		/* initialize the options */
	ctext=0;	/* don't include the C text as comments */
	glbflag=1;	/* define globals */
	mainflg=1;	/* this file contains main() */
	errstop=0;	/* don't stop after errors */
	profile=trace=0; /* no profile or tracing */
	count=128;	/* CP/M command buffer */
	ptr=count+1;
	lastc=ptr+*count;
	*lastc=' ';		/* place a sentinal */
	args=alloc(*count);	/* allocate the buffer */
	argv[0]=args;
	next=args;
	argcnt=0;
	while(++ptr<lastc)
		{if(*ptr==' ') continue;
		if(*ptr=='-')		/* option */
			{c=*++ptr;
			if(c=='C') ctext=1;
			else if(c=='G') glbflag=0;
			else if(c=='M') mainflg=0;
			else if(c=='E') errstop=1;
			else if(c=='P') profile=trace=1;
			while(++*ptr!=' ') {}
			}
		else			/* file name */
			{argv[argcnt++]=next;
			while(*ptr!=' ') *next++=*ptr++;
			*next++=NULL;
			}
		}
	litlab=getlabel();	/* first label=literal pool */ 
	kill();			/* erase line */
}
 
/*					*/
/*	Get output filename		*/
/*					*/
openout()
	{kill();		/* erase line */
	filenum=output=0;	/* start with none */
	if(nextarg(filenum,line,16)==-1) return;
	append(line,".asm");
	if((output=fopen(line,"w"))==NULL) /* if given, open */
		{output=0;	/* can't open */
		error("Can't open output file!");
		}
	kill();			/* erase line */
}

/*					*/
/*	Get (next) input file		*/
/*					*/
openin()
{
	input=0;		/* none to start with */
	while(input==0){	/* any above 1 allowed */
		kill();		/* clear line */
		if(eof)break;	/* if user said none */
		if(nextarg(filenum++,line,16)==-1)
			{eof=1;break;} /* none given... */
		append(line,".C");
		pl(line); pl("\n");
		if((input=fopen(line,"r"))!=NULL)
			newfile();	/* gtf 7/16/80 */
		else {	input=0;	/* can't open it */
			pl("CAN'T OPEN ");
			}
		}
	kill();		/* erase line */
	}

append(s,t) char *s,*t;	/* append t to s */
{	while(*s) ++s;		/* scan to end of s */
	while(*s++=*t++){}	/* append t */
}

/*					*/
/*	Reset line count, etc.		*/
/*			gtf 7/16/80	*/
newfile()
{
	lineno  = 0;	/* no lines read */
	fnstart = 0;	/* no fn. start yet. */
	currfn  = NULL;	/* because no fn. yet */
	infunc  = 0;	/* therefore not in fn. */
/* end newfile */}

/*					*/
/*	Open an include file		*/
/*					*/
doinclude()
{
	blanks();	/* skip over to name */

	toconsole();					/* gtf 7/16/80 */
	outstr("#include "); outstr(line+lptr); nl();
	tofile();

	if(inpt2)					/* gtf 7/16/80 */
		error("Cannot nest include files");
	else if((inpt2=fopen(line+lptr,"r"))==NULL)
		{inpt2=0;
		error("Open failure on include file");
		}
	else {	saveline = lineno;
		savecurr = currfn;
		saveinfn = infunc;
		savestart= fnstart;
		newfile();
		}
	kill();		/* clear rest of line */
			/* so next read will come from */
			/* new file (if open */
}

/*					*/
/*	Close an include file		*/
/*			gtf 7/16/80	*/
endinclude()
{
	toconsole();
	outstr("#end include"); nl();
	tofile();

	inpt2  = 0;
	lineno  = saveline;
	currfn  = savecurr;
	infunc  = saveinfn;
	fnstart = savestart;
/* end endinclude */}

/*					*/
/*	Close the output file		*/
/*					*/
closeout()
{
	tofile();	/* if diverted, return to file */
	if(output)fclose(output); /* if open, close it */
	output=0;		/* mark as closed */
}
/*					*/
/*	Declare a static variable	*/
/*	  (i.e. define for use)		*/
/*					*/
/* makes an entry in the symbol table so subsequent */
/*  references can call symbol by name	*/
declglb(typ)	/* typ is cchar, cint or DOUBLE jrvz 8/5/82 */
	int typ;
{	int k,j;char sname[namesize];
	while(1)
		{while(1)
			{if(endst())return;	/* do line */
			k=1;		/* assume 1 element */
			if(match("*"))	/* pointer ? */
				j=pointer;	/* yes */
				else j=variable; /* no */
			 if (symname(sname)==0) /* name ok? */
				illname(); /* no... */
			if(findglb(sname)) /* already there? */
				multidef(sname);
			if (match("["))		/* array? */
				{k=needsub();	/* get size */
				if(k)j=array;	/* !0=array */
				else j=pointer; /* 0=ptr */
				}
			if (match("("))	/* function?  */
				{k=0;
				j=function;
				needbrack(")");
				}	/* jrvz 8/11/82 */
			addglb(sname,j,typ,k); /* add symbol */
			break;
			}
		if (match(",")==0) return; /* more? */
		}
	}
/*					*/
/*	Declare local variables		*/
/*	(i.e. define for use)		*/
/*					*/
/* works just like "declglb" but modifies machine stack */
/*	and adds symbol table entry with appropriate */
/*	stack offset to find it again			*/
declloc(typ)	/* typ is cchar, cint or DOUBLE jrvz 8/5/82 */
	int typ;
	{
	int k,j;char sname[namesize];
	while(1)
		{while(1)
			{if(endst())return;
			if(match("*"))
				j=pointer;
				else j=variable;
			if (symname(sname)==0)
				illname();
			if(findloc(sname))
				multidef(sname);
			if (match("["))
				{k=needsub();
				if(k)
				    {j=array;
				    if(typ==cint)k=k+k;
				    else if(typ==DOUBLE)k=k*6;
				    /* jrvz 8/5/82 */
				    }
				else
				    {j=pointer;
				    k=2;
				    }
				}
			else
			    if((typ==cchar)&(j!=pointer))
				k=1;
			    else if((typ==DOUBLE)&(j!=pointer))
				k=6;	/* jrvz 8/7/82 */
			    else k=2;
			/* change machine stack */
			Zsp=modstk(Zsp-k);
			addloc(sname,j,typ,Zsp);
			break;
			}
		if (match(",")==0) return;
		}
	}
/*	>>>>>> start of cc2 <<<<<<<<	*/

/*					*/
/*	Get required array size		*/
/*					*/
/* invoked when declared variable is followed by "[" */
/*	this routine makes subscript the absolute */
/*	size of the array. */
needsub()
	{
	int num[1];
	if(match("]"))return 0;	/* null size */
	if (number(num)==0)
			/* go after a number */
		{error("must be constant");	/* it isn't */
		num[0]=1;		/* so force one */
		}
	if (num[0]<0)
		{error("negative size illegal");
		num[0]=(-num[0]);
		}
	needbrack("]");		/* force single dimension */
	return num[0];		/* and return size */
	}
/*					*/
/*	Begin a function		*/
/*					*/
/* Called from "parse" this routine tries to make a function */
/*	out of what follows.	*/
newfunc()
	{
	char n[namesize], /* ptr => currfn,  gtf 7/16/80 */
	i,		/* ident of an argument  jrvz 8/6/82 */
	*prevarg;	/* pointer to the symbol table entry
		for the most recent argument jrvz 8/6/82 */
	int lgh,	/* size (bytes) of an argument
				jrvz 8/6/82 */
	where,		/* offset to argument in stack
			(zero for last argument) jrvz 8/6/82 */
	*iptr;  /* temporary ptr for stepping along argument
					chain jrvz 8/6/82 */
	if (symname(n)==0)
		{error("illegal function or declaration");
		kill();	/* invalidate line */
		return;
		}
	fnstart=lineno;
		/* remember where fn began	gtf 7/2/80 */
	infunc=1;
		/* note, in function now.	gtf 7/16/80 */
	if(currfn=findglb(n))	/* already in symbol table ? */
		{if(currfn[ident]!=function)multidef(n);
			/* already variable by that name */
		else if(currfn[offset]==function)multidef(n);
			/* already function by that name */
		else currfn[offset]=function;
			/*  we have what was earlier*/
			/*  assumed to be a function */
		}
	/* if not in table, define as a function now */
	else currfn=addglb(n,function,cint,function);

	toconsole();			/* gtf 7/16/80 */
	outstr("====== "); outstr(currfn+name); outstr("()");
	nl(); tofile();

	/* we had better see open paren for args... */
	if(match("(")==0)error("missing open paren");
	if(profile)		/* call count  jrvz 8/21/83 */
		{printlabel(lastfct); col(); defword();
		printlabel(lastfct=getlabel()); nl();
		defbyte(); ol("0,0,0");
		}
	if(trace|profile)
		{printlabel(fname=getlabel());col();
		defbyte();outbyte(39);
		outstr(currfn+name); outasm("\',0"); nl();
		}
	outname(n);col();nl();	/* print function name */
	locptr=STARTLOC;      /* "clear" local symbol table */
	prevarg=0;  /* initialize ptr to prev argument
				jrvz 8/6/82 */
	undeclared=0;		/* init arg count */
	while(match(")")==0)	/* then count args */
		/* any legal name bumps arg count */
		{if(symname(n))
			{if(findloc(n))multidef(n);
			else
			    {prevarg=addloc(n,0,cint,prevarg);
				/* add link to argument chain
						jrvz 8/6/82 */
			    undeclared++; /* jrvz 8/6/82 */
			    }
			}
		else{error("illegal argument name");junk();}
		blanks();
		/* if not closing paren, should be comma */
		if(streq(line+lptr,")")==0)
			{if(match(",")==0)
			error("expected comma");
			}
		if(endst())break;
		}
	Zsp=0;			/* preset stack ptr */
	if(trace)		/* jrvz 8/21/83 */
		{caller=Zsp=Zsp-2;
		immed(); printlabel(fname); nl();
		zpush();
		callrts("ccregis");
		}
	while(undeclared)
		/* now let user declare what types of things */
		/*	those arguments were */
		{if(amatch("char",4)){getarg(cchar);ns();}
		else if(amatch("int",3)){getarg(cint);ns();}
		else if(amatch("double",6))
		    {getarg(DOUBLE);ns();} /* jrvz 8/5/82 */
		else{error("wrong number args");break;}
		}
	/* offset calculation rewritten  jrvz 6/8/82 */
	where=2;
	while(prevarg)
		{lgh=2;  /* all arguments except DOUBLE
			have length 2 bytes (even char) */
		if(prevarg[type]==DOUBLE)lgh=6;
		i=prevarg[ident];
		if(i==pointer)lgh=2;
		iptr=prevarg+offset;
		prevarg=*iptr;  /* follow ptr to prev. arg */
		*iptr=where;	/* insert offset */
		where=where+lgh; /* calculate next offset */
		}
	if(statement()!=streturn) /* do a statement, but if */
				/* it's a return, skip */
				/* cleaning up the stack */
		leave();
	Zsp=0;			/* reset stack ptr again */
	locptr=STARTLOC;	/* deallocate all locals */
	dumplits();		/* dump the literal pool
				for this function */
	litlab=getlabel();
	litptr=0;		/* re-initialize pool */
			/* literal dump added 6/21/82  jrvz */
	infunc=0;		/* not in fn. any more
				gtf 7/2/80 */
	}
/*					*/
/*	Declare argument types		*/
/*					*/
/* called from "newfunc" this routine adds an entry in the */
/*	local symbol table for each named argument */
getarg(t)	/* t = cchar, cint or DOUBLE jrvz 8/5/82 */
	int t;
	{
	char n[namesize],c,*argptr;
	int j,legalname; /* "address" removed  jrvz 8/6/82 */
	while(undeclared)  /* jrvz 8/6/82 */
		{if(match("*"))j=pointer;
			else j=variable;
		if((legalname=symname(n))==0) illname();
		if(match("["))	/* pointer ? */
		/* it is a pointer, so skip all */
		/* stuff between "[]" */
			{while(inbyte()!=']')
				if(endst())break;
			j=pointer;
			/* add entry as pointer */
			}
		if(legalname)
			{if(argptr=findloc(n))
				/* add in details of the type
				of the name */
				{argptr[ident]=j;
				argptr[type]=t;
				/* address calculation removed
					jrvz 8/6/82 */
				}
			else error("expecting argument name");
			}
		undeclared--;	/* cnt down  jrvz 8/6/82 */
		if(endst())return;
		if(match(",")==0)error("expected comma");
		}
	}
/*					*/
/*	Statement parser		*/
/*					*/
/* called whenever syntax requires	*/
/*	a statement. 			 */
/*  this routine performs that statement */
/*  and returns a number telling which one */
statement()
{
	if(cpm(11,0) & 1)	/* check for ctrl-C		gtf 7/17/80 */
		if(getchar()==3)
			abort();

	if ((ch()==0) & (eof)) return;
	else if(amatch("char",4))
		{declloc(cchar);ns();}
	else if(amatch("int",3))
		{declloc(cint);ns();}
	else if(amatch("double",6))
		{declloc(DOUBLE);ns();} /* jrvz 8/5/82 */
	else if(match("{"))compound();
	else if(amatch("if",2))
		{doif();lastst=stif;}
	else if(amatch("while",5))
		{dowhile();lastst=stwhile;}
	else if(amatch("return",6))
		{doreturn();ns();lastst=streturn;}
	else if(amatch("break",5))
		{dobreak();ns();lastst=stbreak;}
	else if(amatch("continue",8))
		{docont();ns();lastst=stcont;}
	else if(match(";"));
	else if(match("#asm"))
		{doasm();lastst=stasm;}
	/* if nothing else, assume it's an expression */
	else{expression();ns();lastst=stexp;}
	return lastst;
}
/*					*/
/*	Semicolon enforcer		*/
/*					*/
/* called whenever syntax requires a semicolon */
ns()	{if(match(";")==0)error("missing semicolon");}
/*					*/
/*	Compound statement		*/
/*					*/
/* allow any number of statements to fall between "{}" */
compound()
	{
	++ncmp;		/* new level open */
	while (match("}")==0) statement(); /* do one */
	--ncmp;		/* close current level */
	}
/*					*/
/*		"if" sta/*					*/
doif()
	{
	int flev,fsp,flab1,flab2;
	flev=locptr;	/* record current local level */
	fsp=Zsp;		/* record current stk ptr */
	flab1=getlabel(); /* get label for false branch */
	test(flab1);	/* get expression, and branch false */
	statement();	/* if true, do a statement */
	Zsp=modstk(fsp);	/* then clean up the stack */
	locptr=flev;	/* and deallocate any locals */
	if (amatch("else",4)==0)	/* if...else ? */
		/* simple "if"...print false label */
		{printlabel(flab1);col();nl();
		return;		/* and exit */
		}
	/* an "if...else" statement. */
	jump(flab2=getlabel());	/* jump around false code */
	printlabel(flab1);col();nl();	/* print false label */
	statement();		/* and do "else" clause */
	Zsp=modstk(fsp);		/* then clean up stk ptr */
	locptr=flev;		/* and deallocate locals */
	printlabel(flab2);col();nl();	/* print true label */
	}
/*					*/
/*	"while" statement		*/
/*					*/
dowhile()
	{
	int wq[4];		/* allocate local queue */
	wq[wqsym]=locptr;	/* record local level */
	wq[wqsp]=Zsp;		/* and stk ptr */
	wq[wqloop]=getlabel();	/* and looping label */
	wq[wqlab]=getlabel();	/* and exit label */
	addwhile(wq);		/* add entry to queue */
				/* (for "break" statement) */
	printlabel(wq[wqloop]);col();nl(); /* loop label */
	test(wq[wqlab]);	/* see if true */
	statement();		/* if so, do a statement */
	jump(wq[wqloop]);	/* loop to label */
	printlabel(wq[wqlab]);col();nl(); /* exit label */
	locptr=wq[wqsym];	/* deallocate locals */
	Zsp=modstk(wq[wqsp]);	/* clean up stk ptr */
	delwhile();		/* delete queue entry */
	}
/*					*/
/*	"return" statement		*/
/*					*/
doreturn()
	{
	/* if not end of statement, get an expression */
	if(endst()==0)force(currfn[type],expression());
		/* added type coersion jrvz 10/10/82 */
	leave();
	}
/*					*/
/*	leave a function		*/
/*					*/
leave()
	{if(trace) callrts("ccleavi");/*jrvz 8/21/83*/
	modstk(0);	/* clean up stk */
	zret();		/* and exit function */
	}
/*					*/
/*	"break" statement		*/
/*					*/
dobreak()
	{
	int *ptr;
	/* see if any "whiles" are open */
	if ((ptr=readwhile())==0) return;	/* no */
	modstk((ptr[wqsp]));	/* else clean up stk ptr */
	jump(ptr[wqlab]);	/* jump to exit label */
	}
/*					*/
/*	"continue" statement		*/
/*					*/
docont()
	{
	int *ptr;
	/* see if any "whiles" are open */
	if ((ptr=readwhile())==0) return;	/* no */
	modstk((ptr[wqsp]));	/* else clean up stk ptr */
	jump(ptr[wqloop]);	/* jump to loop label */
	}
/*					*/
/*	"asm" pseudo-statement		*/
/*					*/
/* enters mode where assembly language statement are */
/*	passed intact through parser	*/
doasm()
	{
	cmode=0;		/* mark mode as "asm" */
	while (1)
		{inline();	/* get and print lines */
		if (match("#endasm")) break;	/* until... */
		if(eof)break;
		outstr(line);
		nl();
		}
	kill();		/* invalidate line */
	cmode=1;		/* then back to parse level */
	}
/*	>>>>> start of cc3 <<<<<<<<<	*/

/*					*/
/*	Perform a function call		*/
/*					*/
/* called from heirb, this routine will either call */
/*	the named function, or if the supplied ptr is */
/*	zero, will call the contents of HL		*/
callfunction(ptr)
	char *ptr;	/* symbol table entry (or 0) */
{	char sym[SYMSIZ];
	int nargs;
	nargs=0;
	blanks();	/* already saw open paren */
	if(ptr==0)zpush();	/* calling HL */
	while(streq(line+lptr,")")==0)
		{if(endst())break;
		if(expression()==DOUBLE)  /* jrvz 8/6/82 */
			{if(ptr==0)dpush2(); /* save addr */
			else dpush();
			nargs=nargs+6;
			}
		else
			{if(ptr==0)swapstk(); /* save addr */
			zpush();	/* push argument */
			nargs=nargs+2;	/* count args*2 */
			}
		if (match(",")==0) break;
		}
	needbrack(")");
	if(ptr)
		{if(nospread(ptr))
			{ot("LD A,");
			outdec(nargs>>1);
			nl();
			}
		zcall(ptr);
		}
	else callstk();
	Zsp=modstk(Zsp+nargs);	/* clean up arguments */
}
nospread(sym) char sym[];
{	if(astreq(sym,"printf",6))return 1;
	if(astreq(sym,"fprint",6))return 1;
	if(astreq(sym,"sprintf",7))return 1;
	if(astreq(sym,"scanf",5))return 1;
	if(astreq(sym,"fscan",5))return 1;
	if(astreq(sym,"sscanf",6))return 1;
	return 0;
}
junk()
{	if(an(inbyte()))
		while(an(ch()))gch();
	else while(an(ch())==0)
		{if(ch()==0)break;
		gch();
		}
	blanks();
}
endst()
{	blanks();
	return ((streq(line+lptr,";")|(ch()==0)));
}
illname()
{	error("illegal symbol name");junk();}
multidef(sname)
	char *sname;
{	error("already defined");
	comment();
	outstr(sname);nl();
}
needbrack(str)
	char *str;
{	if (match(str)==0)
		{error("missing bracket");
		comment();outstr(str);nl();
		}
}
needlval()
{	error("must be lvalue");
}
hash(sname)
	char *sname;
{	int h,c;
	h=*sname;
	while(c=*(++sname)) h=(h<<1)+c;
	return h;
}
findglb(sname)	/* cptr is set to entry if found,
		or appropriate empty slot if not */
	char *sname;
{	int h;
	h=hash(sname)&MASKGLBS;
	cptr=STARTGLB+h*SYMSIZ;
	while(0==astreq(sname,cptr,namemax)){
		if(*cptr==0) return 0;
		cptr=cptr+SYMSIZ;
		if(cptr==ENDGLB)cptr=STARTGLB;
	}
	return cptr;
}
findloc(sname)
	char *sname;
{	char *ptr;
	ptr=STARTLOC;
	while(ptr!=locptr)
		{if(astreq(sname,ptr,namemax))return ptr;
		ptr=ptr+SYMSIZ;
		}
	return 0;
}
addglb(sname,id,typ,value)
	char *sname,id,typ;
	int value;
{	char *ptr;
	if(findglb(sname))return cptr;
			 /* declare exported name */
	if(id!=MACRO){ot("global "); outname(sname); nl();}
	if(glbptr>=ENDGLB)
		{error("global symbol table overflow");
		return 0;
		}
	ptr=cptr;
	while(an(*ptr++ = *sname++));	/* copy name */
	cptr[ident]=id;
	cptr[type]=typ;
	cptr[storage]=statik;
	cptr[offset]=value;
	cptr[offset+1]=value>>8;
	glbptr=glbptr+SYMSIZ;
	return cptr;
}
addloc(sname,id,typ,value)
	char *sname,id,typ;
	int value;
{	char *ptr;
	if(cptr=findloc(sname))return cptr;
	if(locptr>=ENDLOC)
		{error("local symbol table overflow");
		return 0;
		}
	cptr=ptr=locptr;
	while(an(*ptr++ = *sname++));	/* copy name */
	cptr[ident]=id;
	cptr[type]=typ;
	cptr[storage]=stkloc;
	cptr[offset]=value;
	cptr[offset+1]=value>>8;
	locptr=locptr+SYMSIZ;
	return cptr;
}
/* Test if next input string is legal symbol name */
symname(sname)
	char *sname;
{	int k;char c;
	blanks();
	if(alpha(ch())==0)return 0;
	k=0;
	while(an(ch()))sname[k++]=gch();
	sname[k]=0;
	return 1;
	}
/* Return next avail internal label number */
getlabel()
{	return(++nxtlab);
}
/* Print specified number as label */
printlabel(label)
	int label;
{	outasm("cc");
	outdec(label);
}
/* Test if given character is alpha */
alpha(c)  /* rewritten for speed 10/24/82 jrvz */
	char c;
{	c=c&127;
	if(c>='a') return (c<='z');
	if(c<='Z') return (c>='A');
	return (c=='_');
}
/* Test if given character is numeric */
numeric(c)
	char c;
{	c=c&127;
	if(c<='9') return(c>='0');
	return 0;
}
/* Test if given character is alphanumeric */
an(c)		/* rewritten for speed  11/10/82 jrvz */
	char c;
{	if(alpha(c)) return 1;
	return numeric(c);
}
/* Print a carriage return and a string only to console */
pl(str)
	char *str;
{	int k;
	k=0;
	putchar(EOL);
	while(str[k])putchar(str[k++]);
}
addwhile(ptr)
	int ptr[];
 {
	int k;
	if (wqptr==wqmax)
		{error("too many active whiles");return;}
	k=0;
	while (k<wqsiz)
		{*wqptr++ = ptr[k++];}
}
delwhile()
	{if(readwhile()) wqptr=wqptr-wqsiz;
	}
readwhile()
{	if (wqptr==wq){error("no active whiles");return 0;}
	else return (wqptr-wqsiz);
}
ch()
{	return(line[lptr]&127);
}
nch()
{/*	if(ch()==0)return 0;
		else return(line[lptr+1]&127);
*/
	if(ch()) return(line[lptr+1]&127);
	return 0;
}
gch()
{/*	if(ch()==0)return 0;
		else return(line[lptr++]&127);
*/
	if(ch()) return(line[lptr++]&127);
	return 0;
}
kill()
{	lptr=0;
	line[lptr]=0;
}
inbyte()
{
	while(ch()==0)
		{if (eof) return 0;
		inline();
		preprocess();
		}
	return gch();
}
inline()
{
	int k,unit;
	while(1)
		{if (input==0)openin();
		if(eof)return;
		if((unit=inpt2)==0)unit=input;
		kill();
		while((k=getc(unit))>0)
			{if((k==EOL)|(lptr>=linemax))break;
			line[lptr++]=k;
			}
		line[lptr]=0;	/* append null */
		lineno++;	/* read one more line		gtf 7/2/80 */
		if(k<=0)
			{fclose(unit);
			if(inpt2)endinclude();		/* gtf 7/16/80 */
				else input=0;
			}
		if(lptr)
			{if((ctext)&(cmode))
				{comment();
				outstr(line);
				nl();
				}
			lptr=0;
			return;
			}
		}
}
/*	>>>>>> start of cc4 <<<<<<<	*/

keepch(c)
	char c;
{	mline[mptr]=c;
	if(mptr<mpmax)++mptr;
	return c;
}
preprocess()
{	int k;
	char c,sname[namesize];
	if(cmode==0)return;
	mptr=lptr=0;
	while(ch())
		{if((ch()==' ')|(ch()==9))
			{keepch(' ');
			while((ch()==' ')|
				(ch()==9))
				gch();
			}
		else if(ch()=='"')
			{keepch(ch());
			gch();
			while((ch()!='"')|
			((line[lptr-1]==92)&(line[lptr-2]!=92))
			)
				{if(ch()==0)
				   {error("missing quote");
				   break;
				   }
				keepch(gch());
				}
			gch();
			keepch('"');
			}
		else if(ch()==39)
			{keepch(39);
			gch();
			while((ch()!=39)|
			((line[lptr-1]==92)&
			(line[lptr-2]!=92)))
			   {if(ch()==0)
				{error("missing apostrophe");
				break;
				}
			   keepch(gch());
			   }
			gch();
			keepch(39);
			}
		else if((ch()=='/')&(nch()=='*'))
			{lptr=lptr+2;
			while(((ch()=='*')&
				(nch()=='/'))==0)
				{if(ch()==0)inline();
					else lptr++;
				if(eof)break;
				}
			lptr=lptr+2;
			}
		else if(alpha(ch())) /* 10/24/82 jrvz */
			{k=0;
			while(an(ch()))
				{if(k<namemax)sname[k++]=ch();
				gch();
				}
			sname[k]=0;
			if(k=findmac(sname))
				while(c=macq[k++])
					keepch(c);
			else
				{k=0;
				while(c=sname[k++])
					keepch(c);
				}
			}
		else keepch(gch());
		}
	keepch(0);
	if(mptr>=mpmax)error("line too long");
	lptr=mptr=0;
	while(line[lptr++]=mline[mptr++]);
	lptr=0;
	}
addmac()
{	char sname[namesize];
	if(symname(sname)==0)
		{illname();
		kill();
		return;
		}
	addglb(sname,MACRO,0,macptr);
		/* call replaced code which moved the name
		into the macro table	6/19/82  jrvz */
	while(ch()==' ' | ch()==9) gch();
	while(putmac(gch()));
	if(macptr>=macmax)error("macro table full");
	}
putmac(c)
	char c;
{	macq[macptr]=c;
	if(macptr<macmax)macptr++;
	return c;
}
findmac(sname)  /* function rewritten 6/19/82  jrvz */
	char *sname;
{	if((findglb(sname)!=0)&(cptr[ident]==MACRO))
		{return((cptr[offset]&255)+
		(cptr[offset+1]<<8));
		}
	return 0;
}
/* direct output to console		gtf 7/16/80 */
toconsole()
{
	saveout = output;
	output = 0;
/* end toconsole */}

/* direct output back to file		gtf 7/16/80 */
tofile()
{
	if(saveout)
		output = saveout;
	saveout = 0;
/* end tofile */}

outbyte(c)
	char c;
{
	if(c)	/* sense of test reversed  jrvz 9/2/83 */
		{if(output)
			{if((putc(c,output))<=0)
				{closeout();
				error("Output file error");
				abort();	/* gtf 7/17/80 */
				}
			}
		else putchar(c);
		}
	return c;
}
outstr(ptr)
	char ptr[];
 {	while(outbyte(*ptr++));	/* jrvz 8/21/83 */
 }

/* write text destined for the assembler to read */
/* (i.e. stuff not in comments)			*/
/*  gtf  6/26/80 */
outasm(ptr)
char *ptr;
{
/*	while(outbyte(raise(*ptr++)));*/
	while(outbyte(*ptr++));	/* ZMAC changes to upper case */
/* end outasm */}

nl()
	{outbyte(EOL);}
tab()
	{outbyte(9);}
col()
	{outbyte(58);}
bell()				/* gtf 7/16/80 */
	{outbyte(7);}

error(ptr)
char ptr[];
{	int k;
	char junk[81];

	toconsole();
	bell();
	outstr("Line "); outdec(lineno); outstr(", ");
	if(infunc==0)
		outbyte('(');
	if(currfn==NULL)
		outstr("start of file");
	else	outstr(currfn+name);
	if(infunc==0)
		outbyte(')');
	outstr(" + ");
	outdec(lineno-fnstart);
	outstr(": ");  outstr(ptr);  nl();

	outstr(line); nl();

	k=0;	/* skip to error position */
	while(k<lptr){
		if(line[k++]==9)
			tab();
		else	outbyte(' ');
		}
	outbyte('^');  nl();
	++errcnt;

	if(errstop){
		pl("Continue (Y,n,g) ? ");
		gets(junk);		
		k=junk[0];
		if((k=='N') | (k=='n'))
			abort();
		if((k=='G') | (k=='g'))
			errstop=0;
		}
	tofile();
/* end error */}

ol(ptr)
	char ptr[];
{
	ot(ptr);
	nl();
}
ot(ptr)
	char ptr[];
{
	tab();
	outasm(ptr);
}
streq(str1,str2)
	char str1[],str2[];
 {
	int k;
	k=0;
	while (*str2)
		{if ((*str1++)!=(*str2++)) return 0;
		k++;
		}
	return k;
 }
astreq(str1,str2,len)
	char str1[],str2[];int len;
 {
	int k;
	k=0;
	while (k<len)
		{if ((*str1)!=(*str2))break;
		if(*str1==0)break;
		if(*str2==0)break;
		++str1; ++str2; ++k;
		}
	if (an(*str1))return 0;
	if (an(*str2))return 0;
	return k;
 }
match(lit)
	char *lit;
{
	int k;
	blanks();
	if (k=streq(line+lptr,lit))
		{lptr=lptr+k;
		return 1;
		}
 	return 0;
}
amatch(lit,len)
	char *lit;int len;
 {
	int k;
	blanks();
	if (k=astreq(line+lptr,lit,len))
		{lptr=lptr+k;
		while(an(ch())) inbyte();
		return 1;
		}
	return 0;
 }
blanks()
	{while(1)
		{while(ch()==0)
			{inline();
			preprocess();
			if(eof)break;
			}
		if(ch()==' ')gch();
		else if(ch()==9)gch();
		else return;
		}
	}
outdec(number)
	int number;
 {	if (number<0)
		{number=(-number);
		outbyte('-');
		}
	outd2(number);
}
outd2(n) int n;
{	if(n>9) {outd2(n/10); n=n%10;}
	outbyte('0'+n);
 }
/* return the length of a string */
/* gtf 4/8/80 */
strlen(s)
char *s;
{	char *t;

	t = s;
	while(*s) s++;
	return(s-t);
/* end strlen */}

/* convert lower case to upper */
/* gtf 6/26/80 */
raise(c)
char c;
{
	if(c>='a')
		{if(c<='z')
			c = c - 32; /* 'a'-'A'=32 */
		}
	return(c);
/* end raise */}
#include c80v-2.c
                                                                                                  