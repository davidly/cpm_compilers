; CLIBRARY.ASM 3.0 (9/6/83) - (c) 1982, 1983 Walter Bilofsky
; Multiply and divide routines (c)1981 UltiMeth Corp. Permission is gran-
; ted to reproduce them without charge, provided this notice is included.
        ORG     256
C_lib:  DS      0
CP_M    EQU     1
$AS     EQU     $+2
$AG     EQU     $
$INIT:  DW      0
        LHLD    6
        DCX     H
        DCR     H
        SHLD    IObuf+6
        DCR     H
        SHLD    IObuf+4
        DCR     H
        SHLD    IObuf+2
        LXI     B,-36
        DAD     B
        SHLD    IOfcb+4
        DAD     B
        SHLD    IOfcb+2
        DAD     B
        SHLD    IOfcb
	LXI	B,-135
	DAD	B
	MVI	M,0
	SHLD	Cbuf
	DCX	H
	MVI	M,132
	DCX	H
	SPHL
	LXI	H,128
	MOV	E,M
	MVI	M,' '
	MVI	D,0
	DAD	D
	INR	E
	LXI	B,0
$A8:	PUSH	B
	MOV	B,M
	DCX	H
	MOV	C,M
	DCX	H
	DCR	E
	DCR	E
	JP	$A8
	LXI	H,202AH
	PUSH	H
	LXI	H,$AS
	PUSH	H
	LXI	H,2
	DAD	SP
$A2:	DS	0
$A7:	MOV	A,M
	INX	H
	ORA	A
	JZ	$A6
	CPI	' '
	JZ	$A7
	MOV	C,A
	CPI	'"'
	JZ	$A3
	CPI	047Q
	JZ	$A3
	MVI	C,' '
	DCX	H
$A3:	POP	D
	MOV	A,L
	STAX	D
	INX	D
	MOV	A,H
	STAX	D
	INX	D
	PUSH	D
	PUSH	H
	DCX	H
$A9:	INX	H
	MOV	A,M
	ORA	A
	JZ	$A5
	CMP	C
	JNZ	$A9
	MVI	M,0
	INX	H
$A5:	XTHL
	MOV	A,M
	INX	H
	CPI	'<'
	JZ	$B1
	CPI	'>'
	JZ	$B2
	LXI	H,$AG
	INR	M
	POP	H
	JMP	$A2
$A6:	POP	H
	MVI	M,-1
	INX	H
	MVI	M,-1
	LHLD	$AG
	PUSH	H
	LXI	H,$AS
	PUSH	H
	CALL	main
exit:	LHLD	fout
	MOV	A,H
	ORA	L
	JZ	$B4
	PUSH	H
	CALL	fclose
$B4:	JMP	-5+5
exic	EQU	exit
$B1:	PUSH	H
	LXI	H,$BR
	PUSH	H
	CALL	fopen
	SHLD	fin
	JMP	$B3
$BR:	DB	'r',0
fin:	DW	0
$B2:	PUSH	H
	LXI	H,$BW
	PUSH	H
	CALL	fopen
	SHLD	fout
$B3:	POP	B
	POP	B
	JC	$B0
	POP	H
	POP	D
	DCX	D
	DCX	D
	PUSH	D
	JMP	$A2
$B0:	LXI	D,$BMS
	MVI	C,9
	CALL	5
	MVI	C,0
	CALL	5
$BMS:	DB	'Can''t open > or < file.$'
CtlB	EQU	$+1
	JMP	exic
$BW:	DB	'w',0
fout:	DW	0
	RET
sbrk:	DS	0
	POP	D
	POP	B
	PUSH	B
	PUSH	D
	LHLD	$LM
	PUSH	H
	PUSH	H
	POP	D
	DAD	B
	PUSH	H
	PUSH	H
	CALL	c.ugt
	POP	D
	JNZ	al.1
	LXI	H,-500
	DAD	SP
	CALL	c.uge
al.1:	POP	D
	POP	B
	LXI	H,-1
	RNZ
	XCHG
	SHLD	$LM
	PUSH	B
	POP	H
	RET
$LM:	DW	$END
	RET
getchar:	DS	0
	LHLD	fin
	PUSH	H
	CALL	getc
	POP	B
	RET
Ccnt:	DB	0
Cbuf:	DS	2
Cmode:	DB	1
$RLIN:	LDA	Ccnt
	INR	A
	LHLD	Cbuf
	CMP	M
	RC
	RZ
	XCHG
	MVI	C,10
	DCX	D
	CALL	5
	XRA	A
	STA	Ccnt
	MVI	E,10
	CALL	$RADD
	JMP	$RLIN
CtlCk:	MVI	C,11
	CALL	5
	ORA	A
	RZ
	MVI	C,1
	CALL	5
	CPI	3
	JZ	0
	CPI	2
	JZ	CtlB-1
	CPI	13
	JNZ	$CC
	MVI	A,10
$CC:	MOV	E,A
$RADD:	LHLD	Cbuf
	MOV	A,M
	DCX	H
	CMP	M
	RNC
	INX	H
	INR	M
	MOV	C,M
	MVI	B,0
	DAD	B
	MOV	M,E
	MVI	A,10
	CMP	E
	MVI	C,2
	CZ	5
	RET
$B8Z:	CALL	CtlB-1
$B8:	MVI	A,32
$GCH:	LXI	H,IOpread
	CALL	$PU
	RC
	PUSH	B
	LDA	Cmode
	CMP	C
	JNZ	$GC1
	CALL	$RLIN
	STA	Ccnt
	MOV	E,A
	MVI	D,0
	DAD	D
	MOV	A,M
	JMP	$GC2
$GC1:	CALL	5
$GC2:	POP	B
	CPI	13
	JNZ	$B8P
	DCR	C
	JNZ	$B8M
	MVI	E,10
	MVI	C,2
	CALL	5
$B8M:	MVI	A,10
	JMP	c.sxt
$B8P:	DCR	C
	JNZ	$B8G
	CPI	2
	JZ	$B8Z
$B8G:	CPI	26
	JZ	$B9
	JMP	c.sxt
$B9:	DS 0
$RM:	LXI	H,-1
	RET
putchar:	DS	0
	POP	B
	POP	D
	PUSH	D
	PUSH	B
	LHLD	fout
	PUSH	D
	PUSH	H
	CALL	putc
	POP	B
	POP	B
	RET
$B7:	XCHG
	MVI	A,32
$PCH:	PUSH	H
	LXI	H,IOpwrit
	CALL	$PU
	POP	D
	RC
	PUSH	D
	XCHG
	MOV	A,L
	CPI	10
	JNZ	$B7A
	MVI	E,13
	PUSH	B
	CALL	5
	POP	B
	MVI	A,10
$B7A:	MOV	E,A
	CALL	5
	POP	H
	RET
IOdev:	DB	'con:rdr:pun:lst:'
	DB	0
$PU:	SUI	32
	JC	$PU1
	CPI	4
	JP	$PU1
	MOV	E,A
	MVI	D,0
	DAD	D
	MOV	A,M
	MOV	C,A
	ORA	A
	RNZ
$PU1:	STC
	JMP	$RM
	RET
IObuf:	DW	0,0,0,0,0,0,0
IOsect:	DW	0,0,0,0,0,0,0
IOrw:	DB	0,0,0,0,0,0,0
IOtmp:	DW	0
IOch:	DB	-1,-1,-1,-1,-1,-1,-1
IOind:	DW	0,0,0,0,0,0,0
IOmode:	DB	0,0,0,0,0,0,0
IObin:	DB	0,0,0,0,0,0,0
IOfcb:	DW	0,0,0,0,0,0,0
IOnch:	DB	0,0,0,0,0,0,0
IOpchan:	DB	32,33,34,35
IOpread:	DB	1,3,0,0
IOpwrit:	DB	2,0,4,5
IOpeof:	DB	0,26,26,12
fopen:	DS	0
	POP	B
	POP	H
	POP	D
	PUSH	D
	PUSH	H
	PUSH	B
	LXI	H,IOdev
	MVI	C,32
Z1$:	PUSH	D
	PUSH	H
	MVI	B,4
Z2$:	LDAX	D
	ORI	' '
	CMP	M
	JNZ	Z3$
	INX	D
	INX	H
	DCR	B
	JNZ	Z2$
	POP	D
	POP	H
	MOV	L,C
	MVI	H,0
	RET
Z3$:	LXI	D,4
	POP	H
	DAD	D
	POP	D
	INR	C
	MOV	A,M
	ORA	A
	JNZ	Z1$
	MVI	B,6
	LXI	H,IOch+1
O1$:	MOV	A,M
	CPI	-1
	JZ	O2$
	INX	H
	DCR	B
	JNZ	O1$
	JMP	RN$
O2$:	POP	B
	POP	D
	PUSH	D
	PUSH	B
	XCHG
	MOV	A,M
	INX	H
	MOV	B,M
	XCHG
	LXI	D,IOrw-IOch
	DAD	D
	MVI	M,0
	LXI	D,IObin-IOrw
	DAD	D
	MOV	M,B
	LXI	D,IOmode-IObin
	DAD	D
	MOV	M,A
	LXI	D,IOnch-IOmode
	DAD	D
	MVI	M,0
	STA	O6$+1
	LXI	D,IOnch
	XCHG
	CALL	s.1
	PUSH	H
	LXI	H,6
	DAD	SP
	CALL	h.
	POP	B
	PUSH	B
	MOV	A,C
	DCR	A
	PUSH	H
	CALL	.CPC
	POP	H
	JZ	RN$
	PUSH	D
	XCHG
	CALL	x_fcb
O6$:	MVI	A,0
	MVI	C,15
	CPI	'w'
	JNZ	O6$B
	POP	D
	PUSH	D
	MVI	C,19
	CALL	5
	MVI	C,22
O6$B:	POP	D
	CALL	5
	POP	D
	INR	A
	JZ	RN$
	LXI	H,IOch
	DAD	D
	MOV	M,E
	LXI	B,IOind-IOch
	DAD	B
	DAD	D
	MVI	M,0
	INX	H
	MVI	M,1
	LXI	B,IObuf-IOind
	DAD	B
	MOV	A,M
	DCX	H
	ORA	M
	JNZ	O8$
	PUSH	D
	PUSH	H
	LXI	B,256
	PUSH	B
	CALL	sbrk
	POP	B
	XCHG
	POP	H
	MOV	M,E
	INX	H
	MOV	M,D
	INX	D
	MOV	A,E
	ORA	D
	POP	D
	JZ	RN$
O8$:	XCHG
	XRA	A
	RET
fclose:	DS	0
	POP	B
	POP	D
	PUSH	D
	PUSH	B
	MOV	A,E
	CPI	32
	JC	F$1
	LXI	H,IOpwrit
	CALL	$PU
	INX	H
	RC
	LXI	D,IOpeof-IOpwrit-1
	DAD	D
	MOV	E,M
	MOV	A,E
	ORA	A
	CNZ	5
	LXI	H,0
	RET
F$1:	LXI	H,IOsect
	DAD	D
	DAD	D
	XRA	A
	MOV	M,A
	INX	H
	MOV	M,A
	LXI	H,IOch
	DAD	D
	MOV	A,M
	INR	A
	JZ	RN$
	MVI	M,-1
	CALL	TM$
	LXI	H,IOmode
	DAD	D
	MOV	A,M
	CPI	'r'
	JZ	F2$
	LXI	H,IObin
	DAD	D
	MOV	C,M
	LXI	H,IOind
	DAD	D
	DAD	D
	PUSH	D
	CALL	h.
	MOV	A,L
	ORA	A
	JZ	F3$
	XCHG
	PUSH	PSW
	LHLD	IOtmp
	MOV	A,C
	CPI	'b'
	JZ	F5$
	DAD	D
	MVI	A,26
F4$:	MOV	M,A
	INX	H
	INR	E
	JNZ	F4$
	DCR	H
F5$:	POP	PSW
	PUSH	H
	LXI	H,128
	DCR	A
	JP	F5A$
	DAD	H
F5A$:	PUSH	H
	CALL	write
	POP	B
	POP	B
F3$:	POP	D
F2$:	MOV	A,E
	DCR	A
	PUSH	D
	CALL	.CPC
	MVI	C,16
	CALL	5
	INR	A
	POP	H
	RNZ
RN$:	LXI	H,0
	STC
	RET
TM$:	LXI	H,IObuf
	DAD	D
	DAD	D
	MOV	C,M
	INX	H
	MOV	B,M
	PUSH	B
	POP	H
	SHLD	IOtmp
	RET
getc:	DS	0
.G3:	CALL	.GPC
	ORA	A
	JZ	$B8
	CPI	32
	JNC	$GCH
	XRA	A
	CMP	C
	DCX	H
	JNZ	.G1
	PUSH	H
	PUSH	D
	LHLD	IOtmp
	PUSH	H
	LXI	H,256
	PUSH	H
	CALL	read
	POP	B
	POP	B
	POP	D
	PUSH	D
	XCHG
	LXI	B,IOnch
	DAD	B
	MOV	M,E
	MOV	A,E
	ORA	D
	POP	D
	POP	H
	JZ	$RM
.G1:	PUSH	D
	PUSH	H
	CALL	h.
	INX	H
	CALL	q.
	DCX	H
	XCHG
	LHLD	IOtmp
	DAD	D
	MOV	B,M
	LXI	H,IObin
	POP	D
	DAD	D
	MVI	A,'b'
	CMP	M
	JZ	.G2
	MOV	A,B
	CPI	13
	JZ	.G3
	CPI	26
	JZ	$RM
	ORA	A
	JZ	.G3
.G2:	MOV	L,B
	MVI	H,0
	RET
.GPC:	POP	H
	POP	B
	POP	D
	PUSH	D
	PUSH	B
	PUSH	H
	MOV	A,E
	ORA	A
	RZ
	CPI	32
	RNC
	CALL	TM$
	LXI	H,IOnch
	DAD	D
	MOV	A,M
	LXI	H,IOind
	DAD	D
	DAD	D
	MOV	C,M
	INX	H
	MOV	B,M
	CMP	C
	MOV	A,E
	RNZ
	MVI	B,0
	MOV	M,B
	DCX	H
	MOV	M,B
	MOV	C,B
	INX	H
	RET
putc:	DS	0
	CALL	.GPC
	ORA	A
	JNZ	PC.8
	POP	B
	POP	H
	POP	D
	PUSH	D
	PUSH	H
	PUSH	B
	JMP	$B7
PC.8:	DS	0
	CPI	32
	JC	PC.9
	POP	B
	POP	D
	POP	H
	PUSH	H
	PUSH	D
	PUSH	B
	JMP	$PCH
PC.9:	DCX	H
	PUSH	H
	LXI	H,6
	DAD	SP
	MOV	A,M
	CPI	10
	JNZ	PC.1
	PUSH	H
	LXI	H,IObin
	DAD	D
	MOV	A,M
	CPI	'b'
	JZ	PC.3
	LXI	H,C.LFD
	DCR	M
	JNZ	PC.2
	MVI	A,13
	POP	H
	JMP	PC.1
C.LFD:	DB 1
PC.2:	MVI	M,1
PC.3:	POP	H
	MVI	A,10
PC.1:	LHLD	IOtmp
	DAD	B
	MOV	M,A
	XTHL
	PUSH	H
	PUSH	H
	MOV	H,B
	MOV	L,C
	INX	H
	CALL	q.
	POP	H
	XRA	A
	CMP	M
	POP	H
	JNZ	.PC1
	POP	B
	POP	D
	PUSH	D
	PUSH	B
	PUSH	D
	DCR	H
	INR	L
	PUSH	H
	LXI	H,256
	PUSH	H
.PC2:	CALL	write
	POP	B
	POP	B
	POP	B
	MOV	A,H
	ORA	L
	LXI	H,-1
	RZ
	RM
.PC1:	LXI	H,4
	DAD	SP
	MOV	L,M
	MVI	H,0
	LDA	C.LFD
	ORA	A
	JZ	putc
	RET
write:	DS	0
	XRA	A
	STA	RD.RW
	MVI	A,21
	JMP	RD.0
RD.T:	DS	1
$RW.2:	PUSH	H
	LXI	H,8
	DAD	SP
	CALL	h.
	XCHG
	POP	H
	PUSH	H
	DAD	H
	LDA	RD.RW
	ANA	H
	PUSH	PSW
	MOV	A,H
	LXI	H,IOsect
	DAD	D
	DAD	D
	ADD	M
	MOV	M,A
	JNC	.PC5
	INX	H
	INR	M
.PC5:	LXI	H,IOrw
	DAD	D
	POP	PSW
	MOV	M,A
	POP	H
	RET
read:	DS	0
	MVI	A,-1
	STA	RD.RW
	MVI	A,20
RD.0:	STA	RD.T
	LDA	Cmode
	ORA	A
	CNZ	CtlCk
	CALL	$RW.
	PUSH	B
RD.1:	MOV	A,B
	ORA	C
	JZ	RD.4
	PUSH	D
	PUSH	H
	PUSH	B
	PUSH	D
	XCHG
	MVI	C,26
	CALL	5
	POP	D
	LDA	RD.T
	MOV	C,A
	CALL	5
	POP	B
	ORA	A
	JNZ	RD.2
	LXI	H,-128
	DAD	B
	MOV	B,H
	MOV	C,L
	POP	H
	LXI	D,128
	DAD	D
	POP	D
	JMP	RD.1
RD.2:	POP	H
	POP	D
	LDA	RD.T
	CPI	21
	JNZ	RD.4
	POP	H
	LXI	D,RD.M
	MVI	C,9
	CALL	5
	LXI	H,-1
	JMP	RD.3
RD.M:	DB	'Write error - Disk full'
	DB	0AH,0DH,'$'
RD.4:	POP	D
	MOV	H,B
	MOV	L,C
	CALL	s.1
RD.3:	PUSH	H
	MVI	C,26
	LXI	D,128
	CALL	5
	POP	H
	JMP	$RW.2
RD.RW:	DS	1
$RW.:	LXI	H,8
	DAD	SP
	MOV	A,M
	DCR	A
	DCX	H
	PUSH	H
	CALL	.CPC
	POP	H
	PUSH	D
	MOV	D,M
	DCX	H
	MOV	E,M
	DCX	H
	MOV	B,M
	DCX	H
	MOV	C,M
	POP	H
	XCHG
	RET
x_fcb:	LXI	B,11
	DAD	B
	SHLD	.XTMP
	MVI	A,' '
nam.1:	MOV	M,A
	DCX	H
	DCR	C
	JNZ	nam.1
	XRA	A
	MOV	M,A
	LXI	B,12
	DAD	B
	MOV	M,A
	INX	H
	INX	H
	MOV	M,A
	LXI	B,18
	DAD	B
	MOV	M,A
	LXI	B,-32
	DAD	B
	XCHG
	INX	H
	MOV	A,M
	DCX	H
	CPI	':'
	JNZ	nam.2
	MOV	A,M
	INX	H
	INX	H
        CALL    NAM@U
        SUI     'A'-1
        STAX    D
nam.2:  INX     D
        MOV     A,M
        INX     H
        ORA     A
        RZ
        CPI     '.'
        JZ      nam.3
        CALL    NAM@U
        STAX    D
        JMP     nam.2
nam.3:  XCHG
        LHLD    .XTMP
        DCX     H
        DCX     H
nam.4:  LDAX    D
        ORA     A
        RZ
        CALL    NAM@U
        MOV     M,A
        INX     D
        INX     H
        JMP     nam.4
.XTMP:  DS 2
NAM@U:  ANI     177Q
        CPI     'a'
        RM
        SUI     'a'-'A'
        RET
.CPC:   MOV     C,A
        MVI     B,0
        LXI     H,IOfcb
        DAD     B
        DAD     B
        MOV     A,M
        MOV     E,A
        INX     H
        MOV     D,M
        ORA     D
        RNZ
        PUSH    H
        LXI     H,36
        PUSH    H
        CALL    sbrk
        XCHG
        POP     H
        POP     H
        MOV     M,D
	DCX	H
	MOV	M,E
	MOV	H,D
	MOV	L,E
	INX	H
	MOV	A,H
	ORA	L
	RET
o.:	POP	B
	POP	D
	PUSH	B
	MOV	A,L
	ORA	E
	MOV	L,A
	MOV	A,H
	ORA	D
	MOV	H,A
	RET
x.:	POP	B
	POP	D
	PUSH	B
	MOV	A,L
	XRA	E
	MOV	L,A
	MOV	A,H
	XRA	D
	MOV	H,A
	RET
a.:	POP	B
	POP	D
	PUSH	B
	MOV	A,L
	ANA	E
	MOV	L,A
	MOV	A,H
	ANA	D
	MOV	H,A
	RET
e.0:	MOV	A,H
	ORA	L
	RZ
e.t:	LXI	H,0
e.2:	INR	L
	RET
e.:	POP	B
	POP	D
	PUSH	B
e.1:	MOV	A,H
	CMP	D
	MOV	A,L
	LXI	H,0
	JNZ	e.f
	CMP	E
	JNZ	e.f
	INR	L
	RET
e.f:	XRA	A
	RET
c.not:	MOV	A,H
	ORA	L
	JZ	e.2
	LXI	H,0
	XRA	A
	RET
n.:	POP	B
	POP	D
	PUSH	B
n.1:	MOV	A,H
	CMP	D
	MOV	A,L
	LXI	H,1
	RNZ
	CMP	E
	RNZ
	DCR	L
	RET
c.ge:	XCHG
c.le:	MOV	A,D
	CMP	H
	JNZ	c.lt1
	MOV	A,E
	CMP	L
	JNZ	c.lt3
true:	LXI	H,0
	INR	L
	RET
c.gt:	XCHG
c.lt:	MOV	A,D
c.lt1:	XRA	H
	JM	negHL
	MOV	A,D
	CMP	H
	JNZ	c.lt3
	MOV	A,E
	CMP	L
c.lt3:	LXI	H,1
	RC
c.lt4:	DCR	L
	RET
negHL:	MOV	A,H
	ANA	A
	LXI	H,1
	JM	c.lt4
	ORA	L
	RET
c.tst:	MOV	A,H
	XRI	128
	MOV	H,A
	DAD	D
	RET
c.uge:	XCHG
c.ule:	MOV A,H
	CMP D
	JNZ c.ule1
	MOV A,L
	CMP E
c.ule1: LXI H,1
	JNC c.true
c.fals: DCR L
	RET
c.true: ORA L
	RET
c.ugt:	XCHG
c.ult:	MOV A,D
	CMP H
	JNZ c.rt
	MOV A,E
	CMP L
c.rt:	LXI H,1
	RC
	DCR L
	RET
c.asr:	XCHG
	MOV	A,H
	RAL
c.shf:	DCR	E
	RM
	MOV	A,H
	RAR
	MOV	H,A
	MOV	A,L
	RAR
	MOV	L,A
	JMP	c.asr+1
c.usr:	XCHG
	XRA	A
	JMP	c.shf
c.asl:	XCHG
	DCR	E
	RM
	DAD	H
	JMP	c.asl+1
s.:	POP	B
	POP	D
	PUSH	B
s.1:	MOV	A,E
	SUB	L
	MOV	L,A
	MOV	A,D
	SBB	H
	MOV	H,A
	RET
c.neg:	DCX	H
c.com:	MOV	A,H
	CMA
	MOV	H,A
	MOV	A,L
	CMA
	MOV	L,A
	RET
g.:	MOV	A,M
c.sxt:	MOV	L,A
	RLC
	SBB	A
	MOV	H,A
	RET
h.:	MOV	A,M
	INX	H
	MOV	H,M
	MOV	L,A
	RET
q.:	XCHG
	POP	H
	XTHL
	MOV	M,E
	INX	H
	MOV	M,D
	XCHG
	RET
.switch:
	XCHG
	POP	H
S.9:	MOV	C,M
	INX	H
	MOV	B,M
	INX	H
	MOV	A,B
	ORA	C
	JZ	S.8
	MOV	A,M
	INX	H
	CMP	E
	MOV	A,M
	INX	H
	JNZ	S.9
	CMP	D
	JNZ	S.9
	MOV	H,B
	MOV	L,C
S.8:	PCHL
c.mult: MOV	B,H
	MOV	C,L
	LXI	H,0
	MOV	A,D
	ORA	A
	MVI	A,16
	JNZ	.MLP
	MOV	D,E
	MOV	E,H
	RRC
.MLP:	DAD	H
	XCHG
	DAD	H
	XCHG
	JNC	.MSK
	DAD	B
.MSK:	DCR	A
	JNZ	.MLP
	RET
c.udv:	XRA	A
	PUSH	PSW
	JMP	c.d1
c.div:	MOV	A,D
	XRA	H
	PUSH	PSW
	XRA	H
	XCHG
	CM	c.neg
	XCHG
	MOV	A,H
	ORA	A
c.d1:	CP	c.neg
	MOV	C,L
	MOV	B,H
	LXI	H,0
	MOV	A,B
	INR	A
	JNZ	.DV3
	MOV	A,D
	ADD	C
	MVI	A,16
	JC	.DV1
.DV3:	MOV	L,D
	MOV	D,E
	MOV	E,H
	MVI	A,8
.DV1:	DAD	H
	XCHG
	DAD	H
	XCHG
	JNC	.DV4
	INX	H
.DV4:	PUSH	H
	DAD	B
	POP	H
	JNC	.DV5
	DAD	B
	INX	D
.DV5:	DCR	A
	JNZ	.DV1
	XCHG
	POP	PSW
	RP
	XCHG
	CALL	c.neg
	XCHG
	JMP	c.neg
	RET
                                                                                      