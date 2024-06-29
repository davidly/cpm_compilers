* 32 bit common library routines; C/80 3.0 (7/1/83) - (c) 1983 Walter Bilofsky
Four_b:	DS	0
movrm.::
llong.:: MOV	 E,M
	INX	H
	MOV	D,M
	INX	H
	MOV	C,M
	INX	H
	MOV	B,M
	INX	H
	RET
st4.:	XTHL
	CALL	llong.
	XTHL
slong.: MOV	M,E
	INX	H
	MOV	M,D
	INX	H
	MOV	M,C
	INX	H
	MOV	M,B
	RET
eq.4:	POP	H
	PUSH	B
	MVI	C,1
	JMP	comp.4
neq.4:	POP	H
	PUSH	B
	MVI	C,0
comp.4:
	PUSH	D
	PUSH	H
	LXI	H,2
	DAD	SP
	XCHG
	LXI	H,6
	DAD	SP
	MVI	B,4
lneq.4: LDAX	D
	CMP	M
	INX	H
	INX	D
	JNZ	diff
	DCR	B
	JNZ	lneq.4
	XRA	A
	JMP	exneq
diff:	MVI	A,1
exneq:	POP	H
	POP	D
	POP	D
	POP	D
	XTHL
	MVI	H,0
	XRA	C
	MOV	L,A
	RET
swap4.: LXI	H,2
swaps.: DAD	SP
	MOV	A,M
	MOV	M,E
	MOV	E,A
	INX	H
	MOV	A,M
	MOV	M,D
	MOV	D,A
	INX	H
	MOV	A,M
	MOV	M,C
	MOV	C,A
	INX	H
	MOV	A,M
	MOV	M,B
	MOV	B,A
	RET
long.0: MOV	A,B
	ORA	C
	ORA	D
	ORA	E
	RET
L.not:	LXI	H,1
	CALL	long.0
	RNZ
	DCR	L
	RET
l_stak:	DS	0
C..L:	XTHL
	PUSH	H
	LXI	H,Hc.Bl
	JMP	C.1632
U..L:	XTHL
	PUSH	H
	LXI	H,Hu.Bl
	JMP	C.1632
I..L:	XTHL
	PUSH	H
	LXI	H,Hi.Bl
C.1632:: PUSH	 B
	PUSH	D
	PUSH	H
	LXI	H,8
	DAD	SP
	CALL	movrm.
	POP	H
	PUSH	D
	LXI	D,her.32
	PUSH	D
	PUSH	H
	MOV	H,B
	MOV	L,C
	RET
her.32:: LXI	 H,8
	DAD	SP
	CALL	slong.
	POP	H
	POP	D
	POP	B
	RET
L..C::	PUSH	H
	LXI	H,Bl.Hc
	JMP	C.3216
L..U::	PUSH	H
	LXI	H,Bl.Hu
	JMP	C.3216
L..I::	PUSH	H
	LXI	H,Bl.Hi
C.3216:: PUSH	 B
	PUSH	D
	PUSH	H
	LXI	H,10
	DAD	SP
	CALL	movrm.
	POP	H
	CALL	callhl
	MOV	B,H
	MOV	C,L
	LXI	H,6
	DAD	SP
	MOV	E,M
	INX	H
	MOV	D,M
	INX	H
	CALL	slong.
	POP	D
	POP	B
	POP	H
	POP	PSW
	RET
callhl: PCHL
	RET
I_long:	DS	0
Hu.Bl:	XCHG
	LXI	B,0
	RET
Hc.Bl:	MOV	A,L
	CALL	sgnbyt
	MOV	E,L
	MOV	D,A
	MOV	C,A
	MOV	B,A
	RET
Hi.Bl:	MOV	A,H
	CALL	sgnbyt
	XCHG
	MOV	C,A
	MOV	B,A
	RET
sgnbyt: ORA	A
	MVI	A,-1
	RM
	INR	A
	RET
Bl.Hu:
Bl.Hi:	XCHG
	RET
Bl.Hc:	XCHG
	JMP	c.sxt##
	RET
L_adsb:	DS	0
L.sub:	CALL	L.neg
L.add:	POP	H
	XTHL
	DAD	D
	XCHG
	POP	H
	XTHL
	MOV	A,L
	ADC	C
	MOV	C,A
	MOV	A,H
	ADC	B
	MOV	B,A
	RET
L.neg:	MVI	A,0
	SUB	E
	MOV	E,A
	MVI	A,0
	SBB	D
	MOV	D,A
	MVI	A,0
	SBB	C
	MOV	C,A
	MVI	A,0
	SBB	B
	MOV	B,A
	RET
L.com:	MOV	A,E
	CMA
	MOV	E,A
	MOV	A,D
	CMA
	MOV	D,A
	MOV	A,C
	CMA
	MOV	C,A
	MOV	A,B
	CMA
	MOV	B,A
	RET
