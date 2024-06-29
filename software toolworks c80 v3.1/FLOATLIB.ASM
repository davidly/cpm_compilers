* Floating point library; C/80 3.0 (7/7/83) - (c) 1983 Walter Bilofsky
facl_:	DB	0
facl_1:	DB	0
facl_2:	DB	0
fac_:	DB	0
fac_1:	DB	0
save_:	DB	0
fmlt_1:	DB	0
fmlt_2:	DB	0
dum_:	DB	0
save_1:	DB	0
errcod:	DB	0
fdiv_a:	DB	0
fdiv_b:	DB	0
fdiv_c:	DB	0
fdiv_g:	DB	0
flt_pk:	DS	0
F.add:	XRA	A
	JMP	Dual
F.sub:	MVI	A,1
	JMP	Dual
F.mul:	MVI	A,2
	JMP	Dual
F.div:	MVI	A,3
Dual:	CALL	movfr.
	POP	H
	POP	D
	POP	B
	PUSH	H
	LXI	H,movrf.
	PUSH	H
	LXI	H,Ftab
Fexecl: ORA	A
	JZ	Fexec
	DCR	A
	INX	H
	INX	H
	JMP	Fexecl
Fexec:	MOV	A,M
	INX	H
	MOV	H,M
	MOV	L,A
	PCHL
Ftab:	DW	fadd.
	DW	fsub
	DW	fmult
	DW	fdiv
F.neg:	MOV	A,C
	XRI	80H
	MOV	C,A
	RET
cf.le:	CALL	relopf
	JP	ftrue
ffalse: DCR	L
	RET
cf.lt:	CALL	relopf
	DCR	A
	JNZ	ffalse
ftrue:	INR	A
	RET
cf.ge:	CALL	relopf
	DCR	A
	RM
	DCR	L
	RET
cf.gt:	CALL	relopf
	RM
	DCR	L
	RET
relopf:
	CALL	movfr.
	POP	B
	POP	H
	POP	D
	XTHL
	PUSH	B
	MOV	B,H
	MOV	C,L
	CALL	fcomp.
	LXI	H,1
	ORA	A
	RET
cf.eq:	CALL	cf.zro
	JNC	eq.4
	JZ	cf.tru
cf.fls: DCR	E
cf.tru: POP	H
	POP	B
	XTHL
	XCHG
	DCR	L
	RET
cf.ne:	CALL	cf.zro
	JNC	neq.4
	JZ	cf.fls
	JMP	cf.tru
cf.zro: XRA	A
	LXI	H,7
	DAD	SP
	ORA	B
	JZ	zer1
	XRA	A
	ORA	M
	RNZ
	INR	A
zer1:	ORA	M
	STC
	LXI	D,2
	RET
fsub:	CALL	flneg.
fadd.:	MOV	A,B
	ORA	A
	RZ
	LDA	fac_
	ORA	A
	JZ	movfr.
	SUB	B
	JNC	fadd1
	CMA
	INR	A
	XCHG
	CALL	pushf.
	XCHG
	CALL	movfr.
	POP	B
	POP	D
fadd1:	CPI	25
	RNC
	PUSH	PSW
	CALL	unpack
	MOV	H,A
	POP	PSW
	CALL	shiftr
	ORA	H
	LXI	H,facl_
	JP	fadd3
	CALL	fadda.
	JNC	round
	INX	H
	INR	M
	CZ	overr
	MVI	L,1
	CALL	shradd
	JMP	round
fadd3:	XRA	A
	SUB	B
	MOV	B,A
	MOV	A,M
	SBB	E
	MOV	E,A
	INX	H
	MOV	A,M
	SBB	D
	MOV	D,A
	INX	H
	MOV	A,M
	SBB	C
	MOV	C,A
fadflt: CC	negr
normal: MOV	L,B
	MOV	H,E
	XRA	A
norm1:	MOV	B,A
	MOV	A,C
	ORA	A
	JNZ	norm3
	MOV	C,D
	MOV	D,H
	MOV	H,L
	MOV	L,A
	MOV	A,B
	SUI	8
	CPI	0E0H
	JNZ	norm1
zero.:	XRA	A
zero0:	STA	fac_
	RET
norm2:	DCR	B
	DAD	H
	MOV	A,D
	RAL
	MOV	D,A
	MOV	A,C
	ADC	A
	MOV	C,A
norm3:	JP	norm2
	MOV	A,B
	MOV	E,H
	MOV	B,L
	ORA	A
	JZ	round
	LXI	H,fac_
	ADD	M
	MOV	M,A
	JNC	zero.
	RZ
round:	MOV	A,B
roundb: LXI	H,fac_
	ORA	A
	CM	rounda
	MOV	B,M
	INX	H
	MOV	A,M
	ANI	80H
	XRA	C
	MOV	C,A
	JMP	movfr.
rounda: INR	E
	RNZ
	INR	D
	RNZ
	INR	C
	RNZ
	MVI	C,80H
	INR	M
	RNZ
overr1: JMP	overr
fadda.: MOV	A,M
	ADD	E
	MOV	E,A
	INX	H
	MOV	A,M
	ADC	D
	MOV	D,A
	INX	H
	MOV	A,M
	ADC	C
	MOV	C,A
	RET
negr:	LXI	H,fac_1
	MOV	A,M
	CMA
	MOV	M,A
	XRA	A
	MOV	L,A
	SUB	B
	MOV	B,A
	MOV	A,L
	SBB	E
	MOV	E,A
	MOV	A,L
	SBB	D
	MOV	D,A
	MOV	A,L
	SBB	C
	MOV	C,A
	RET
shiftr: MVI	B,0
shftr1: SUI	8
	JC	shftr2
	MOV	B,E
	MOV	E,D
	MOV	D,C
	MVI	C,0
	JMP	shftr1
shftr2: ADI	9
	MOV	L,A
shftr3: XRA	A
	DCR	L
	RZ
	MOV	A,C
shradd: RAR
	MOV	C,A
	MOV	A,D
	RAR
	MOV	D,A
	MOV	A,E
	RAR
	MOV	E,A
	MOV	A,B
	RAR
	MOV	B,A
	JMP	shftr3
fmult3: MOV	B,E
	MOV	E,D
	MOV	D,C
	MOV	C,A
	RET
fmult:	CALL	sign.
	RZ
	MVI	L,0
	CALL	muldiv
	MOV	A,C
	STA	fmlt_1
	XCHG
	SHLD	fmlt_2
	LXI	B,0
	MOV	D,B
	MOV	E,B
	LXI	H,normal
	PUSH	H
	LXI	H,fmult2
	PUSH	H
	PUSH	H
	LXI	H,facl_
fmult2: MOV	A,M
	INX	H
	ORA	A
	JZ	fmult3
	PUSH	H
	MVI	L,8
fmult4: RAR
	MOV	H,A
	MOV	A,C
	JNC	fmult5
	PUSH	H
	LHLD	fmlt_2
	DAD	D
	XCHG
	POP	H
	LDA	fmlt_1
	ADC	C
fmult5: RAR
	MOV	C,A
	MOV	A,D
	RAR
	MOV	D,A
	MOV	A,E
	RAR
	MOV	E,A
	MOV	A,B
	RAR
	MOV	B,A
	DCR	L
	MOV	A,H
	JNZ	fmult4
pophrt: POP	H
	RET
div10.: CALL	pushf.
	LXI	B,8420H
	LXI	D,0000H
	CALL	movfr.
fdivt:	POP	B
	POP	D
fdiv:	CALL	sign.
	CZ	dv0err
	MVI	L,0FFH
	CALL	muldiv
	INR	M
	INR	M
	DCX	H
	MOV	A,M
	STA	fdiv_a
	DCX	H
	MOV	A,M
	STA	fdiv_b
	DCX	H
	MOV	A,M
	STA	fdiv_c
	MOV	B,C
	XCHG
	XRA	A
	MOV	C,A
	MOV	D,A
	MOV	E,A
	STA	fdiv_g
fdiv1:	PUSH	H
	PUSH	B
	MOV	A,L
fdivc:
	PUSH	H
	LXI	H,fdiv_c
	SUB	M
	POP	H
	MOV	L,A
	MOV	A,H
fdivb:
	PUSH	H
	LXI	H,fdiv_b
	SBB	M
	POP	H
	MOV	H,A
	MOV	A,B
fdiva:
	PUSH	H
	LXI	H,fdiv_a
	SBB	M
	POP	H
	MOV	B,A
fdivg:
	LDA	fdiv_g
	SBI	0
	CMC
	JNC	fdiv2
	STA	fdiv_g
	POP	PSW
	POP	PSW
	STC
	DB	0D2H
fdiv2:	POP	B
	POP	H
	MOV	A,C
	INR	A
	DCR	A
	RAR
	JM	roundb
	RAL
	MOV	A,E
	RAL
	MOV	E,A
	MOV	A,D
	RAL
	MOV	D,A
	MOV	A,C
	RAL
	MOV	C,A
	DAD	H
	MOV	A,B
	RAL
	MOV	B,A
	LDA	fdiv_g
	RAL
	STA	fdiv_g
	MOV	A,C
	ORA	D
	ORA	E
	JNZ	fdiv1
	PUSH	H
	LXI	H,fac_
	DCR	M
	POP	H
	CZ	overr
	JNZ	fdiv1
muldiv: MOV	A,B
	ORA	A
	JZ	muldv2
	MOV	A,L
	LXI	H,fac_
	XRA	M
	ADD	B
	MOV	B,A
	RAR
	XRA	B
	MOV	A,B
	JP	muldv1
	ADI	80H
	MOV	M,A
	JZ	pophrt
	CALL	unpack
	MOV	M,A
dcxhrt: DCX	H
	RET
mldvex: CALL	sign.
	CMA
	POP	H
muldv1: ORA	A
muldv2: POP	H
	CM	overr
	JMP	zero.
mul10.: CALL	movrf.
	MOV	A,B
	ORA	A
	RZ
	ADI	2
	CC	overr
	MOV	B,A
	CALL	fadd.
	LXI	H,fac_
	INR	M
	RNZ
	JMP	overr
sign.:	LDA	fac_
	ORA	A
	RZ
signc:	LDA	facl_2
	DB	0FEH
fcomps: CMA
	RAL
	SBB	A
	RNZ
inrart: INR	A
	RET
fflo:	MVI	B,98H
	MOV	A,C
	JMP	floatr
float.: MVI	B,88H
	LXI	D,0000H
floatr: LXI	H,fac_
	MOV	C,A
	MOV	M,B
	MVI	B,0
	INX	H
	MVI	M,80H
	RAL
	JMP	fadflt
flneg.: LXI	H,facl_2
	MOV	A,M
	XRI	80H
	MOV	M,A
	RET
pushf.: XCHG
	LHLD	facl_
	XTHL
	PUSH	H
	LHLD	facl_2
	XTHL
	PUSH	H
	XCHG
	RET
movfm.: CALL	movrm.
movfr.: XCHG
	SHLD	facl_
	MOV	H,B
	MOV	L,C
	SHLD	facl_2
	XCHG
	RET
movrf.: LXI	H,facl_
	JMP	movrm.
inxhr.: INX	H
	RET
movmf.: LXI	D,facl_
move:	MVI	B,4
move1:	LDAX	D
	MOV	M,A
	INX	D
	INX	H
	DCR	B
	JNZ	move1
	RET
unpack: LXI	H,facl_2
	MOV	A,M
	RLC
	STC
	RAR
	MOV	M,A
	CMC
	RAR
	INX	H
	INX	H
	MOV	M,A
	MOV	A,C
	RLC
	STC
	RAR
	MOV	C,A
	RAR
	XRA	M
	RET
fcomp.: MOV	A,B
	ORA	A
	JZ	sign.
	LXI	H,fcomps
	PUSH	H
	CALL	sign.
	MOV	A,C
	RZ
	LXI	H,facl_2
	XRA	M
	MOV	A,C
	RM
	CALL	fcomp2
fcompd: RAR
	XRA	C
	RET
fcomp2: INX	H
	MOV	A,B
	CMP	M
	RNZ
	DCX	H
	MOV	A,C
	CMP	M
	RNZ
	DCX	H
	MOV	A,D
	CMP	M
	RNZ
	DCX	H
	MOV	A,E
	SUB	M
	RNZ
	POP	H
	POP	H
	RET
fint.:	LXI	B,6900H
	MOV	D,C
	MOV	E,C
	CALL	fadd.
	LXI	H,fac_
	MOV	A,M
qint.:	MOV	B,A
	MOV	C,A
	MOV	D,A
	MOV	E,A
	ORA	A
	RZ
	PUSH	H
	CALL	movrf.
	CALL	unpack
	XRA	M
	MOV	H,A
	CM	qinta
	MVI	A,98H
	SUB	B
	CALL	shiftr
	MOV	A,H
	RAL
	CC	rounda
	MVI	B,0
	CC	negr
	POP	H
	RET
qinta:	DCX	D
	MOV	A,D
	ANA	E
	INR	A
	RNZ
dcxbrt: DCX	B
	RET
int:	LXI	H,fac_
	MOV	A,M
	CPI	98H
	LDA	facl_
	RNC
	MOV	A,M
	CALL	qint.
	MVI	M,98H
	MOV	A,E
	PUSH	PSW
	MOV	A,C
	RAL
	CALL	fadflt
	POP	PSW
	RET
overr:	CALL	erreur
	DB	1
	RET
dv0err: CALL	erreur
	DB	3
	RET
erreur:
	XTHL
	PUSH	PSW
	LDA	errcod
	ORA	A
	JNZ	exiterr
	MOV	A,M
	STA	errcod
exiterr:
	INX	H
	POP	PSW
	XTHL
	RET
Hc.Bf:	CALL	Hc.Bl
	JMP	HiBf0
Hi.Bf:	CALL	Hi.Bl
HiBf0:	CALL	fflo
	JMP	movrf.
Hu.Bf:	CALL	Hu.Bl
Bl.Bf:
	MOV	A,B
	ORA	A
	JP	BlBf0
	CALL	L.neg
	MVI	A,-1
BlBf0:	PUSH	PSW
	PUSH	B
	MVI	C,0
	CALL	fflo
	POP	B
	CALL	pushf.
	MOV	E,C
	MOV	D,B
	MVI	C,0
	CALL	fflo
	LDA	fac_
	ORA	A
	JZ	R_b
	ADI	16
	STA	fac_
R_b:	POP	B
	POP	D
	CALL	fadd.
	POP	PSW
	ORA	A
	CM	flneg.
	JMP	movrf.
Bf.Hc:	CALL	Bf.Bl
	XCHG
	JMP	c.sxt
Bf.Hu:	DS	0
Bf.Hi:	CALL	Bf.Bl
	XCHG
	RET
Bf.Bl:	MOV	A,B
	ORA	A
	JNZ	BfBl0
	MOV	C,A
	MOV	D,A
	MOV	E,A
	RET
BfBl0:
	LXI	H,0
	MOV	A,C
	XRI	80H
	JM	BfBl1
	MOV	C,A
	INR	H
BfBl1:	MOV	A,B
	CPI	128+32
	JNC	BfBlov
	CPI	128+24
	JC	BfBl2
	SUI	8
	MOV	B,A
	INR	L
BfBl2:	PUSH	H
	CALL	movfr.
	CALL	fint.
	MVI	B,0
	POP	H
	DCR	L
	JNZ	BfBl3
	MOV	B,C
	MOV	C,D
	MOV	D,E
	MVI	E,0
BfBl3:	DCR	H
	RNZ
	JMP	L.neg
BfBlov: LXI	B,7FFFH
	LXI	D,-1
	JMP	BfBl3
F.not:	LXI	H,1
	MOV	A,B
	ORA	A
	RNZ
	DCR	L
	RET
flt.0:	MOV	A,B
	ORA	A
	RET
	RET
f_stak:	DS	0
I..F::	XTHL
	PUSH	H
	LXI	H,Hi.Bf
	JMP	C.1632
C..F::	XTHL
	PUSH	H
	LXI	H,Hc.Bf
	JMP	C.1632
U..F::	XTHL
	PUSH	H
	LXI	H,Hu.Bf
	JMP	C.1632
F..C::	PUSH	H
	LXI	H,Bf.Hc
	JMP	C.3216
F..U::	PUSH	H
	LXI	H,Bf.Hu
	JMP	C.3216
F..I::	PUSH	H
	LXI	H,Bf.Hi
	JMP	C.3216
L..F::	XRA	A
	JMP	C3232
F..L::	MVI	A,1
C3232:	PUSH	B
	PUSH	D
	PUSH	H
	LXI	H,her.32
	PUSH	H
	LXI	H,10
	DAD	SP
	CALL	movrm.
	ORA	A
	JZ	Bl.Bf
	JMP	Bf.Bl
	RET
.tmvb:	DW	-27009,-26600
.umvb:	DW	9216,-27532
digc__:	DB	6
fmtc__:	DB	69
.vmvb:	DW	16960,15,-31072,1,10000,0,1000,0
	DW	100,0,10,0,1,0
.wmvb:	DW	9216,-27788,20480,-28605,16384,-29412,0,-30342
	DW	0,-31160,0,-31968,0,32768,-13107,31820
	DW	-10486,31011,4718,30211,-18666,29265,-14933,28455
	DW	-16493,27478,-13194,26667
ftoa:	LXI	H,8
	DAD	SP
	CALL	h.
	MOV	A,L
	STA	digc__
	LXI	H,10
	DAD	SP
	CALL	g.
	MOV	A,L
	STA	fmtc__
	LXI	H,4
	DAD	SP
	CALL	movrm.
	CALL	movfr.
	POP	D
	POP	H
	PUSH	H
	PUSH	D
	CALL	sign.
	JP	fout1
	MVI	M,'-'
	INX	H
fout1:	MVI	M,'0'
	JZ	fout19a
	PUSH	H
	CM	flneg.
	LDA	fmtc__
	ANI	0137Q
	CPI	'E'
	JZ	fout41
	LDA	digc__
	ADI	6
	CALL	f.round
fout41: XRA	A
	PUSH	PSW
	CALL	foutcb
fout3:	DS	0
	LXI	H,.umvb
	CALL	llong.
	CALL	fcomp.
	ORA	A
	JP	fout5
	CALL	mul10.
	POP	PSW
	DCR	A
	PUSH	PSW
	JMP	fout3
foutcb: DS	0
	LXI	H,.tmvb
	CALL	llong.
	CALL	fcomp.
	ORA	A
	POP	H
	JPO	fout9
	PCHL
fout9:	CALL	div10.
	POP	PSW
	INR	A
	PUSH	PSW
	CALL	foutcb
fout5:	LDA	fmtc__
	ANI	0137Q
	CPI	'E'
	JNZ	fout5a
	LDA	digc__
	CALL	f.round
	CALL	foutcb
fout5a: MVI	A,1
	CALL	qint.
	CALL	movfr.
	POP	PSW
	POP	H
	ADI	7-1
	MOV	C,A
	LDA	fmtc__
	ANI	0137Q
	CPI	'E'
	MVI	B,2
	MOV	A,C
	JZ	fout6
	ADI	2
	MOV	B,A
	MVI	A,0
	JZ	fout6a
	JP	fout6
fout6a: MVI	M,'.'
	INX	H
	LDA	digc__
	DCR	B
fout32: MVI	M,'0'
	INX	H
	DCR	A
	JZ	fout17
	INR	B
	JM	fout32
	MVI	B,0
	STA	digc__
	XRA	A
fout6:	PUSH	PSW
	LDA	digc__
	PUSH	PSW
	MVI	C,7
	XCHG
	LXI	H,.vmvb
	XCHG
fout8:	DCR	C
	JM	fout8b
	DCR	B
	JM	fout8g
	JNZ	fout8f
	MVI	M,'.'
	INX	H
fout8g: POP	PSW
	DCR	A
	JM	fout11
	PUSH	PSW
fout8f: PUSH	B
	PUSH	H
	PUSH	D
	CALL	movrf.
	POP	H
	MVI	B,2FH
fout10: INR	B
	MOV	A,E
	SUB	M
	MOV	E,A
	INX	H
	MOV	A,D
	SBB	M
	MOV	D,A
	INX	H
	MOV	A,C
	SBB	M
	MOV	C,A
	DCX	H
	DCX	H
	JNC	fout10
	CALL	fadda.
	INX	H
	INX	H
	CALL	movfr.
	XCHG
	POP	H
	MOV	M,B
	INX	H
	POP	B
	JMP	fout8
fout8b: MOV	A,B
	DCR	A
	CALL	foutt.
	DCR	B
	MVI	M,'.'
	CP	inxhr.
	POP	PSW
	CALL	foutt.
fout11: LDA	fmtc__
	ANI	040Q
	JNZ	fout12
fout11a: DCX	 H
	MOV	A,M
	CPI	'0'
	JZ	fout11a
	CPI	'.'
	CNZ	inxhr.
fout12: POP	PSW
	ORA	A
	JZ	fout17
fout20: MVI	M,'e'
	INX	H
	MVI	M,'+'
	JP	fout14
	MVI	M,'-'
	CMA
	INR	A
fout14: MVI	B,'0'-1
fout15: INR	B
	SUI	10
	JNC	fout15
	INX	H
	MOV	M,B
fout19: INX	H
	ADI	'0'+10
	MOV	M,A
fout19a: INX	H
fout17: MVI	M,0
	RET
foutt.: DCR	A
	RM
	MVI	M,'0'
	INX	H
	JMP	foutt.
f.round: ADD	A
	RM
	CPI	28
	RNC
	ADD	A
	MOV	E,A
	MVI	D,0
	LXI	H,.wmvb
	DAD	D
	CALL	movrm.
	JMP	fadd.
	RET
atof:	DS	0
	LXI	H,2
	DAD	SP
	MOV	E,M
	INX	H
	MOV	D,M
	XCHG
	MOV	A,M
	CALL	ffin
	JMP	movrf.
ffin:	CPI	'-'
	PUSH	PSW
	JZ	fin1
	CPI	'+'
	JZ	fin1
	DCX	H
fin1:	CALL	zero.
	MOV	B,A
	MOV	D,A
	MOV	E,A
	CMA
	MOV	C,A
finc:	CALL	chrgtr
	JC	findig
	CPI	'.'
	JZ	findp
	CPI	'e'
	JZ	founde
	CPI	'E'
	JNZ	fine
founde:
	CALL	chrgtr
	CALL	minpls
finec:	CALL	chrgtr
	JC	finedg
	INR	D
	JNZ	fine
	XRA	A
	SUB	E
	MOV	E,A
	INR	C
findp:	INR	C
	JZ	finc
fine:	PUSH	H
	MOV	A,E
	SUB	B
fine2:	CP	finmul
	JP	fine3
	PUSH	PSW
	CALL	div10.
	POP	PSW
	INR	A
fine3:	JNZ	fine2
	POP	D
	POP	PSW
	CZ	flneg.
	XCHG
	RET
finmul: RZ
finmlt: PUSH	PSW
	CALL	mul10.
	POP	PSW
dcrart: DCR	A
	RET
findig: PUSH	D
	MOV	D,A
	MOV	A,B
	ADC	C
	MOV	B,A
	PUSH	B
	PUSH	H
	PUSH	D
	CALL	mul10.
	POP	PSW
	SUI	30H
	CALL	finlog
	POP	H
	POP	B
	POP	D
	JMP	finc
finlog: CALL	pushf.
	CALL	float.
faddt:	POP	B
	POP	D
	JMP	fadd.
finedg: MOV	A,E
	RLC
	RLC
	ADD	E
	RLC
	ADD	M
	SUI	'0'
	MOV	E,A
	JMP	finec
chrgtr: INX	H
chrgt2: MOV	A,M
	CPI	':'
	RNC
chrcon: CPI	' '
	JZ	chrgtr
notlf:	CPI	'0'
	CMC
	INR	A
	DCR	A
	RET
minpls: DCR	D
	CPI	0A8H
	RZ
	CPI	'-'
	RZ
	INR	D
	CPI	'+'
	RZ
	CPI	0A7H
	RZ
	DCX	H
	RET
	RET
