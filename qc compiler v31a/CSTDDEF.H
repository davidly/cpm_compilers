/********************************************************/
/*							*/
/*		Q/C Compiler Version 3.1		*/
/*		  Standard Definitions			*/
/*							*/
/*     Copyright (c) 1983 Quality Computer Systems	*/
/*							*/
/*			06/30/83			*/
/********************************************************/

#define Z80	TRUE

/* Uncomment the following line to compile only
 * pure C code.  When PORTABLE is defined the
 * compiler contains the C version of all
 * functions, so the compiler is portable.

#define PORTABLE	1
*/

/*	Define code generation parameters	*/

#define DEFASM		'm'	/* default assembler: 'm'-M80, 'a'-RMAC */
#define MAXREG		5	/* max number of register variables */
#define MAXINCL 	3	/* max depth for nested #include */
#define MAXIF		3	/* max depth for nested #if */
#define PREG		1	/* the primary register (HL) */
#define SREG		2	/* the secondary register (DE) */
#define WREG		2	/* the work register (DE) */
#define SFP		3	/* the stack frame pointer (BC) */
#if Z80
#define XREG		4	/* Z80 index register (IX) */
#endif
#define EQ		1	/* codes for binary operator routine */
#define NE		2
#define LE		3
#define GE		4
#define LT		5
#define GT		6
#define CODE		1	/* values for segtype:	code segment */
#define DATA		2	/*			data segment */
#define INITSIZE	128	/* max size array that will get default */
				/* initialization unless -I flag is used */
#define FILNAMSIZE	14	/* size of a CP/M filename */
#define ASMULINE	'@'	/* What '_' changes to in assembler	*/
#define ASMRTS		'?'	/* To set off created names with	*/

/*	Define peephole optimization flags	*/

#define JUMP		1
#define JUMPTRUE	2
#define JUMPFALSE	3
#define PREGSYM 	4
#define ADDRSFP 	5

#define TESTED		1
#define REGH		2
#define REGL		3

/*	Define the type table		*/

struct typeinfo {
	char	 t_code;	/* int, ptr to, array of, etc. */
	unsigned t_size;	/* size of one thing of this type */
	unsigned t_refs;	/* # of vars pointing to this entry */
	struct typeinfo 	/* the 'int' of 'ptr to int' or */
		*t_base;	/*	the 'ptr' of 'array of ptrs' */
	struct typeinfo	 	/* next type of this class */
		*t_next;
	};

#define TSSIZE		30	/* size of type parsing stack */

struct parsestack {
	struct typestack {
		char	 t_code;
		unsigned t_size;
		} *curr_ptr, stack[TSSIZE];
	};

/*
 *	Type codes:
 *
 *	T_xxx is the code for the type 'xxx'.
 *	S_xxx is the size, in bytes, of one item of type 'xxx'.
 *
 *	T_NONE is assumed to be non-negative, and less than all other
 *		type codes.
 *	All types between T_NONE and T_SIMPLE are 'simple' types:
 *		they may be returned by functions.  All other types
 *		are 'non-simple' and may not be returned by functions.
 */

#define T_NONE		0

#define T_CHAR		1
#define		S_CHAR	 	1
#define	T_SHORT		2
#define 	S_SHORT 	2
#define T_INT		3
#define		S_INT	 	2
#define	T_UNSIGNED	4
#define 	S_UNSIGNED	2
#define T_LONG		5
/*#define			S_LONG	4	*/
#define T_PTR		6
#define		S_PTR		2

#define T_SIMPLE	T_PTR

#define T_LABEL 	7		/* statement label */
#define T_STRUCT	8
#define T_UNION 	9
	/* The following are all compound types */
#define T_ARRAY 	10		/* array of ... */
#define T_FUNC		11		/* function returning ... */
#define 	S_FUNC		0	/* functions have no size */
#define T_MAX		12

/*	Define the symbol table parameters	*/

#define STARTGLB symtab
#define STARTLOC (symtab+(nsym-1))
#define NAMEMAX  8
#define NAMESIZE (NAMEMAX+1)

/*	Define symbol table entry format	*/
struct st {
	char	 st_sc; 	/* storage class */
	struct typeinfo		/* variable type */
		 *st_type;
	int	 st_info;	/* stack offset for local auto	*/
				/* register # for local register*/
				/* offset for structure member	*/
				/* label # for local static	*/
				/* label # for statement label	*/
	char	 st_name[NAMESIZE];
	char	 st_idset;	/* tag/member or variable */
	};

/*	Define possible entries for "st_idset"	*/
#define ID_VAR		1
#define ID_STRUCT	2

/*	Define possible entries for "st_sc"  */

#define SC_NONE 	0
#define SC_GLOBAL	1	/* unspecified external */
#define SC_ST_GLB	2	/* static ... (global) */
#define SC_EXTERN	3	/* extern ... */
#define SC_STATIC	4	/* static ... (local) */
#define SC_AUTO 	5	/* auto ... or unspecified local */
#define SC_ARG		6	/* like auto, but for arg on stack */
#define SC_REG		7	/* register ... */
#define SC_MEMBER	8	/* member of, or tag for, structure */
				/* distinguished by st_ident */
#define SC_TYPE 	9	/* typedef ..., or struct xxx */

/*	Define possible entries for "st_info"	*/

#define DECL_GLB	1
#define DECL_LOC	2

/*	Define expression operand for parser	*/

struct operand {
	char		op_load;
	struct st	*op_sym;
	int		op_val;
	struct typeinfo *op_type;
	};

/*	Define possible entries for "op_load"	*/

#define EXPRESSION	0	/* an operand whose value is in preg */
#define LOADVALUE	01	/* an op whose value needs loading */
#define LOADADDR	02	/* an op whose address needs loading */
#define LVALUE		04	/* an lvalue */
#define CONSTANT	010	/* a constant expression */
#define CONSTADDR	020	/* a constant address expression */
#define CONSTOFF	040	/* a stack var with constant offset */
/* This is the result of constant assignment statements */
#define ASGCONST	0100

/*	Define the switch/loop queue		*/

struct swq {
	int loop;
	int exit;
	};

/*	Define the switch case table		*/

struct case_table {
	int value;
	int label;
	};

/*	Define the literal pool 		*/

/*	#define LITMAX	(litpool+litpsize-1)	*/
#define LITSIZE 128

/*	Define the macro (#define) pool 	*/

#define MACPTR	8
#define MACSIZE 10

/*	Define the input line			*/

#define LINESIZE 128
#define LINEMAX (LINESIZE-1)

/*	Define conditional compilation parameters	*/

#define IGNORE	0
#define PROCESS 1
#define SKIP	2
/* end of CSTDDEF.H */
