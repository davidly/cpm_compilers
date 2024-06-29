/* Q/C Compiler Version 3.1
 *	Global Declarations
 *	Copyright (c) 1983 Quality Computer Systems
 *	08/06/83
 */
extern
int	segtype,
	fullist,
	mainflag,
	libflag,
	trace,
	genflag,
	romflag,
	spaddr,
	cmode,
	midline,
	pregflag,
	retvalue,
	testdone,
	eof,
	stopeol,
	infunc,
	textline;
extern
struct typeinfo
	*typelist,
	*basetypes[],
	*functype,
	*labeltype,
	*chartype,
	*inttype,
	*unsgntype;
extern
struct st
	*symtab,
	*glbptr,
	*locptr;
extern
unsigned
	minsym;
extern
struct st
	lit_sym;
extern
int	lit_label;
extern
char	*litpool,
	*plitpool;
extern
char	*macpool,
	*pmacsym,
	*pmacdef;
extern
struct swq
	*swq,
	*pswq;
extern
struct case_table
	*casetab,
	*pcasetab;
extern
char	*line,
	*lptr,
	*mline;
extern
char	infil[],
	**nextfil,
	*inbuf,
	outfil[],
	*outbuf,
	inclfil[][FILNAMSIZE+1],
	*inclbuf[];
extern
FILE	*input,
	*output,
	*holdinput[];
extern
int	ninfils,
	iobufsize,
	inclbsize,
	lineno,
	incldepth,
	holdlineno[],
	ifdepth,
	holdif[],
	holdelse[],
	condif,
	condelse,
	locspace,
	retlab,
	nregvar,
	ncmp,
	errcnt;
extern
int	peepflag,
	testflag,
	jcondlabel,
	jumplabel;
extern
char	*peepbuf,
	peepsym[];
extern
int	peepoffset;
extern
char	copyright[],
	signon[],
	version[];
extern
int	nsym,
	n_types,
	nswq,
	ncases,
	macpsize,
	pausecnt,
	initflag,
	verbose,
	redirect,
	codeflag;
extern
char	defext[];
/* end of CGLBDECL.C */
