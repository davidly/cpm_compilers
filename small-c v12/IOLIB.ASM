;* * *  Small-C  V1.2  * * *
;       By Ron Cain  and  James Van Zandt
;     2 August 1984
;
	GLOBAL	CCAND
	GLOBAL	CCASR
	GLOBAL	CCASL
	GLOBAL	CCCDR
	GLOBAL	CCCAR
	GLOBAL	CCCMP
	GLOBAL	CCCMP1
	GLOBAL	CCCOM
	GLOBAL	CCDIV
	GLOBAL	CCEQ
	GLOBAL	CCGE
	GLOBAL	CCGO
	GLOBAL	CCGCHAR
	GLOBAL	CCGINT
	GLOBAL	CCGT
	GLOBAL	CCLE
	GLOBAL	CCLT
	GLOBAL	CCMULT
	GLOBAL	CCNE
	GLOBAL	CCNEG
	GLOBAL	CCOR
	GLOBAL	CCPINT
	GLOBAL	CCSUB
	GLOBAL	CCSXT
	GLOBAL	CCUCMP
	GLOBAL	CCUGE
	GLOBAL	CCUGT
	GLOBAL	CCULE
	GLOBAL	CCULT
	GLOBAL	CCXOR
	GLOBAL	CURRENT
	GLOBAL	ERR2
	GLOBAL	QALLOC
	GLOBAL	QARGC
	GLOBAL	QAVAIL
	GLOBAL	QCPM
	GLOBAL	QERR
	GLOBAL	QEXIT
	GLOBAL	QFCLOSE
	GLOBAL	QFOPEN
	GLOBAL	QFREE
	GLOBAL	QGETB
	GLOBAL	QGETC
	GLOBAL	QGETCHA
	GLOBAL	QGETS
	GLOBAL	QPUTB
	GLOBAL	QPUTC
	GLOBAL	QPUTCHA
	GLOBAL	QPUTS
	GLOBAL	_END
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
	global q_dfltdsk
	global qstdin
	global qstdout
	global qgetchar
qgetchar:
	global qgetc
	LD HL,(qstdin)
	PUSH HL
	CALL qgetc
	POP BC
	RET
	global qputchar
qputchar:
	global qputc
	LD HL,2
	ADD HL,SP
	CALL ccgchar
	PUSH HL
	LD HL,(qstdout)
	PUSH HL
	CALL qputc
	POP BC
	POP BC
	LD HL,2
	ADD HL,SP
	CALL ccgchar
	RET
	global qgets
qgets:
	DEC SP
	DEC SP
	PUSH BC
	LD HL,(qstdin)
	LD A,H
	OR L
	JP Z,cc5
	LD HL,0
	ADD HL,SP
	PUSH HL
	LD HL,80
	CALL ccpint
cc6:
	LD HL,0
	ADD HL,SP
	PUSH HL
	CALL ccgint
	DEC HL
	CALL ccpint
	INC HL
	LD A,H
	OR L
	JP Z,cc7
	LD HL,3
	ADD HL,SP
	PUSH HL
	LD HL,(qstdin)
	PUSH HL
	CALL qgetc
	POP BC
	POP DE
	LD A,L
	LD (DE),A
	LD HL,3
	ADD HL,SP
	CALL ccgchar
	PUSH HL
	LD HL,1
	CALL ccneg
	CALL cceq
	PUSH HL
	LD HL,5
	ADD HL,SP
	CALL ccgchar
	PUSH HL
	LD HL,13
	CALL cceq
	CALL ccor
	LD A,H
	OR L
	JP Z,cc8
	JP cc7
cc8:
	LD HL,6
	ADD HL,SP
	PUSH HL
	CALL ccgint
	INC HL
	CALL ccpint
	DEC HL
	PUSH HL
	LD HL,5
	ADD HL,SP
	CALL ccgchar
	POP DE
	LD A,L
	LD (DE),A
	JP cc6
cc7:
	LD HL,6
	ADD HL,SP
	CALL ccgint
	PUSH HL
	LD HL,0
	POP DE
	LD A,L
	LD (DE),A
	JP cc9
cc5:
	LD HL,2
	ADD HL,SP
	PUSH HL
	LD HL,8
	ADD HL,SP
	CALL ccgint
	PUSH HL
	LD HL,2
	CALL ccneg
	POP DE
	ADD HL,DE
	CALL ccgchar
	POP DE
	LD A,L
	LD (DE),A
	LD HL,3
	ADD HL,SP
	PUSH HL
	LD HL,8
	ADD HL,SP
	CALL ccgint
	PUSH HL
	LD HL,1
	CALL ccneg
	POP DE
	ADD HL,DE
	CALL ccgchar
	POP DE
	LD A,L
	LD (DE),A
	LD HL,6
	ADD HL,SP
	CALL ccgint
	PUSH HL
	LD HL,2
	CALL ccneg
	POP DE
	ADD HL,DE
	PUSH HL
	LD HL,80
	POP DE
	LD A,L
	LD (DE),A
	global qcpm
	LD HL,10
	PUSH HL
	LD HL,8
	ADD HL,SP
	CALL ccgint
	PUSH HL
	LD HL,2
	CALL ccsub
	PUSH HL
	CALL qcpm
	POP BC
	POP BC
	LD HL,6
	ADD HL,SP
	CALL ccgint
	PUSH HL
	LD HL,8
	ADD HL,SP
	CALL ccgint
	PUSH HL
	LD HL,1
	CALL ccneg
	POP DE
	ADD HL,DE
	CALL ccgchar
	POP DE
	ADD HL,DE
	PUSH HL
	LD HL,0
	POP DE
	LD A,L
	LD (DE),A
	LD HL,6
	ADD HL,SP
	CALL ccgint
	PUSH HL
	LD HL,1
	CALL ccneg
	POP DE
	ADD HL,DE
	PUSH HL
	LD HL,5
	ADD HL,SP
	CALL ccgchar
	POP DE
	LD A,L
	LD (DE),A
	LD HL,6
	ADD HL,SP
	CALL ccgint
	PUSH HL
	LD HL,2
	CALL ccneg
	POP DE
	ADD HL,DE
	PUSH HL
	LD HL,4
	ADD HL,SP
	CALL ccgchar
	POP DE
	LD A,L
	LD (DE),A
	LD HL,10
	PUSH HL
	CALL qputchar
	POP BC
cc9:
	POP BC
	POP BC
	RET
	global qputs
qputs:
	DEC SP
cc11:
	LD HL,0
	ADD HL,SP
	PUSH HL
	LD HL,5
	ADD HL,SP
	PUSH HL
	CALL ccgint
	INC HL
	CALL ccpint
	DEC HL
	CALL ccgchar
	POP DE
	LD A,L
	LD (DE),A
	LD A,H
	OR L
	JP Z,cc12
	LD HL,0
	ADD HL,SP
	CALL ccgchar
	PUSH HL
	CALL qputchar
	POP BC
	JP cc11
cc12:
	INC SP
	RET
	global q_fbuf
	global q_ffcb
	global q_fnext
	global q_ffirst
	global q_flast
	global q_fmode
	global q_ex
	global q_cr
	global qfopen
qfopen:
	DEC SP
	PUSH BC
	PUSH BC
	PUSH BC
	PUSH BC
	LD HL,4
	ADD HL,SP
	PUSH HL
	LD HL,3
	CALL ccpint
cc14:
	LD HL,4
	ADD HL,SP
	PUSH HL
	CALL ccgint
	DEC HL
	CALL ccpint
	INC HL
	LD A,H
	OR L
	JP Z,cc15
	LD HL,q_fmode
	PUSH HL
	LD HL,6
	ADD HL,SP
	CALL ccgint
	ADD HL,HL
	POP DE
	ADD HL,DE
	CALL ccgint
	PUSH HL
	LD HL,11387
	CALL cceq
	LD A,H
	OR L
	JP Z,cc16
	JP cc15
cc16:
	JP cc14
cc15:
	LD HL,4
	ADD HL,SP
	CALL ccgint
	PUSH HL
	LD HL,1
	CALL ccneg
	CALL cceq
	LD A,H
	OR L
	JP Z,cc17
	global qerr
	LD HL,cc13+0
	PUSH HL
	CALL qerr
	POP BC
	global qexit
	CALL qexit
cc17:
	LD HL,0
	ADD HL,SP
	PUSH HL
	LD HL,6
	ADD HL,SP
	CALL ccgint
	PUSH HL
	LD HL,5
	POP DE
	ADD HL,DE
	CALL ccpint
	LD HL,q_ffcb
	PUSH HL
	LD HL,6
	ADD HL,SP
	CALL ccgint
	ADD HL,HL
	POP DE
	ADD HL,DE
	PUSH HL
	LD HL,(q_fbuf)
	PUSH HL
	LD HL,8
	ADD HL,SP
	CALL ccgint
	PUSH HL
	LD HL,33
	PUSH HL
	LD HL,1024
	POP DE
	ADD HL,DE
	CALL ccmult
	POP DE
	ADD HL,DE
	CALL ccpint
	LD HL,q_ffirst
	PUSH HL
	LD HL,6
	ADD HL,SP
	CALL ccgint
	ADD HL,HL
	POP DE
	ADD HL,DE
	PUSH HL
	LD HL,q_ffcb
	PUSH HL
	LD HL,8
	ADD HL,SP
	CALL ccgint
	ADD HL,HL
	POP DE
	ADD HL,DE
	CALL ccgint
	PUSH HL
	LD HL,33
	POP DE
	ADD HL,DE
	CALL ccpint
	LD HL,q_flast
	PUSH HL
	LD HL,6
	ADD HL,SP
	CALL ccgint
	ADD HL,HL
	POP DE
	ADD HL,DE
	PUSH HL
	LD HL,q_ffirst
	PUSH HL
	LD HL,8
	ADD HL,SP
	CALL ccgint
	ADD HL,HL
	POP DE
	ADD HL,DE
	CALL ccgint
	PUSH HL
	LD HL,1024
	POP DE
	ADD HL,DE
	CALL ccpint
	LD HL,6
	ADD HL,SP
	PUSH HL
	LD HL,q_ffcb
	PUSH HL
	LD HL,8
	ADD HL,SP
	CALL ccgint
	ADD HL,HL
	POP DE
	ADD HL,DE
	CALL ccgint
	CALL ccpint
	LD HL,2
	ADD HL,SP
	PUSH HL
	LD HL,11
	CALL ccpint
cc18:
	LD HL,2
	ADD HL,SP
	CALL ccgint
	LD A,H
	OR L
	JP Z,cc19
	LD HL,6
	ADD HL,SP
	CALL ccgint
	PUSH HL
	LD HL,4
	ADD HL,SP
	PUSH HL
	CALL ccgint
	DEC HL
	CALL ccpint
	INC HL
	POP DE
	ADD HL,DE
	PUSH HL
	LD HL,32
	POP DE
	LD A,L
	LD (DE),A
	JP cc18
cc19:
	LD HL,6
	ADD HL,SP
	CALL ccgint
	PUSH HL
	LD HL,12
	POP DE
	ADD HL,DE
	PUSH HL
	LD HL,8
	ADD HL,SP
	CALL ccgint
	PUSH HL
	LD HL,32
	POP DE
	ADD HL,DE
	PUSH HL
	LD HL,0
	POP DE
	LD A,L
	LD (DE),A
	POP DE
	LD A,L
	LD (DE),A
	LD HL,13
	ADD HL,SP
	CALL ccgint
	PUSH HL
	LD HL,1
	POP DE
	ADD HL,DE
	CALL ccgchar
	PUSH HL
	LD HL,58
	CALL cceq
	LD A,H
	OR L
	JP Z,cc20
	LD HL,6
	ADD HL,SP
	CALL ccgint
	PUSH HL
	LD HL,0
	POP DE
	ADD HL,DE
	PUSH HL
	LD HL,15
	ADD HL,SP
	CALL ccgint
	CALL ccgchar
	PUSH HL
	LD HL,15
	CALL ccand
	PUSH HL
	LD HL,1
	POP DE
	ADD HL,DE
	POP DE
	LD A,L
	LD (DE),A
	LD HL,13
	ADD HL,SP
	PUSH HL
	LD HL,15
	ADD HL,SP
	CALL ccgint
	PUSH HL
	LD HL,2
	POP DE
	ADD HL,DE
	CALL ccpint
	JP cc21
cc20:
	LD HL,6
	ADD HL,SP
	CALL ccgint
	PUSH HL
	LD HL,0
	POP DE
	ADD HL,DE
	PUSH HL
	LD HL,(q_dfltdsk)
	POP DE
	LD A,L
	LD (DE),A
cc21:
cc22:
	LD HL,8
	ADD HL,SP
	PUSH HL
	global qupper
	LD HL,15
	ADD HL,SP
	PUSH HL
	CALL ccgint
	INC HL
	CALL ccpint
	DEC HL
	CALL ccgchar
	PUSH HL
	CALL qupper
	POP BC
	POP DE
	LD A,L
	LD (DE),A
	LD A,H
	OR L
	JP Z,cc23
	LD HL,8
	ADD HL,SP
	CALL ccgchar
	PUSH HL
	LD HL,46
	CALL cceq
	LD A,H
	OR L
	JP Z,cc24
	JP cc23
cc24:
	LD HL,6
	ADD HL,SP
	CALL ccgint
	PUSH HL
	LD HL,4
	ADD HL,SP
	PUSH HL
	CALL ccgint
	INC HL
	CALL ccpint
	POP DE
	ADD HL,DE
	PUSH HL
	LD HL,10
	ADD HL,SP
	CALL ccgchar
	POP DE
	LD A,L
	LD (DE),A
	JP cc22
cc23:
	LD HL,8
	ADD HL,SP
	CALL ccgchar
	PUSH HL
	LD HL,46
	CALL cceq
	LD A,H
	OR L
	JP Z,cc25
	LD HL,2
	ADD HL,SP
	PUSH HL
	LD HL,8
	CALL ccpint
cc26:
	LD HL,8
	ADD HL,SP
	PUSH HL
	LD HL,15
	ADD HL,SP
	PUSH HL
	CALL ccgint
	INC HL
	CALL ccpint
	DEC HL
	CALL ccgchar
	PUSH HL
	CALL qupper
	POP BC
	POP DE
	LD A,L
	LD (DE),A
	LD A,H
	OR L
	JP Z,cc27
	LD HL,6
	ADD HL,SP
	CALL ccgint
	PUSH HL
	LD HL,4
	ADD HL,SP
	PUSH HL
	CALL ccgint
	INC HL
	CALL ccpint
	POP DE
	ADD HL,DE
	PUSH HL
	LD HL,10
	ADD HL,SP
	CALL ccgchar
	POP DE
	LD A,L
	LD (DE),A
	JP cc26
cc27:
cc25:
	LD HL,8
	ADD HL,SP
	PUSH HL
	LD HL,13
	ADD HL,SP
	CALL ccgint
	CALL ccgchar
	PUSH HL
	CALL qupper
	POP BC
	POP DE
	LD A,L
	LD (DE),A
	LD HL,8
	ADD HL,SP
	CALL ccgchar
	PUSH HL
	LD HL,82
	CALL cceq
	PUSH HL
	LD HL,10
	ADD HL,SP
	CALL ccgchar
	PUSH HL
	LD HL,65
	CALL cceq
	CALL ccor
	LD A,H
	OR L
	JP Z,cc28
	LD HL,15
	PUSH HL
	LD HL,8
	ADD HL,SP
	CALL ccgint
	PUSH HL
	CALL qcpm
	POP BC
	POP BC
	PUSH HL
	LD HL,0
	CALL cclt
	LD A,H
	OR L
	JP Z,cc29
	LD HL,0
	EX DE,HL
	LD HL,9
	ADD HL,SP
	LD SP,HL
	EX DE,HL
	RET
cc29:
	LD HL,q_fmode
	PUSH HL
	LD HL,6
	ADD HL,SP
	CALL ccgint
	ADD HL,HL
	POP DE
	ADD HL,DE
	PUSH HL
	LD HL,22489
	CALL ccpint
	LD HL,q_fnext
	PUSH HL
	LD HL,6
	ADD HL,SP
	CALL ccgint
	ADD HL,HL
	POP DE
	ADD HL,DE
	PUSH HL
	LD HL,q_flast
	PUSH HL
	LD HL,8
	ADD HL,SP
	CALL ccgint
	ADD HL,HL
	POP DE
	ADD HL,DE
	CALL ccgint
	CALL ccpint
	LD HL,8
	ADD HL,SP
	CALL ccgchar
	PUSH HL
	LD HL,65
	CALL cceq
	LD A,H
	OR L
	JP Z,cc30
cc31:
	LD HL,0
	ADD HL,SP
	CALL ccgint
	PUSH HL
	CALL qgetc
	POP BC
	PUSH HL
	LD HL,1
	CALL ccneg
	CALL ccne
	LD A,H
	OR L
	JP Z,cc32
	JP cc31
cc32:
	LD HL,6
	ADD HL,SP
	CALL ccgint
	PUSH HL
	LD HL,12
	POP DE
	ADD HL,DE
	PUSH HL
	LD HL,(q_ex)
	POP DE
	LD A,L
	LD (DE),A
	LD HL,15
	PUSH HL
	LD HL,8
	ADD HL,SP
	CALL ccgint
	PUSH HL
	CALL qcpm
	POP BC
	POP BC
	LD HL,6
	ADD HL,SP
	CALL ccgint
	PUSH HL
	LD HL,32
	POP DE
	ADD HL,DE
	PUSH HL
	LD HL,(q_cr)
	POP DE
	LD A,L
	LD (DE),A
	LD HL,q_fmode
	PUSH HL
	LD HL,6
	ADD HL,SP
	CALL ccgint
	ADD HL,HL
	POP DE
	ADD HL,DE
	PUSH HL
	LD HL,17325
	CALL ccpint
cc30:
	LD HL,0
	ADD HL,SP
	CALL ccgint
	EX DE,HL
	LD HL,9
	ADD HL,SP
	LD SP,HL
	EX DE,HL
	RET
	JP cc33
cc28:
	LD HL,8
	ADD HL,SP
	CALL ccgchar
	PUSH HL
	LD HL,87
	CALL cceq
	LD A,H
	OR L
	JP Z,cc34
	LD HL,19
	PUSH HL
	LD HL,8
	ADD HL,SP
	CALL ccgint
	PUSH HL
	CALL qcpm
	POP BC
	POP BC
	LD HL,2
	ADD HL,SP
	PUSH HL
	LD HL,22
	PUSH HL
	LD HL,10
	ADD HL,SP
	CALL ccgint
	PUSH HL
	CALL qcpm
	POP BC
	POP BC
	CALL ccpint
	LD HL,2
	ADD HL,SP
	CALL ccgint
	PUSH HL
	LD HL,0
	CALL cclt
	LD A,H
	OR L
	JP Z,cc35
	LD HL,0
	EX DE,HL
	LD HL,9
	ADD HL,SP
	LD SP,HL
	EX DE,HL
	RET
cc35:
	LD HL,q_fmode
	PUSH HL
	LD HL,6
	ADD HL,SP
	CALL ccgint
	ADD HL,HL
	POP DE
	ADD HL,DE
	PUSH HL
	LD HL,17325
	CALL ccpint
	LD HL,q_fnext
	PUSH HL
	LD HL,6
	ADD HL,SP
	CALL ccgint
	ADD HL,HL
	POP DE
	ADD HL,DE
	PUSH HL
	LD HL,q_ffirst
	PUSH HL
	LD HL,8
	ADD HL,SP
	CALL ccgint
	ADD HL,HL
	POP DE
	ADD HL,DE
	CALL ccgint
	CALL ccpint
	LD HL,0
	ADD HL,SP
	CALL ccgint
	EX DE,HL
	LD HL,9
	ADD HL,SP
	LD SP,HL
	EX DE,HL
	RET
	JP cc36
cc34:
	LD HL,0
	EX DE,HL
	LD HL,9
	ADD HL,SP
	LD SP,HL
	EX DE,HL
	RET
cc36:
cc33:
	EX DE,HL
	LD HL,9
	ADD HL,SP
	LD SP,HL
	EX DE,HL
	RET
cc13:	DEFB 79,85,84,32,79,70,32,68,73,83
	DEFB 75,32,66,85,70,70,69,82,83,0
	global qfclose
qfclose:
	PUSH BC
	PUSH BC
	PUSH BC
	LD HL,4
	ADD HL,SP
	PUSH HL
	LD HL,10
	ADD HL,SP
	CALL ccgint
	PUSH HL
	LD HL,5
	CALL ccsub
	CALL ccpint
	LD HL,2
	ADD HL,SP
	PUSH HL
	global qfchk
	LD HL,6
	ADD HL,SP
	CALL ccgint
	PUSH HL
	CALL qfchk
	POP BC
	CALL ccpint
	LD HL,2
	ADD HL,SP
	CALL ccgint
	PUSH HL
	LD HL,22489
	CALL cceq
	PUSH HL
	LD HL,4
	ADD HL,SP
	CALL ccgint
	PUSH HL
	LD HL,8734
	CALL ccneg
	CALL cceq
	CALL ccor
	LD A,H
	OR L
	JP Z,cc38
	LD HL,q_fmode
	PUSH HL
	LD HL,6
	ADD HL,SP
	CALL ccgint
	ADD HL,HL
	POP DE
	ADD HL,DE
	PUSH HL
	LD HL,11387
	CALL ccpint
	LD HL,1
	POP BC
	POP BC
	POP BC
	RET
cc38:
	global qputb
	LD HL,26
	PUSH HL
	LD HL,10
	ADD HL,SP
	CALL ccgint
	PUSH HL
	CALL qputb
	POP BC
	POP BC
	LD HL,0
	ADD HL,SP
	PUSH HL
	global qfflush
	LD HL,10
	ADD HL,SP
	CALL ccgint
	PUSH HL
	CALL qfflush
	POP BC
	CALL ccpint
	LD HL,q_fmode
	PUSH HL
	LD HL,6
	ADD HL,SP
	CALL ccgint
	ADD HL,HL
	POP DE
	ADD HL,DE
	PUSH HL
	LD HL,11387
	CALL ccpint
	LD HL,16
	PUSH HL
	LD HL,q_ffcb
	PUSH HL
	LD HL,8
	ADD HL,SP
	CALL ccgint
	ADD HL,HL
	POP DE
	ADD HL,DE
	CALL ccgint
	PUSH HL
	CALL qcpm
	POP BC
	POP BC
	PUSH HL
	LD HL,0
	CALL cclt
	PUSH HL
	LD HL,2
	ADD HL,SP
	CALL ccgint
	CALL ccor
	LD A,H
	OR L
	JP Z,cc39
	LD HL,0
	POP BC
	POP BC
	POP BC
	RET
cc39:
	LD HL,1
	POP BC
	POP BC
	POP BC
	RET
qfchk:
	PUSH BC
	LD HL,4
	ADD HL,SP
	CALL ccgint
	PUSH HL
	LD HL,0
	CALL ccge
	PUSH HL
	LD HL,6
	ADD HL,SP
	CALL ccgint
	PUSH HL
	LD HL,3
	CALL ccle
	CALL ccand
	LD A,H
	OR L
	JP Z,cc41
	LD HL,0
	ADD HL,SP
	PUSH HL
	LD HL,q_fmode
	PUSH HL
	LD HL,8
	ADD HL,SP
	CALL ccgint
	ADD HL,HL
	POP DE
	ADD HL,DE
	CALL ccgint
	CALL ccpint
	LD HL,0
	ADD HL,SP
	CALL ccgint
	PUSH HL
	LD HL,22489
	CALL cceq
	PUSH HL
	LD HL,2
	ADD HL,SP
	CALL ccgint
	PUSH HL
	LD HL,17325
	CALL cceq
	CALL ccor
	PUSH HL
	LD HL,2
	ADD HL,SP
	CALL ccgint
	PUSH HL
	LD HL,8734
	CALL ccneg
	CALL cceq
	CALL ccor
	LD A,H
	OR L
	JP Z,cc42
	LD HL,0
	ADD HL,SP
	CALL ccgint
	POP BC
	RET
cc42:
cc41:
	LD HL,cc40+0
	PUSH HL
	CALL qerr
	POP BC
	CALL qexit
	POP BC
	RET
cc40:	DEFB 73,78,86,65,76,73,68,32,85,78
	DEFB 73,84,32,78,85,77,66,69,82,0
qgetc:
	PUSH BC
cc44:
	LD HL,0
	ADD HL,SP
	PUSH HL
	global qgetb
	LD HL,6
	ADD HL,SP
	CALL ccgint
	PUSH HL
	CALL qgetb
	POP BC
	CALL ccpint
	PUSH HL
	LD HL,10
	CALL cceq
	LD A,H
	OR L
	JP Z,cc45
	JP cc44
cc45:
	LD HL,0
	ADD HL,SP
	CALL ccgint
	PUSH HL
	LD HL,26
	CALL cceq
	LD A,H
	OR L
	JP Z,cc46
	LD HL,4
	ADD HL,SP
	CALL ccgint
	PUSH HL
	LD HL,5
	CALL ccge
	LD A,H
	OR L
	JP Z,cc47
	LD HL,q_fmode
	PUSH HL
	LD HL,6
	ADD HL,SP
	CALL ccgint
	PUSH HL
	LD HL,5
	CALL ccsub
	ADD HL,HL
	POP DE
	ADD HL,DE
	PUSH HL
	LD HL,8734
	CALL ccneg
	CALL ccpint
	LD HL,q_fnext
	PUSH HL
	LD HL,6
	ADD HL,SP
	CALL ccgint
	PUSH HL
	LD HL,5
	CALL ccsub
	ADD HL,HL
	POP DE
	ADD HL,DE
	PUSH HL
	CALL ccgint
	DEC HL
	CALL ccpint
cc47:
	LD HL,1
	CALL ccneg
	POP BC
	RET
cc46:
	LD HL,0
	ADD HL,SP
	CALL ccgint
	POP BC
	RET
qgetb:
	PUSH BC
	PUSH BC
	PUSH BC
	PUSH BC
	PUSH BC
	DEC SP
	PUSH BC
	LD HL,15
	ADD HL,SP
	CALL ccgint
	PUSH HL
	LD HL,0
	CALL cceq
	LD A,H
	OR L
	JP Z,cc49
	LD HL,2
	ADD HL,SP
	PUSH HL
	LD HL,1
	PUSH HL
	LD HL,0
	PUSH HL
	CALL qcpm
	POP BC
	POP BC
	POP DE
	LD A,L
	LD (DE),A
	LD HL,2
	ADD HL,SP
	CALL ccgchar
	PUSH HL
	LD HL,13
	CALL cceq
	LD A,H
	OR L
	JP Z,cc50
	LD HL,2
	PUSH HL
	LD HL,10
	PUSH HL
	CALL qcpm
	POP BC
	POP BC
cc50:
	LD HL,2
	ADD HL,SP
	CALL ccgchar
	EX DE,HL
	LD HL,13
	ADD HL,SP
	LD SP,HL
	EX DE,HL
	RET
cc49:
	LD HL,11
	ADD HL,SP
	PUSH HL
	LD HL,17
	ADD HL,SP
	CALL ccgint
	PUSH HL
	LD HL,5
	CALL ccsub
	CALL ccpint
	LD HL,9
	ADD HL,SP
	PUSH HL
	LD HL,13
	ADD HL,SP
	CALL ccgint
	PUSH HL
	CALL qfchk
	POP BC
	CALL ccpint
	LD HL,9
	ADD HL,SP
	CALL ccgint
	PUSH HL
	LD HL,8734
	CALL ccneg
	CALL cceq
	LD A,H
	OR L
	JP Z,cc51
	LD HL,1
	CALL ccneg
	EX DE,HL
	LD HL,13
	ADD HL,SP
	LD SP,HL
	EX DE,HL
	RET
cc51:
	LD HL,9
	ADD HL,SP
	CALL ccgint
	PUSH HL
	LD HL,22489
	CALL ccne
	LD A,H
	OR L
	JP Z,cc52
	LD HL,cc48+0
	PUSH HL
	CALL qerr
	POP BC
	CALL qexit
cc52:
	LD HL,5
	ADD HL,SP
	PUSH HL
	LD HL,q_fnext
	PUSH HL
	LD HL,15
	ADD HL,SP
	CALL ccgint
	ADD HL,HL
	POP DE
	ADD HL,DE
	CALL ccgint
	CALL ccpint
	LD HL,5
	ADD HL,SP
	CALL ccgint
	PUSH HL
	LD HL,q_flast
	PUSH HL
	LD HL,15
	ADD HL,SP
	CALL ccgint
	ADD HL,HL
	POP DE
	ADD HL,DE
	CALL ccgint
	CALL cceq
	LD A,H
	OR L
	JP Z,cc53
	LD HL,0
	ADD HL,SP
	PUSH HL
	LD HL,q_ffcb
	PUSH HL
	LD HL,15
	ADD HL,SP
	CALL ccgint
	ADD HL,HL
	POP DE
	ADD HL,DE
	CALL ccgint
	CALL ccpint
	LD HL,0
	ADD HL,SP
	CALL ccgint
	PUSH HL
	LD HL,12
	POP DE
	ADD HL,DE
	CALL ccgchar
	LD (q_ex),HL
	LD HL,0
	ADD HL,SP
	CALL ccgint
	PUSH HL
	LD HL,32
	POP DE
	ADD HL,DE
	CALL ccgchar
	LD (q_cr),HL
	LD HL,5
	ADD HL,SP
	PUSH HL
	LD HL,q_ffirst
	PUSH HL
	LD HL,15
	ADD HL,SP
	CALL ccgint
	ADD HL,HL
	POP DE
	ADD HL,DE
	CALL ccgint
	CALL ccpint
	LD HL,3
	ADD HL,SP
	PUSH HL
	LD HL,7
	ADD HL,SP
	CALL ccgint
	PUSH HL
	LD HL,1024
	POP DE
	ADD HL,DE
	CALL ccpint
cc54:
	LD HL,5
	ADD HL,SP
	CALL ccgint
	PUSH HL
	LD HL,5
	ADD HL,SP
	CALL ccgint
	CALL ccult
	LD A,H
	OR L
	JP Z,cc55
	LD HL,26
	PUSH HL
	LD HL,7
	ADD HL,SP
	CALL ccgint
	PUSH HL
	CALL qcpm
	POP BC
	POP BC
	LD HL,20
	PUSH HL
	LD HL,2
	ADD HL,SP
	CALL ccgint
	PUSH HL
	CALL qcpm
	POP BC
	POP BC
	LD A,H
	OR L
	JP Z,cc56
	JP cc55
cc56:
	LD HL,5
	ADD HL,SP
	PUSH HL
	LD HL,7
	ADD HL,SP
	CALL ccgint
	PUSH HL
	LD HL,128
	POP DE
	ADD HL,DE
	CALL ccpint
	JP cc54
cc55:
	LD HL,26
	PUSH HL
	LD HL,128
	PUSH HL
	CALL qcpm
	POP BC
	POP BC
	LD HL,5
	ADD HL,SP
	CALL ccgint
	PUSH HL
	LD HL,q_ffirst
	PUSH HL
	LD HL,15
	ADD HL,SP
	CALL ccgint
	ADD HL,HL
	POP DE
	ADD HL,DE
	CALL ccgint
	CALL cceq
	LD A,H
	OR L
	JP Z,cc57
	LD HL,1
	CALL ccneg
	EX DE,HL
	LD HL,13
	ADD HL,SP
	LD SP,HL
	EX DE,HL
	RET
cc57:
	LD HL,q_flast
	PUSH HL
	LD HL,13
	ADD HL,SP
	CALL ccgint
	ADD HL,HL
	POP DE
	ADD HL,DE
	PUSH HL
	LD HL,7
	ADD HL,SP
	CALL ccgint
	CALL ccpint
	LD HL,5
	ADD HL,SP
	PUSH HL
	LD HL,q_ffirst
	PUSH HL
	LD HL,15
	ADD HL,SP
	CALL ccgint
	ADD HL,HL
	POP DE
	ADD HL,DE
	CALL ccgint
	CALL ccpint
cc53:
	LD HL,2
	ADD HL,SP
	PUSH HL
	LD HL,7
	ADD HL,SP
	PUSH HL
	CALL ccgint
	INC HL
	CALL ccpint
	DEC HL
	CALL ccgchar
	POP DE
	LD A,L
	LD (DE),A
	LD HL,q_fnext
	PUSH HL
	LD HL,13
	ADD HL,SP
	CALL ccgint
	ADD HL,HL
	POP DE
	ADD HL,DE
	PUSH HL
	LD HL,7
	ADD HL,SP
	CALL ccgint
	CALL ccpint
	LD HL,2
	ADD HL,SP
	CALL ccgchar
	EX DE,HL
	LD HL,13
	ADD HL,SP
	LD SP,HL
	EX DE,HL
	RET
cc48:	DEFB 67,65,78,39,84,32,82,69,65,68
	DEFB 32,79,85,84,70,73,76,69,0
qputc:
	LD HL,4
	ADD HL,SP
	CALL ccgchar
	PUSH HL
	LD HL,4
	ADD HL,SP
	CALL ccgint
	PUSH HL
	CALL qputb
	POP BC
	POP BC
	LD HL,4
	ADD HL,SP
	CALL ccgchar
	PUSH HL
	LD HL,13
	CALL cceq
	LD A,H
	OR L
	JP Z,cc59
	LD HL,10
	PUSH HL
	LD HL,4
	ADD HL,SP
	CALL ccgint
	PUSH HL
	CALL qputb
	POP BC
	POP BC
cc59:
	LD HL,4
	ADD HL,SP
	CALL ccgchar
	RET
qputb:
	PUSH BC
	PUSH BC
	PUSH BC
	LD HL,8
	ADD HL,SP
	CALL ccgint
	PUSH HL
	LD HL,1
	CALL cceq
	LD A,H
	OR L
	JP Z,cc61
	LD HL,2
	PUSH HL
	LD HL,12
	ADD HL,SP
	CALL ccgchar
	PUSH HL
	CALL qcpm
	POP BC
	POP BC
	LD HL,10
	ADD HL,SP
	CALL ccgchar
	POP BC
	POP BC
	POP BC
	RET
cc61:
	LD HL,4
	ADD HL,SP
	PUSH HL
	LD HL,10
	ADD HL,SP
	CALL ccgint
	PUSH HL
	LD HL,5
	CALL ccsub
	CALL ccpint
	LD HL,4
	ADD HL,SP
	CALL ccgint
	PUSH HL
	CALL qfchk
	POP BC
	PUSH HL
	LD HL,17325
	CALL ccne
	LD A,H
	OR L
	JP Z,cc62
	LD HL,cc60+0
	PUSH HL
	CALL qerr
	POP BC
	CALL qexit
cc62:
	LD HL,q_fnext
	PUSH HL
	LD HL,6
	ADD HL,SP
	CALL ccgint
	ADD HL,HL
	POP DE
	ADD HL,DE
	CALL ccgint
	PUSH HL
	LD HL,q_flast
	PUSH HL
	LD HL,8
	ADD HL,SP
	CALL ccgint
	ADD HL,HL
	POP DE
	ADD HL,DE
	CALL ccgint
	CALL cceq
	LD A,H
	OR L
	JP Z,cc63
	LD HL,2
	ADD HL,SP
	PUSH HL
	LD HL,10
	ADD HL,SP
	CALL ccgint
	PUSH HL
	CALL qfflush
	POP BC
	CALL ccpint
	JP cc64
cc63:
	LD HL,2
	ADD HL,SP
	PUSH HL
	LD HL,0
	CALL ccpint
cc64:
	LD HL,0
	ADD HL,SP
	PUSH HL
	LD HL,q_fnext
	PUSH HL
	LD HL,8
	ADD HL,SP
	CALL ccgint
	ADD HL,HL
	POP DE
	ADD HL,DE
	CALL ccgint
	CALL ccpint
	LD HL,0
	ADD HL,SP
	PUSH HL
	CALL ccgint
	INC HL
	CALL ccpint
	DEC HL
	PUSH HL
	LD HL,12
	ADD HL,SP
	CALL ccgchar
	POP DE
	LD A,L
	LD (DE),A
	LD HL,q_fnext
	PUSH HL
	LD HL,6
	ADD HL,SP
	CALL ccgint
	ADD HL,HL
	POP DE
	ADD HL,DE
	PUSH HL
	LD HL,2
	ADD HL,SP
	CALL ccgint
	CALL ccpint
	LD HL,2
	ADD HL,SP
	CALL ccgint
	LD A,H
	OR L
	JP Z,cc65
	LD HL,2
	ADD HL,SP
	CALL ccgint
	POP BC
	POP BC
	POP BC
	RET
cc65:
	LD HL,10
	ADD HL,SP
	CALL ccgchar
	POP BC
	POP BC
	POP BC
	RET
cc60:	DEFB 67,65,78,39,84,32,87,82,73,84
	DEFB 69,32,84,79,32,73,78,70,73,76
	DEFB 69,0
qfflush:
	PUSH BC
	PUSH BC
	PUSH BC
	PUSH BC
	LD HL,6
	ADD HL,SP
	PUSH HL
	LD HL,12
	ADD HL,SP
	CALL ccgint
	PUSH HL
	LD HL,5
	CALL ccsub
	CALL ccpint
	LD HL,6
	ADD HL,SP
	CALL ccgint
	PUSH HL
	CALL qfchk
	POP BC
	PUSH HL
	LD HL,17325
	CALL ccne
	LD A,H
	OR L
	JP Z,cc67
	LD HL,cc66+0
	PUSH HL
	CALL qerr
	POP BC
	CALL qexit
cc67:
	LD HL,2
	ADD HL,SP
	PUSH HL
	LD HL,q_fnext
	PUSH HL
	LD HL,10
	ADD HL,SP
	CALL ccgint
	ADD HL,HL
	POP DE
	ADD HL,DE
	CALL ccgint
	CALL ccpint
	LD HL,0
	ADD HL,SP
	PUSH HL
	LD HL,q_fnext
	PUSH HL
	LD HL,10
	ADD HL,SP
	CALL ccgint
	ADD HL,HL
	POP DE
	ADD HL,DE
	PUSH HL
	LD HL,q_ffirst
	PUSH HL
	LD HL,12
	ADD HL,SP
	CALL ccgint
	ADD HL,HL
	POP DE
	ADD HL,DE
	CALL ccgint
	CALL ccpint
	CALL ccpint
cc68:
	LD HL,0
	ADD HL,SP
	CALL ccgint
	PUSH HL
	LD HL,4
	ADD HL,SP
	CALL ccgint
	CALL ccult
	LD A,H
	OR L
	JP Z,cc69
	LD HL,26
	PUSH HL
	LD HL,2
	ADD HL,SP
	CALL ccgint
	PUSH HL
	CALL qcpm
	POP BC
	POP BC
	LD HL,21
	PUSH HL
	LD HL,q_ffcb
	PUSH HL
	LD HL,10
	ADD HL,SP
	CALL ccgint
	ADD HL,HL
	POP DE
	ADD HL,DE
	CALL ccgint
	PUSH HL
	CALL qcpm
	POP BC
	POP BC
	LD A,H
	OR L
	JP Z,cc70
	LD HL,1
	CALL ccneg
	EX DE,HL
	LD HL,8
	ADD HL,SP
	LD SP,HL
	EX DE,HL
	RET
cc70:
	LD HL,0
	ADD HL,SP
	PUSH HL
	LD HL,2
	ADD HL,SP
	CALL ccgint
	PUSH HL
	LD HL,128
	POP DE
	ADD HL,DE
	CALL ccpint
	JP cc68
cc69:
	LD HL,26
	PUSH HL
	LD HL,128
	PUSH HL
	CALL qcpm
	POP BC
	POP BC
	LD HL,0
	EX DE,HL
	LD HL,8
	ADD HL,SP
	LD SP,HL
	EX DE,HL
	RET
cc66:	DEFB 67,65,78,39,84,32,70,76,85,83
	DEFB 72,32,73,78,70,73,76,69,0
qupper:
	LD HL,2
	ADD HL,SP
	CALL ccgint
	PUSH HL
	LD HL,97
	CALL ccge
	LD A,H
	OR L
	JP Z,cc72
	LD HL,2
	ADD HL,SP
	CALL ccgint
	PUSH HL
	LD HL,32
	CALL ccsub
	RET
cc72:
	LD HL,2
	ADD HL,SP
	CALL ccgint
	RET
qexit:
	LD HL,(qstdout)
	PUSH HL
	LD HL,5
	CALL ccge
	LD A,H
	OR L
	JP Z,cc74
	LD HL,(qstdout)
	PUSH HL
	CALL qfclose
	POP BC
cc74:
	JP	0
	RET
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
q_flast:	DEFS 6
q_dfltdsk:	DEFS 2
q_fmode:	DEFS 6
q_fnext:	DEFS 6
q_cr:	DEFS 2
q_ex:	DEFS 2
q_ffirst:	DEFS 6
qstdin:	DEFS 2
qstdout:	DEFS 2
q_ffcb:	DEFS 6
q_fbuf:	DEFS 2

; --- End of Compilation ---
