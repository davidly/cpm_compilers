;C/80 Compiler 3.0a (12/6/83) - (c) 1983 The Software Toolworks

	XTEXT A:CLIBRARY.ASM
LINKPT:	DW	-1

;#asm
; CPROF - C/80 Execution Profile (8/11/83)
;  Note - for use on other than Heath/Zenith systems,
;	CPROF.ASM must be regenerated.	See C/80 documentation.
CURRTN: DW 0		;CURRENT RTN
CALLTP: DW 0		;TEMP FOR TIME
CALLED: DW 0		;HOLDS RTN CALLED
FIRSTM: DB 0		;FIRST TIME FLAG
CALL::	DS 0
	LDA FIRSTM
	XRI 1
	JZ CALL1
	STA FIRSTM
	LXI H,0
	SHLD 11
CALL1:	LHLD 11
	SHLD CALLTP
	POP H
	MOV A,M
	STA CALLED
	INX H
	MOV A,M
	STA CALLED+1
	INX H
	MOV A,M
	STA CURRTN
	INX H
	MOV A,M
	STA CURRTN+1
	INX H
	PUSH H		;FIX RETURN ADDRESS
	PUSH B
	PUSH D
	CALL SCORET
	LHLD CALLED
	PUSH H
	LXI H,exit	;CHECK IF QUITTING
	CALL e.
	CNZ PrinPr
	POP D
	POP B
	LHLD CALLED
	PCHL		;CALL ROUTINE
RET::	XTHL		;SAVE RETURN VALUE
	PUSH B
	PUSH D
	PUSH H
	LHLD 11
	SHLD CALLTP
	POP H		;GET CURRENT SUBR
	CALL h.##
	SHLD CURRTN
	CALL SCORET
	PUSH H		;INCREMENT COUNT
	CALL h.
	INX H
	CALL q.##
	LHLD CURRTN
	PUSH H
	LXI H,main	;IF RETURN FROM MAIN
	CALL e.##
	CNZ PrinPr	 ;PRINT SUMMARY
	POP D
	POP B
	POP H		;RESTORE RETURN VAL
	RET
SCORET: LHLD CURRTN
	DCX H		;PREPARE TO STORE VALUES
	DCX H
	PUSH H		;PUSH ADDRESS OF COUNT
	DCX H
	DCX H
	PUSH H		;ADDRESS OF TIME
	PUSH H
	DCX H
	DCX H
	PUSH H		;GET PTR TO LINK
	CALL h.
	MOV A,H 	;CHECK LINK=0?
	ORA L
	JNZ CALL2	;YES - ADD TO CHAIN
	LHLD LINKPT
	XCHG
	LHLD CURRTN	;IF NO LINK,
	SHLD LINKPT	;LINK IT IN
	XCHG
CALL2:	CALL q.
	POP H		;ADD TO TIME
	CALL h.
	XCHG
	LHLD CALLTP
	DAD D
	CALL q.
	LXI H,0 	;ERASE 11
	SHLD 11
	POP H		;GET ADDR OF COUNT
	RET		;AND RETURN
;#endasm
.d:	DW	0
.e:	DW	0
.f:	DW	0
.g:	DW	0
.h:	DW	0
.i:	DW	0
.j:	DW	0
.k:	DW	0

PrinPr:	LXI	H,.c
	SHLD	.d
.n:	LHLD	.d
	MOV	A,M
	ORA	A
	JZ	.m
	JMP	.o
.l:	LHLD	.d
	INX	H
	SHLD	.d
	DCX	H
	CALL	g.
	PUSH	H
	CALL	putchar
	POP	B
	JMP	.n
.o:	JMP	.l
.m:	LXI	H,0
	SHLD	.k
	LHLD	LINKPT
	SHLD	.g
.r:	LHLD	.g
	INX	H
	MOV	A,H
	ORA	L
	JZ	.q
	JMP	.s
.p:	LHLD	.g
	LXI	D,-6
	DAD	D
	CALL	h.##
	SHLD	.g
	JMP	.r
.s:	LHLD	.g
	LXI	D,-4
	DAD	D
	CALL	h.##
	LXI	D,100
	DAD	D
	SHLD	.h
	MVI	L,0
	MOV	A,H
	ANI	128
	MOV	H,A
	MOV	A,H
	ORA	L
	JZ	.t
	LHLD	.k
	LXI	D,164
	DAD	D
	SHLD	.k
	LHLD	.h
	MOV	A,H
	ANI	127
	MOV	H,A
	SHLD	.h
.t:	LHLD	.h
	XCHG
	LXI	H,200
	CALL	c.div
	XCHG
	LHLD	.k
	DAD	D
	SHLD	.k
	JMP	.p
.q:	DS	0
.w:	LXI	H,0
	SHLD	.e
	SHLD	.j
	LHLD	LINKPT
	SHLD	.g
.z:	LHLD	.g
	INX	H
	MOV	A,H
	ORA	L
	JZ	.y
	JMP	.ab
.x:	LHLD	.g
	LXI	D,-6
	DAD	D
	CALL	h.##
	SHLD	.g
	JMP	.z
.ab:	LHLD	.g
	LXI	D,-4
	DAD	D
	CALL	h.##
	SHLD	.f
	LHLD	.g
	DCX	H
	DCX	H
	CALL	h.##
	MOV	A,H
	ORA	L
	JZ	.bb
	LHLD	.e
	XCHG
	LHLD	.f
	CALL	c.ule
	JZ	.cb
	LHLD	.f
	SHLD	.e
	LHLD	.g
	SHLD	.j
.cb:	DS	0
.bb:	JMP	.x
.y:	LHLD	.j
	MOV	A,H
	ORA	L
	JNZ	.db
	JMP	.v
.db:	LHLD	.j
	DCX	H
	DCX	H
	SHLD	.j
	CALL	h.##
	SHLD	.i
	LHLD	.j
	MVI	M,0
	INX	H
	MVI	M,0
	LHLD	.j
	LXI	D,-4
	DAD	D
	SHLD	.j
	SHLD	.d
.eb:	LHLD	.d
	DCX	H
	MOV	A,M
	ORA	A
	JZ	.fb
	LHLD	.d
	DCX	H
	SHLD	.d
	JMP	.eb
.fb:	DS	0
.gb:	LHLD	.j
	PUSH	H
	LHLD	.d
	CALL	n.
	JZ	.hb
	LHLD	.d
	INX	H
	SHLD	.d
	DCX	H
	CALL	g.
	PUSH	H
	CALL	putchar
	POP	B
	JMP	.gb
.hb:	LXI	H,9
	PUSH	H
	CALL	putchar
	POP	B
	LHLD	.i
	PUSH	H
	CALL	PrinNr
	POP	B
	LXI	H,9
	PUSH	H
	CALL	putchar
	POP	B
	LHLD	.e
	XCHG
	LXI	H,1
	CALL	c.usr
	SHLD	.e
	PUSH	H
	CALL	PrinNr
	POP	B
	LXI	H,9
	PUSH	H
	CALL	putchar
	POP	B
	LHLD	.k
	XCHG
	LXI	H,1
	CALL	c.usr
	XCHG
	LHLD	.e
	DAD	D
	XCHG
	LHLD	.k
	CALL	c.udv
	PUSH	H
	CALL	PrinNr
	POP	B
	LXI	H,10
	PUSH	H
	CALL	putchar
	POP	B
	JMP	.w
.v:	RET
.ib:	DB	0,0,0,0,0,0
.jb:	DW	0
.kb:	DW	0

PrinNr:	LXI	H,.ib
	SHLD	.jb
	LXI	H,2
	DAD	SP
	CALL	h.##
	SHLD	.kb
	LXI	D,0
	CALL	c.gt
	JZ	.lb
	LHLD	.kb
	LXI	D,-20000
	DAD	D
	SHLD	.kb
.lb:	DS	0
.ob:	LHLD	.jb
	INX	H
	SHLD	.jb
	DCX	H
	PUSH	H
	LHLD	.kb
	XCHG
	LXI	H,10
	CALL	c.div
	XCHG
	LXI	D,48
	DAD	D
	POP	D
	MOV	A,L
	STAX	D
.mb:	LHLD	.kb
	XCHG
	LXI	H,10
	CALL	c.div
	SHLD	.kb
	MOV	A,H
	ORA	L
	JNZ	.ob
.nb:	LXI	H,2
	DAD	SP
	CALL	h.##
	LXI	D,32768
	CALL	c.tst
	JC	.pb
	LHLD	.jb
	DCX	H
	PUSH	H
	CALL	g.
	INX	H
	INX	H
	POP	D
	MOV	A,L
	STAX	D
.pb:	DS	0
.sb:	LHLD	.jb
	DCX	H
	SHLD	.jb
	CALL	g.
	PUSH	H
	CALL	putchar
	POP	B
.qb:	LHLD	.jb
	LXI	D,.ib
	CALL	c.ult
	JNZ	.sb
.rb:	RET
	CALL	exit
	PUSH	H
	CALL	main
	CALL	e.
	RET
.c:
	DB	'ROUTINE'
	DB	9
	DB	'CALLS'
	DB	9
	DB	'TICKS'
	DB	9
	DB	'% TIME (Approx.)'
	DB	10
	DB	0
$END	DS	0
	END	$INIT
