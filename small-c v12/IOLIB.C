/*	name...
		iolib

	purpose...
		to provide a "standard" interface between c
		programs and the CPM I/O system.

	notes...
		Compile using -M option.

	history...
		31 Jul 84  fbuf is now a pointer rather than
			an array, and the disk buffer is
			allocated from the heap.
		28 Jul 84  Prepended '_' to all global
			variables that shouldn't be visible
			elsewhere.
		27 Jul 84  Permitting I/O redirection. err()
			temporarily resets STDOUT to 1 so
			error messages go to console.
		26 Jul 84  ccgo is initializing fmode[] at run
			time, so compiled code need not be
			changed before assembly.
		14 Jul 84  gets() emitting LF after reading input.
		1 Jul 84   Declaring _dfltdsk in c rather than
			assembly, so references from c don't 
			have to be corrected.
		27 Jun 84  Changed ENDDATA to _END in alloc().
		17 Jun 84  including iolib.h, so output can be
			separately assembled.
		14 Jun 84  Several bugs fixed, 'A' file mode
			supported, putb() and getb() installed,
			getc(1) comes from keyboard & putc(c,2)
			goes to console.
		29 Oct 83  Saving return addr in cpm().
		13 Oct 83  QERR added from clibv.asm,
			reformatted for ZMAC.
		18 Sep 83  written (jrvz).
*/
#include iolib.h
#asm
BDOS	=	5
CR	=	13
;	cpm(bc,de) int bc,de;   BDOS call */
QCPM:	POP	HL
	POP	DE
	POP	BC
	PUSH	BC
	PUSH	DE
	PUSH	HL
	CALL	BDOS
	JP	CCSXT	;move A to HL & sign extend
;
;	/* return address of a block of memory */
;	alloc(b)
;	int b;		/* # bytes desired */
;
QALLOC:	POP	HL	;return addr
	POP	DE	;block size
	PUSH	DE
	PUSH	HL
	LD	HL,(HEAPTOP) ;current top of heap
	EX	DE,HL
	ADD	HL,DE	;hl=new top of heap
	LD	(HEAPTOP),HL
	EX	DE,HL	;hl=old top of heap
	RET
HEAPTOP: DEFW	_END
;
;	/* reset the top of heap pointer to addr* */
;
;	free(addr)
;	int addr;
;
QFREE:	POP	DE
	POP	HL	;addr
	PUSH	HL
	PUSH	DE
	LD	(HEAPTOP),HL
	RET
;
;	/* return number of bytes between top of heap
;	and end of TPA.  Remember that this includes
;	the stack! */
;
;	avail()
;
QAVAIL:	LD	HL,(6)	;end of TPA
	PUSH	HL
	LD	HL,(HEAPTOP)	;top of heap
	JP	CCSUB	;find (6)-HEAPTOP
;
;	error...print message & walkback trace (if available)
;
;			err(s) char *s;
;			{	int str;
;				puts("\nERROR ");
QERR:	LD	HL,(QSTDOUT)
	LD	(ERR6),HL
	LD	HL,1
	LD	(QSTDOUT),HL
	LD	HL,MSGE
	PUSH	HL
	CALL	QPUTS
	POP	HL
;				puts(s);
	POP	DE
	POP	HL
	PUSH	HL
	PUSH	DE
	PUSH	HL
	CALL	QPUTS
	POP	HL
;				str=current;
	LD	HL,(CURRENT)
;				while(str)
ERR4:	LD	(ERR2),HL
	LD	A,H
	OR	L
	JR	Z,ERR5
;					{puts("\ncalled by ");
	LD	HL,MSGE2
	PUSH	HL
	CALL	QPUTS
	POP	HL
;					puts(*(str+1));
	LD	HL,(ERR2)
	INC	HL
	INC	HL
	CALL	CCGINT
	PUSH	HL
	CALL	QPUTS
	POP	HL
;					str=*str;
	LD	HL,(ERR2)
	CALL	CCGINT
;					}
	JR	ERR4
;			}
ERR5:	LD	HL,(ERR6)
	LD	(QSTDOUT),HL
	RET
;
MSGE:	DB	CR,'ERROR: ',0
MSGE2:	DB	CR,'CALLED BY ',0
ERR2:	DW	0
ERR6:	DW	0	;temporary storage for STDOUT
CURRENT: DW	0
#endasm
#define LF 10

int _dfltdsk,	/* "current disk" at beginning of execution */
stdin,		/* 0 initially, or unit number for input file
		if input has been redirected by args() */
stdout;		/* 1 initially, or unit number for output file
		if output has been redirected by args()	*/

getchar()
{	return getc(stdin);
}

putchar(c) char c;
{	putc(c,stdout);
	return c;
}

gets(buf) char *buf;   /* input a string (editing permitted) */
{	char s1,s2;
	int i;
	if(stdin)	/* input has been redirected */
		{i=80;
		while(i--)
			{s1=getc(stdin);
			if((s1==-1)|(s1=='\n')) break;
			*buf++=s1;
			}
		*buf=0;
		}
	else
		{s2=buf[-2]; s1=buf[-1];    /* save 2 bytes */
		buf[-2]=80;	/* assumed string length */
		cpm(10,buf-2);
		buf[buf[-1]]=0;	/* mark end using count left by cpm */
		buf[-1]=s1; buf[-2]=s2;	/* restore the bytes */
		putchar('\l');	/* LF */
		}
}

puts(buf) char *buf;	/* print a null-terminated string */
{	char c;
	while(c=*buf++) putchar(c);
}

#define NBUFS 3
	/*	= number of files which can be open at once */
	/*	NOTE: ccgo() must initialize this many	*/
	/*	elements of fmode[].			*/
#define LGH 1024
	/*	length of each file buffer		*/
	/*	= some multiple of 128: 128, 256, 384, 512... */
#define BUFLGH 3171
	/*	=NBUFS*(LGH+33)				*/
	/*  used in ccgo() to allocate the disk buffer	*/
#define MFREE 11387
#define MREAD 22489
#define MWRITE 17325
#define MEOF -8734
char *_fbuf;		/* for fcb's and disk buffers */
int	_ffcb[NBUFS],	/* pointers to the fcb's */
	_fnext[NBUFS],	/* pointers to the next char to be fed
			to the program (for an input file) or
			the next free byte in the buffer (for
			an output file)			*/
	_ffirst[NBUFS],	/* ptrs to the starts of the buffers */
	_flast[NBUFS],	/* ptrs to the ends of the buffers */
	_fmode[NBUFS],	/* MFREE => buffer is free
			   MREAD => open for reading
			   MWRITE => open for writing
			   MEOF => was open for reading, but
				EOF encountered
			= MFREE initially */
	_ex,_cr;		/* extent & current record at beginning
		of this buffer full (used for "A" access) */

fopen(name,mode)   /* open file in fmode
		"r", "w", or "a" (upper or lower case)	*/
char *name,*mode;
{	char c,*fcb;
	int index,i,unit;
	index=NBUFS;
	while(index--)		/* search for free buffer */
		{if(_fmode[index]==MFREE)break;
		}
	if(index==-1)
		{err("OUT OF DISK BUFFERS"); exit();
		}
	unit=index+5;
	_ffcb[index]=_fbuf+index*(33+LGH);
	_ffirst[index]=_ffcb[index]+33;
	_flast[index]=_ffirst[index]+LGH;
	fcb=_ffcb[index];
	i=11; while(i) fcb[i--]=' ';  /* clear file name */
	fcb[12]=fcb[32]=0;		/* clear ex & cr */
	if (name[1]==':')		/* transfer disk */
		{fcb[0]= (*name&15) +1; /* either case */
		name=name+2;
		}
	else	fcb[0]=_dfltdsk;
	while(c=upper(*name++))		/* transfer name */
		{if(c=='.')break;
		fcb[++i]=c;
		}
	if(c=='.')		/* transfer extension */
		{i=8;
		while(c=upper(*name++)) {fcb[++i]=c;}
		}
	c=upper(*mode);
/*	puts("OPENING FILE "); puts(fcb+1); putchar('\n');
	puts("fcb at "); hex(fcb);
	puts("\nbuffer "); hex(_ffirst[index]);
	puts("through "); hex(_flast[index]);	*/
	if((c=='R')|(c=='A'))
		{if(cpm(15,fcb)<0) 
			{/* err("INPUT FILE DOESN\'T EXIST");*/
			return 0; /* file not found */
			}
		_fmode[index]=MREAD;	/* open for reading */
		_fnext[index]=_flast[index];
				/* forces immed. read */
		if(c=='A')	/* append mode requested? */
			{while(getc(unit)!=-1)
				{} /* read to EOF */
			fcb[12]=_ex; /* reset to values at...*/
			cpm(15,fcb); /* ...beginning of buffer */
			fcb[32]=_cr;
			_fmode[index]=MWRITE;
			}
/*		puts("\nnext char at "); hex(_fnext[index]); */
		return unit;
		}
	else if(c=='W')
		{cpm(19,fcb);		/* delete file */
		i=cpm(22,fcb);		/* create file */
		if(i<0) return 0;	/* creation failure */
		_fmode[index]=MWRITE;	/* open for writing */
		_fnext[index]=_ffirst[index];
				/* buffer is empty */
/*		puts("\nnext char at "); hex(_fnext[index]);*/
		return unit;
		}
	else return 0;
}

fclose(unit) int unit;	/* close a file */
{	int index,i,werror;
/*	puts("\nfclose: closing unit "); hexb(unit); */
	index=unit-5;
	i=fchk(index);
	if((i==MREAD)|(i==MEOF)) /* don't close read files */
		{_fmode[index]=MFREE;
		return 1;	/* success */
		}
	putb(26,unit);	/* append ^Z (CP/M EOF) */
	werror=fflush(unit);
	_fmode[index]=MFREE;
	if((cpm(16,_ffcb[index])<0)|werror)
		return 0; /* failure */
	return 1;	/* success */
}

fchk(index) int index;	/* check for legal index */
{	int i;
	if((index>=0)&(index<=NBUFS))
		{i=_fmode[index];
		if((i==MREAD)|(i==MWRITE)|(i==MEOF))
			return i;
		}
	err("INVALID UNIT NUMBER");
	exit();
}

getc(unit) int unit;	/* get character from file 
				(return -1 at EOF)  */
{	int c;
	while((c=getb(unit))==LF){}	/* discard LF */
	if(c==26)	/* CP/M EOF? */
		{if(unit>=5)	/* leave _fnext[index] pointing
					at the ^Z */
			{_fmode[unit-5]=MEOF;
			--_fnext[unit-5];
			}
		return -1;
		}
	return c;
}

getb(unit) int unit;	/* get byte from file 
				(return -1 at EOF)  */
{	int index,mode,i;
	char *next,*last,c,*fcb;

	if(unit==0)			/* STDIN */
		{c=cpm(1,0);
		if(c=='\n')cpm(2,LF);	/* add LF after CR */
		return c;
		}
	index=unit-5;
	mode=fchk(index);
	if(mode==MEOF) return -1;	/* already found eof */
	if(mode!=MREAD) {err("CAN\'T READ OUTFILE"); exit();}
	next=_fnext[index];
	if(next==_flast[index])	/* empty buffer? */
		{fcb=_ffcb[index];
		_ex=fcb[12]; _cr=fcb[32]; /* save for fopen() */
		next=_ffirst[index];
		last=next+LGH;
		while(next<last)
			{cpm(26,next);	/* set DMA */
			if(cpm(20,fcb))break;
			next=next+128;
			}
		cpm(26,128);		/* reset DMA */
		if(next==_ffirst[index])	/* no records read? */
			{/* _fmode[index]=MEOF; not needed */
			return -1;
			}
		_flast[index]=next;
		next=_ffirst[index];
		}
	c=*next++;
	_fnext[index]=next;
	return c;
}

putc(c,unit) char c; int unit;  /* write a character to a file */
{	putb(c,unit);
	if(c=='\n')putb(LF,unit);	/* add LF after CR */
	return c;
}

putb(c,unit) char c; int unit;  /* write a byte to a file */
{	int index,werror;
	char *next;
	if(unit==1)		/* STDOUT */
		{cpm(2,c);
		return c;
		}
	index=unit-5;
	if(fchk(index)!=MWRITE)
		{err("CAN\'T WRITE TO INFILE");
		exit();
		}
	if(_fnext[index]==_flast[index]) werror=fflush(unit);
	else werror=0;
	next=_fnext[index];
	*next++=c;
	_fnext[index]=next;
	if(werror) return werror;
	return c;
}

fflush(unit) int unit;  /* flush buffer to disk 
			(on error returns nonzero)*/
{	int index,i;
	char *next,*going;
	index=unit-5;
	if(fchk(index)!=MWRITE)
		{err("CAN\'T FLUSH INFILE");
		exit();
		}
/*	puts("\nfflush: must write out "); hex(_ffirst[index]);
	puts("through "); hex(_fnext[index]); */
	next=_fnext[index];
	going=_fnext[index]=_ffirst[index];
	while(going<next)
		{cpm(26,going); /* set DMA */
/*		puts("\n writing from "); hex(going); */
		if(cpm(21,_ffcb[index])) return -1; /* error? */
		going=going+128;
		}
	cpm(26,128); /* reset DMA */
	return 0;	/* no error */
}

upper(c) int c;		/* converts to upper case */
{	if(c>='a')return c-32;
	return c;
}

exit()
{	if(stdout>=5)fclose(stdout);
#asm
	JP	0
#endasm
}
#asm
;
; Runtime library initialization.
; Set up default drive for CP/M.
CCGO:	LD	C,25     ;get current disk
	CALL	BDOS
	INC	A	;now in range 1...16
	LD	(Q_DFLTDSK),A
	LD	HL,11387	;initialize the elements of
	LD	(Q_FMODE),HL	;_fmode[] (# entries = NBUFS)
	LD	(Q_FMODE+2),HL	;to reflect free buffers
	LD	(Q_FMODE+4),HL
	LD	HL,(HEAPTOP)	;current top of heap
	LD	(Q_FBUF),HL	;initialize buffer pointer
	LD	DE,3171		;= BUFLGH
	ADD	HL,DE		;hl=new top of heap
	LD	(HEAPTOP),HL
	LD	HL,0
	LD	(QSTDIN),HL	;initialize input unit
	INC	HL
	LD	(QSTDOUT),HL	;initialize output unit
	RET	
;Fetch a single byte from the address in HL and
; sign extend into HL
CCGCHAR: LD	A,(HL)
QARGC:
CCSXT:	LD	L,A
	RLCA	
	SBC	A,A
	LD	H,A
	RET	
;Fetch integer from (HL+2)
CCCDR:	INC	HL
	INC	HL
;Fetch a full 16-bit integer from the address in HL
CCCAR:
CCGINT:	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A
	RET	
;Store a 16-bit integer in HL at the address in TOS
CCPINT:	POP	BC
	POP	DE
	PUSH	BC
	LD	A,L
	LD	(DE),A
	INC	DE
	LD	A,H
	LD	(DE),A
	RET	
;Inclusive "or" HL and TOS into HL
CCOR:	POP	BC
	POP	DE
	PUSH	BC
	LD	A,L
	OR	E
	LD	L,A
	LD	A,H
	OR	D
	LD	H,A
	RET	
;Exclusive "or" HL and TOS into HL
CCXOR:	POP	BC
	POP	DE
	PUSH	BC
	LD	A,L
	XOR	E
	LD	L,A
	LD	A,H
	XOR	D
	LD	H,A
	RET	
;"And" HL and TOS into HL
CCAND:	POP	BC
	POP	DE
	PUSH	BC
	LD	A,L
	AND	E
	LD	L,A
	LD	A,H
	AND	D
	LD	H,A
	RET	
;Test if HL = TOS and set HL = 1 if true else 0
CCEQ:	POP	BC
	POP	DE
	PUSH	BC
	CALL	CCCMP
	RET	Z
	DEC	HL
	RET	
;Test if TOS ~= HL
CCNE:	POP	BC
	POP	DE
	PUSH	BC
	CALL	CCCMP
	RET	NZ
	DEC	HL
	RET	
;Test if TOS > HL (signed)
CCGT:	POP	BC
	POP	DE
	PUSH	BC
	EX	DE,HL
	CALL	CCCMP
	RET	C
	DEC	HL
	RET	
;Test if TOS <= HL (signed)
CCLE:	POP	BC
	POP	DE
	PUSH	BC
	CALL	CCCMP
	RET	Z
	RET	C
	DEC	HL
	RET	
;Test if TOS >= HL (signed)
CCGE:	POP	BC
	POP	DE
	PUSH	BC
	CALL	CCCMP
	RET	NC
	DEC	HL
	RET	
;Test if TOS < HL (signed)
CCLT:	POP	BC
	POP	DE
	PUSH	BC
	CALL	CCCMP
	RET	C
	DEC	HL
	RET	
;Common routine to perform a signed compare
; of DE and HL
;This routine performs DE - HL and sets the conditions:
;	Carry reflects sign of difference (set means DE < HL)
;	Zero/non-zero set according to equality.
CCCMP:	LD	A,E
	SUB	L
	LD	E,A
	LD	A,D
	SBC	A,H
	LD	HL,1	     ;preset true condition
	JP	M,CCCMP1
	OR	E	     ;"OR" resets carry
	RET	
CCCMP1:	OR	E
	SCF		     ;set carry to signal minus
	RET	
;
;Test if TOS >= HL (unsigned)
CCUGE:	POP	BC
	POP	DE
	PUSH	BC
	CALL	CCUCMP
	RET	NC
	DEC	HL
	RET	
;
;Test if TOS < HL (unsigned)
CCULT:	POP	BC
	POP	DE
	PUSH	BC
	CALL	CCUCMP
	RET	C
	DEC	HL
	RET	
;
;Test if TOS > HL (unsigned)
CCUGT:	POP	BC
	POP	DE
	PUSH	BC
	EX	DE,HL
	CALL	CCUCMP
	RET	C
	DEC	HL
	RET	
;
;Test if TOS <= HL (unsigned)
CCULE:	POP	BC
	POP	DE
	PUSH	BC
	CALL	CCUCMP
	RET	Z
	RET	C
	DEC	HL
	RET	
;
;Common routine to perform unsigned compare
;carry set if DE < HL
;zero/nonzero set accordingly
CCUCMP:	LD	A,D
	CP	H
	JP	NZ,CUCMP1
	LD	A,E
	CP	L
CUCMP1:	LD	HL,1
	RET	
;
;Shift DE arithmetically right by HL and return in HL
CCASR:	EX	DE,HL
	DEC	E
	RET	M	     ;			7/2/82  jrvz
	LD	A,H
	RLA	
	LD	A,H
	RRA	
	LD	H,A
	LD	A,L
	RRA	
	LD	L,A
	JP	CCASR+1
;Shift TOS arithmetically left by HL and return in HL
CCASL:	POP	BC
	POP	DE
	PUSH	BC
	EX	DE,HL
CCASL4:	DEC	E
	RET	M	     ;		jrvz 7/2/82
	ADD	HL,HL
	JP	CCASL4
;Subtract HL from TOS and return in HL
CCSUB:	POP	BC
	POP	DE
	PUSH	BC
	LD	A,E
	SUB	L
	LD	L,A
	LD	A,D
	SBC	A,H
	LD	H,A
	RET	
;Form the two's complement of HL
CCNEG:	CALL	CCCOM
	INC	HL
	RET	
;Form the one's complement of HL
CCCOM:	LD	A,H
	CPL	
	LD	H,A
	LD	A,L
	CPL	
	LD	L,A
	RET	
;Multiply TOS by HL and return in HL
CCMULT:	POP	BC
	POP	DE
	PUSH	BC
	LD	B,H
	LD	C,L
	LD	HL,0
CCMLT1:	LD	A,C
	RRCA	
	JP	NC,CMLT2
	ADD	HL,DE
CMLT2:	XOR	A
	LD	A,B
	RRA	
	LD	B,A
	LD	A,C
	RRA	
	LD	C,A
	OR	B
	RET	Z
	XOR	A
	LD	A,E
	RLA	
	LD	E,A
	LD	A,D
	RLA	
	LD	D,A
	OR	E
	RET	Z
	JP	CCMLT1
;Divide DE by HL and return quotient in HL, remainder in DE
CCDIV:	LD	B,H
	LD	C,L
	LD	A,D
	XOR	B
	PUSH	AF
	LD	A,D
	OR	A
	CALL	M,CCDENEG
	LD	A,B
	OR	A
	CALL	M,CCBCNEG
	LD	A,16
	PUSH	AF
	EX	DE,HL
	LD	DE,0
CCDIV1:	ADD	HL,HL
	CALL	CCRDEL
	JP	Z,CCDIV2
	CALL	CCPBCDE
	JP	M,CCDIV2
	LD	A,L
	OR	1
	LD	L,A
	LD	A,E
	SUB	C
	LD	E,A
	LD	A,D
	SBC	A,B
	LD	D,A
CCDIV2:	POP	AF
	DEC	A
	JP	Z,CCDIV3
	PUSH	AF
	JP	CCDIV1
CCDIV3:	POP	AF
	RET	P
	CALL	CCDENEG
	EX	DE,HL
	CALL	CCDENEG
	EX	DE,HL
	RET	
CCDENEG: LD	A,D
	CPL	
	LD	D,A
	LD	A,E
	CPL	
	LD	E,A
	INC	DE
	RET	
CCBCNEG: LD	A,B
	CPL	
	LD	B,A
	LD	A,C
	CPL	
	LD	C,A
	INC	BC
	RET	
CCRDEL:	LD	A,E
	RLA	
	LD	E,A
	LD	A,D
	RLA	
	LD	D,A
	OR	E
	RET	
CCPBCDE: LD	A,E
	SUB	C
	LD	A,D
	SBC	A,B
	RET	
#endasm
/*
hex(x) int x;
{	hexb(x>>8); hexb(x); putchar(' ');
}
hexb(x) int x;
{	hexn(x>>4); hexn(x);
}
hexn(x) int x;
{	x=x&15;
	if(x<10) putchar(x+'0');
	else putchar(x-10+'a');
}
*/
                      