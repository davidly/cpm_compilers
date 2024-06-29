;C/80 Compiler 3.0a (12/6/83) - (c) 1983 The Software Toolworks

	XTEXT A:CLIBRARY.ASM
COMnf:	DW	0
COMfn:	DW	0
COMc:	DW	0
COMv:	DW	0
COMarg:	DW	0
COMs:	DW	0

command:	LXI	H,-510
	DAD	SP
	SPHL
	LXI	H,0
	DAD	SP
	SHLD	COMfn
	LXI	H,514
	DAD	SP
	CALL	h.##
	CALL	h.##
	SHLD	COMc
	LXI	H,512
	DAD	SP
	CALL	h.##
	CALL	h.##
	SHLD	COMv
	LHLD	COMfn
	PUSH	H
	LHLD	COMv
	INX	H
	INX	H
	SHLD	COMv
	DCX	H
	DCX	H
	CALL	h.##
	CALL	q.
	LXI	H,1
	SHLD	COMnf
	LHLD	COMv
	CALL	h.##
	SHLD	COMarg
.g:	LHLD	COMc
	DCX	H
	SHLD	COMc
	MOV	A,H
	ORA	L
	JZ	.f
	JMP	.h
.e:	LHLD	COMv
	INX	H
	INX	H
	SHLD	COMv
	CALL	h.##
	SHLD	COMarg
	JMP	.g
.h:	LHLD	COMarg
	SHLD	COMs
.k:	LHLD	COMs
	MOV	A,M
	ORA	A
	JZ	.j
	JMP	.l
.i:	LHLD	COMs
	INX	H
	SHLD	COMs
	DCX	H
	JMP	.k
.l:	LHLD	COMs
	CALL	g.
	LXI	D,-63
	DAD	D
	CALL	c.not
	JNZ	.n
	LHLD	COMs
	CALL	g.
	LXI	D,-42
	DAD	D
	CALL	c.not
.n:	CALL	e.0
	JZ	.m
	CALL	.d
	JMP	.o
.m:	JMP	.i
.j:	LHLD	COMnf
	INX	H
	SHLD	COMnf
	DCX	H
	DAD	H
	XCHG
	LHLD	COMfn
	DAD	D
	PUSH	H
	LHLD	COMarg
	CALL	q.
.o:	JMP	.e
.f:	LXI	H,514
	DAD	SP
	CALL	h.##
	PUSH	H
	LHLD	COMnf
	CALL	q.
	LHLD	COMnf
	INX	H
	SHLD	COMnf
	DCX	H
	DAD	H
	XCHG
	LHLD	COMfn
	DAD	D
	MVI	M,255
	INX	H
	MVI	M,255
	LXI	H,512
	DAD	SP
	CALL	h.##
	PUSH	H
	LHLD	COMnf
	DAD	H
	PUSH	H
	CALL	sbrk
	POP	B
	CALL	q.
	SHLD	COMv
.p:	LHLD	COMnf
	DCX	H
	SHLD	COMnf
	INX	H
	MOV	A,H
	ORA	L
	JZ	.q
	LHLD	COMnf
	DAD	H
	XCHG
	LHLD	COMv
	DAD	D
	PUSH	H
	LHLD	COMnf
	DAD	H
	XCHG
	LHLD	COMfn
	DAD	D
	CALL	h.##
	CALL	q.
	JMP	.p
.q:	DS	0
.r:	LXI	H,510
	DAD	SP
	SPHL
	RET
.s:	DW	0
.t:	DW	0
.u:	DW	0
.v:	DW	0

.d:	LXI	H,-36
	DAD	SP
	SPHL
	LHLD	COMarg
	PUSH	H
	LXI	H,2
	DAD	SP
	PUSH	H
	CALL	makfcb
	POP	B
	POP	B
	LXI	H,0
	DAD	SP
	CALL	g.
	INX	H
	MOV	A,H
	ORA	L
	JNZ	.w
	LXI	H,0
	DAD	SP
	MVI	M,63
.w:	LXI	H,1
	SHLD	.v
	SHLD	.u
.z:	LHLD	.u
	LXI	D,32756
	CALL	c.tst
	JC	.y
	JMP	.ab
.x:	LHLD	.u
	INX	H
	SHLD	.u
	JMP	.z
.ab:	LHLD	.u
	LXI	D,-9
	DAD	D
	MOV	A,H
	ORA	L
	JNZ	.bb
	LXI	H,1
	SHLD	.v
.bb:	LXI	H,0
	DAD	SP
	XCHG
	LHLD	.u
	DAD	D
	CALL	g.
	LXI	D,-42
	DAD	D
	MOV	A,H
	ORA	L
	JNZ	.cb
	LXI	H,0
	SHLD	.v
.cb:	LHLD	.v
	MOV	A,H
	ORA	L
	JNZ	.db
	LXI	H,0
	DAD	SP
	XCHG
	LHLD	.u
	DAD	D
	MVI	M,63
.db:	JMP	.x
.y:	LXI	H,17
	SHLD	.v
	LXI	H,26
	PUSH	H
	LXI	H,128
	PUSH	H
	CALL	bdos
	POP	B
	POP	B
.eb:	LHLD	.v
	PUSH	H
	LXI	H,2
	DAD	SP
	PUSH	H
	CALL	bdos
	POP	B
	POP	B
	SHLD	.u
	INX	H
	CALL	e.0
	JZ	.fb
	LHLD	COMnf
	INX	H
	SHLD	COMnf
	DCX	H
	DAD	H
	XCHG
	LHLD	COMfn
	DAD	D
	PUSH	H
	LXI	H,15
	PUSH	H
	CALL	sbrk
	POP	B
	SHLD	.t
	CALL	q.
	LHLD	COMnf
	LXI	D,32514
	CALL	c.tst
	JNC	.gb
	LXI	H,.c
	SHLD	.s
.jb:	LHLD	.s
	INX	H
	SHLD	.s
	DCX	H
	CALL	g.
	PUSH	H
	CALL	putchar
	POP	B
	MOV	A,H
	ORA	L
	JZ	.ib
	JMP	.jb
.ib:	LXI	H,0
	PUSH	H
	CALL	exit
	POP	B
.gb:	LHLD	.u
	DAD	H
	DAD	H
	DAD	H
	DAD	H
	DAD	H
	LXI	D,129
	DAD	D
	SHLD	.s
	LHLD	COMarg
	INX	H
	CALL	g.
	LXI	D,-58
	DAD	D
	CALL	c.not
	JZ	.lb
	LHLD	COMarg
	CALL	g.
	LXI	D,-63
	DAD	D
	CALL	e.0
.lb:	CALL	e.0
	JZ	.kb
	LHLD	.t
	INX	H
	SHLD	.t
	DCX	H
	PUSH	H
	LHLD	COMarg
	CALL	g.
	POP	D
	MOV	A,L
	STAX	D
	LHLD	.t
	INX	H
	SHLD	.t
	DCX	H
	MVI	M,58
.kb:	LXI	H,12
	SHLD	.u
.ob:	LHLD	.u
	DCX	H
	SHLD	.u
	MOV	A,H
	ORA	L
	JZ	.nb
	LHLD	.u
	DCX	H
	DCX	H
	DCX	H
	MOV	A,H
	ORA	L
	JNZ	.pb
	LHLD	.t
	INX	H
	SHLD	.t
	DCX	H
	MVI	M,46
.pb:	LHLD	.t
	PUSH	H
	LHLD	.s
	INX	H
	SHLD	.s
	DCX	H
	CALL	g.
	MVI	H,0
	MOV	A,L
	ANI	127
	MOV	L,A
	POP	D
	MOV	A,L
	STAX	D
	LXI	D,-32
	DAD	D
	CALL	e.0
	JZ	.qb
	LHLD	.t
	INX	H
	SHLD	.t
.qb:	JMP	.ob
.nb:	LHLD	.t
	MVI	M,0
	LXI	H,18
	SHLD	.v
	JMP	.eb
.fb:	DS	0
.rb:	LXI	H,36
	DAD	SP
	SPHL
	RET

makfcb:	DS	0

;#asm
	POP B
	POP H
	POP D
	PUSH D
	PUSH H
	PUSH B
;#endasm
	CALL	x_fcb
	RET

bdos:	DS	0
;#asm
	POP H
	POP D		; Get arguments into d
	POP B		; and b.
	PUSH B		; Restore stack.
	PUSH D
	PUSH H
	CALL 5		; Call BDOS.
	MOV L,A 	; Return value from A.
	MVI H,0
	ORA A		; Extend sign of value.
	RP
	DCR H
;#endasm
	RET
.c:
	DB	'Too many file names.'
	DB	10
	DB	0
$END	DS	0
	END	$INIT
