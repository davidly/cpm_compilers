/********************************************************/
/*							*/
/*		Q/C Compiler Version 3.1		*/
/*		   Global Definitions			*/
/*							*/
/*     Copyright (c) 1983 Quality Computer Systems	*/
/*							*/
/*			08/06/83			*/
/********************************************************/

int	segtype = CODE, 	/* record whether code or data segment */
	fullist = FALSE,	/* commented listing? */
	mainflag = FALSE,	/* has main() been defined? */
	libflag = FALSE,	/* is library being generated? */
	trace = FALSE,		/* print trace messages? */
	genflag = TRUE, 	/* FALSE to suppress code generation */
	romflag = FALSE,	/* generating ROMable code? */
	spaddr, 		/* if romflag==TRUE, addr to init SP */
	cmode = TRUE,		/* parsing C or passing asm thru? */
	midline = FALSE,	/* at beginning of output line? */
	pregflag = FALSE,	/* does preg contain curr val of expr? */
	retvalue = FALSE,	/* is return value in preg? */
	testdone = FALSE,	/* was a test (e.g. ==) just done? */
	eof = FALSE,		/* reached end-of-file? */
	stopeol = FALSE,	/* TRUE if parser must stop at end of */
				/*	line when skipping white space */
	infunc = FALSE, 	/* compiling a function? */
	textline = FALSE;	/* printing a C text line? */
/*
 *	Compiler tables & pointers
 */
struct typeinfo
	*typelist,		/* the type table */
	*basetypes[T_MAX],	/* heads of each base-type list */
	*functype,		/* constant 'function returning int' */
	*labeltype,		/* constant 'statement label' */
	*chartype,		/* constant 'char'	*/
	*inttype,		/* constant 'int'	*/
	*unsgntype;		/* constant 'unsigned'	*/
/*
 *	Symbol table
 */
struct st
	*symtab,	/* beginning of symbol table */
	*glbptr,	/* next global sym table entry */
	*locptr;	/* next local sym table entry */
unsigned
	minsym; 	/* record minimum symbol table space */
/*
 *	Literal pool
 */
struct st
	lit_sym;	/* special "symbol" for literal pool */
int	lit_label;	/* label for current literal pool */
char	*litpool,	/* beginning of literal pool */
	*plitpool;	/* next char in literal pool */
/*
 *	Macro pool
 */
char	*macpool,	/* beginning of macro pool */
	*pmacsym,	/* next macro pool sym entry */
	*pmacdef;	/* next macro pool def entry */
/*
 *	Switch/loop queue
 */
struct swq
	*swq,		/* start of switch/loop queue */
	*pswq;		/* next switch/loop entry */
/*
 *	Switch/case table
 */
struct case_table
	*casetab,	/* start of switch case table */
	*pcasetab;	/* next switch case entry */

char	*line,		/* parsing buffer */
	*lptr,		/* parsing line buffer */
	*mline; 	/* temp macro buffer */
/*
 *	Misc variables
 */
char	infil[FILNAMSIZE+1],	/* current input file name */
	**nextfil,		/* name of next input file */
	*inbuf, 		/* pointer to input buffer */
	outfil[FILNAMSIZE+1],	/* output file name */
	*outbuf,		/* pointer to input buffer */
	inclfil[MAXINCL][FILNAMSIZE+1], /* include file names */
	*inclbuf[MAXINCL];	/* pointers to include buffers */

FILE	*input, 	/* iob for current input file */
	*output,	/* iob for output file (if any) */
	*holdinput[MAXINCL]; /* hold input file iob during #include */

int	ninfils,	/* # of input files */
	iobufsize = 512,/* size of input/output buffers */
	inclbsize = 128,/* size of include buffers */
	lineno, 	/* line number in current input file */
	incldepth,	/* current depth of #include nesting */
	holdlineno[MAXINCL], /* hold input file line no during #include */
	ifdepth = 0,	/* current depth of #if nesting */
	holdif[MAXIF],	/* hold process status of nested #if */
	holdelse[MAXIF],/* record presence of #else for nested #if */
	condif=PROCESS, /* records whether #if says to PROCESS or SKIP */
	condelse=FALSE, /* records whether matching #else was found */
	locspace,	/* local space needed in current function */
	retlab, 	/* label # of return for current function */
	nregvar,	/* # of register variables in current function */
	ncmp,		/* # open compound statements */
	errcnt; 	/* # errors in compilation */
/*
 *	Peephole optimization variables
 */
int	peepflag,	/* type of pattern (if any) */
	testflag,	/* = TESTED, REGH, or REGL */
	jcondlabel,	/* label on last conditional jump */
	jumplabel;	/* label on following unconditional jump */
char	*peepbuf,	/* buffer for patterns */
	peepsym[NAMESIZE]; /* name of symbol currently in preg */
int	peepoffset;	/* offset from symbol currently in preg */

/********************************************************/
/*	Global variables referenced by QRESET		*/
/*							*/
/* If you change the compiler and you still want QRESET */
/* to work, this code must remain unchanged.		*/
/********************************************************/

#asm
	CSEG
#endasm
char	copyright[] = " Copyright (c) 1983 Quality Computer Systems";
char	signon[] = "Q/C Compiler ";

#if Z80
char	version[] = "V3.1a (Z80)";
#else
char	version[] = "V3.1a (8080)";
#endif

int	nsym = 150,		/* size of symbol table */
	n_types = 50,		/* size of type table */
	nswq = 10,		/* max entries in switch/loop queue */
	ncases = 50,		/* max entries in switch case table */
	macpsize = 1000,	/* size of macro (#define) pool */
	pausecnt = 6,		/* pause after this many errors on screen */
	initflag = FALSE,	/* TRUE if all arrays get initialized */
				/* FALSE: don't do default init */
				/*	of arrays > INITSIZE */
	verbose = FALSE,	/* TRUE to chat during compile */
	redirect = FALSE,	/* TRUE if redirection requested */
	codeflag = DEFASM;	/* default assembler: 'm'-M80, 'a'-RMAC */
#if DEFASM == 'm'
char	defext[] = "MAC";
#else
char	defext[] = "ASM";
#endif
#asm
	DSEG
#endasm

/********************************************************/
/*	End of global variables referenced by QRESET	*/
/********************************************************/

/* end of CGLBDEF.C */
