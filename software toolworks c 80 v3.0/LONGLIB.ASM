* Long runtime library; C/80 3.0 (5/28/83) - (c) 1983 Walter Bilofsky
L_shif:	DS	0
L.and:	LXI	H,2
	DAD	SP
	MOV	A,M
	ANA	E
	MOV	E,A
	INX	H
	MOV	A,M
	ANA	D
	MOV	D,A
	INX	H
	MOV	A,M
	ANA	C
	MOV	C,A
	INX	H
	MOV	A,M
	ANA	B
	MOV	B,A
	POP	H
	INX	SP
	INX	SP
	XTHL
	RET
L.asr:	XRA	A
	ORA	B
	ORA	C
	ORA	D
	JNZ	Lasr9
	ORA	E
	JZ	Lasr3
	MOV	A,E
	CPI	32
	JNC	Lasr9
Lasr2:	MVI	B,4
	LXI	H,5
	DAD	SP
	XRA	A
	MOV	A,M
	ORA	A
	JP	Lasr1
	STC
Lasr1:	MOV	A,M
	RAR
	MOV	M,A
	DCX	H
	DCR	B
	JNZ	Lasr1
	DCR	E
	JNZ	Lasr2
Lasr3:	POP	H
	POP	D
	POP	B
	PCHL
Lasr9:
	LXI	H,5
	DAD	SP
	MOV	A,M
	ORA	A
	MVI	A,0
	JP	Lasr8
	DCR	A
Lasr8:	MVI	B,4
Lasr7:	MOV	M,A
	DCX	H
	DCR	B
	JNZ	Lasr7
	JMP	Lasr3
L.asl:	XRA	A
	ORA	B
	ORA	C
	ORA	D
	JNZ	Lasl9
	ORA	E
	JZ	Lasr3
	MOV	A,E
	CPI	32
	JNC	Lasl9
Lasl2:	MVI	B,4
	LXI	H,2
	DAD	SP
	XRA	A
Lasl4:	MOV	A,M
	RAL
	MOV	M,A
	INX	H
	DCR	B
	JNZ	Lasl4
	DCR	E
	JNZ	Lasl2
	JMP	Lasr3
Lasl9:	LXI	H,5
	DAD	SP
	XRA	A
	JMP	Lasr8
	RET
L_comp:	DS	0
cl.lt:	LXI	H,4
	CALL	swaps.
cl.gt:	LXI	H,1
cl.glt: PUSH	H
	CALL	sstak
	POP	H
	PUSH	PSW
	CALL	long.0
	JNZ	clgt1
	POP	PSW
	JMP	clgt2
clgt1:	POP	PSW
	LXI	H,2
	JNC	clgt2
	DCR	L
clgt2:	POP	D
	POP	B
	POP	B
	PUSH	D
	DCR	L
	RET
cl.le:	LXI	H,4
	CALL	swaps.
cl.ge:	LXI	H,2
	JMP	cl.glt
sstak:	LXI	H,6
	DAD	SP
	MOV	A,M
	SUB	E
	MOV	E,A
	INX	H
	MOV	A,M
	SBB	D
	MOV	D,A
	INX	H
	MOV	A,M
	SBB	C
	MOV	C,A
	INX	H
	MOV	A,M
	MOV	L,B
	MOV	H,A
	SBB	B
	MOV	B,A
	PUSH	PSW
	MOV	A,H
	XRA	L
	JP	snorml
	POP	PSW
	CMC
	RET
snorml: POP	PSW
	RET
	RET
L_mdiv:	DS	0
L.mul:	PUSH	B
	PUSH	D
	LXI	D,0
	PUSH	D
	PUSH	D
Lmshtx: MVI	B,4
	LXI	H,7
	DAD	SP
	XRA	A
Lmrtx:	MOV	A,M
	RAR
	MOV	M,A
	DCX	H
	DCR	B
	JNZ	Lmrtx
	JNC	Lmul0
	MVI	B,4
	LXI	H,10
	DAD	SP
	XCHG
	LXI	H,0
	DAD	SP
	XRA	A
Lmnxt:	LDAX	D
	ADC	M
	MOV	M,A
	INX	D
	INX	H
	DCR	B
	JNZ	Lmnxt
Lmul0:	LXI	H,4
	MOV	B,L
	MOV	A,H
	DAD	SP
Lmzchk: ORA	M
	JNZ	Lmshty
	INX	H
	DCR	B
	JNZ	Lmzchk
	JMP	Lmexi
Lmshty: MVI	B,4
	LXI	H,10
	DAD	SP
	XRA	A
Lmlfty: MOV	A,M
	RAL
	MOV	M,A
	INX	H
	DCR	B
	JNZ	Lmlfty
	JMP	Lmshtx
Lmexi:	LXI	H,8
	DAD	SP
	MOV	E,M
	INX	H
	MOV	D,M
	INX	H
	INX	H
	INX	H
	MOV	M,E
	INX	H
	MOV	M,D
	POP	D
	POP	B
	LXI	H,8
	DAD	SP
	SPHL
	RET
L.mod:	MVI	L,0
	JMP	Ldiv0
L.div:	MVI	L,1
Ldiv0:	PUSH	H
	PUSH	B
	PUSH	D
	MOV	A,B
	ORA	A
	JP	Ldiv1
	CALL	negst4
	MVI	A,-1
Ldiv1:	PUSH	PSW
	LXI	H,0
	PUSH	H
	PUSH	H
	MVI	L,17
	DAD	SP
	MOV	B,M
	DCX	H
	MOV	C,M
	DCX	H
	MOV	D,M
	DCX	H
	MOV	E,M
	PUSH	B
	PUSH	D
	MOV	A,B
	ORA	A
	JP	Ldiv2
	CALL	negst4
	MVI	A,-1
Ldiv2:	LXI	H,9
	DAD	SP
	XRA	M
	MOV	M,A
	LXI	H,0
	PUSH	H
	PUSH	H
	MVI	A,32
Ldiv10: PUSH	PSW
	LXI	H,6
	DAD	SP
	XRA	A
	MVI	B,8
Ldiv3:	MOV	A,M
	RAL
	MOV	M,A
	INX	H
	DCR	B
	JNZ	Ldiv3
	LXI	H,13
	DAD	SP
	XCHG
	LXI	H,19
	DAD	SP
	LXI	B,4*256
Ldiv5:	LDAX	D
	CMP	M
	JC	Ldiv4
	JNZ	Ldiv44
	DCX	H
	DCX	D
	DCR	B
	JNZ	Ldiv5
Ldiv44:
	INR	C
Ldiv4:
	CMC
	PUSH	PSW
	LXI	H,4
	DAD	SP
	POP	PSW
	MVI	B,4
Ldiv7:	MOV	A,M
	RAL
	MOV	M,A
	INX	H
	DCR	B
	JNZ	Ldiv7
	MOV	A,C
	ORA	A
	JZ	Ldiv8
	LXI	H,16
	DAD	SP
	XCHG
	LXI	H,10
	DAD	SP
	XRA	A
	XCHG
	MVI	B,4
Ldiv9:	LDAX	D
	SBB	M
	STAX	D
	INX	H
	INX	D
	DCR	B
	JNZ	Ldiv9
Ldiv8:
	POP	PSW
	DCR	A
	JNZ	Ldiv10
	LXI	H,18
	DAD	SP
	MOV	A,M
	ORA	A
	JNZ	Ldiv20
	LXI	H,8
	DAD	SP
	XCHG
	LXI	H,0
	DAD	SP
	XCHG
	MVI	B,4
Ldiv21: MOV	A,M
	STAX	D
	INX	H
	INX	D
	DCR	B
	JNZ	Ldiv21
Ldiv20:
	LXI	H,13
	DAD	SP
	MOV	A,M
	ORA	A
	CM	negst4
	POP	D
	POP	B
	LXI	H,16
	DAD	SP
	SPHL
outLL:	POP	H
	INX	SP
	INX	SP
	XTHL
	RET
negst4:
	PUSH	H
	PUSH	B
	LXI	B,4*256
	LXI	H,6
	DAD	SP
	XRA	A
ngst4l: MOV	A,C
	SBB	M
	MOV	M,A
	INX	H
	DCR	B
	JNZ	ngst4l
	POP	B
	POP	H
	RET
L.or:	LXI	H,2
	DAD	SP
	MOV	A,M
	ORA	E
	MOV	E,A
	INX	H
	MOV	A,M
	ORA	D
	MOV	D,A
	INX	H
	MOV	A,M
	ORA	C
	MOV	C,A
	INX	H
	MOV	A,M
	ORA	B
	MOV	B,A
	JMP	outLL
L.xor:	LXI	H,2
	DAD	SP
	MOV	A,M
	XRA	E
	MOV	E,A
	INX	H
	MOV	A,M
	XRA	D
	MOV	D,A
	INX	H
	MOV	A,M
	XRA	C
	MOV	C,A
	INX	H
	MOV	A,M
	XRA	B
	MOV	B,A
	JMP	outLL
	RET
