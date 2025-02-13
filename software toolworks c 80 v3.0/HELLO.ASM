;C/80 Compiler 3.0 (8/10/83) - (c) 1983 The Software Toolworks

	XTEXT B:CLIBRARY.ASM
.d:	DW	0
.e:	DW	.c
.f:	DB	0
.g:	DW	0
.h:	DW	0
.i:	DW	0
.j:	DW	0
.k:	DB	0
.l:	DW	0
.m:	DW	0
.n:	DW	0

prnt_1:	LXI	H,2
	DAD	SP
	SHLD	.d
	RET

prnt_2:	LHLD	.d
	DCX	H
	DCX	H
	SHLD	.d
	CALL	h.
	PUSH	H
	CALL	format
	POP	B

;#asm
@prnt@: DS      0
;#endasm
.x:	LXI	H,2
	DAD	SP
	XCHG
	LHLD	.d
	CALL	c.ult
	JZ	.y
	LHLD	.d
	PUSH	H
	CALL	printf
	POP	B
	JMP	.x
.y:	RET

prnt_3:	LHLD	.d
	DCX	H
	DCX	H
	SHLD	.d
	CALL	h.
	MOV	A,L
	STA	.f
	LDA	.f
	CALL	c.sxt
	PUSH	H
	LHLD	.d
	DCX	H
	DCX	H
	SHLD	.d
	CALL	h.
	PUSH	H
	CALL	fformat
	POP	B
	POP	B
;#asm
        JMP     @prnt@
;#endasm
	RET

prnt_4:	LHLD	.d
	DCX	H
	DCX	H
	SHLD	.d
	CALL	h.
	SHLD	.g
	LHLD	.g
	PUSH	H
	LHLD	.d
	DCX	H
	DCX	H
	SHLD	.d
	CALL	h.
	PUSH	H
	CALL	sformat
	POP	B
	POP	B
;#asm
        JMP     @prnt@
;#endasm
	RET

format:	LXI	H,0
	PUSH	H
	LXI	H,4
	DAD	SP
	CALL	h.
	PUSH	H
	CALL	fformat
	POP	B
	POP	B
	RET

fformat:	LXI	H,4
	DAD	SP
	CALL	g.
	MOV	A,L
	STA	.f
	LXI	H,2
	DAD	SP
	CALL	h.
	SHLD	.e
	CALL	.o
	RET

sformat:	LXI	H,4
	DAD	SP
	CALL	h.
	SHLD	.g
	LXI	H,-2
	PUSH	H
	LXI	H,4
	DAD	SP
	CALL	h.
	PUSH	H
	CALL	fformat
	POP	B
	POP	B
	RET

.o:	DS	0
.z:	LHLD	.e
	CALL	g.
	CALL	e.0
	JZ	.bb
	LHLD	.e
	CALL	g.
	LXI	D,-37
	DAD	D
	CALL	e.0
.bb:	CALL	e.0
	JZ	.ab
	LHLD	.e
	INX	H
	SHLD	.e
	DCX	H
	CALL	g.
	PUSH	H
	CALL	.p
	POP	B
	JMP	.z
.ab:	RET

.p:	LDA	.f
	CALL	c.sxt
	JMP	.db
.eb:	LXI	H,2
	DAD	SP
	CALL	g.
	PUSH	H
	CALL	putchar
	POP	B
	RET
.fb:	LHLD	.g
	INX	H
	SHLD	.g
	DCX	H
	PUSH	H
	LXI	H,4
	DAD	SP
	CALL	g.
	POP	D
	MOV	A,L
	STAX	D
	LHLD	.g
	MVI	M,0
	RET
.gb:	LXI	H,2
	DAD	SP
	CALL	g.
	PUSH	H
	LDA	.f
	CALL	c.sxt
	PUSH	H
	CALL	putc
	POP	B
	POP	B
	JMP	.cb
.db:	CALL	.switch
	DW	.eb,0
	DW	.fb,-2
	DW	0
	JMP	.gb
.cb:	RET
.hb:	DW	0
.ib:	DW	0
.jb:	DW	0
.kb:	DW	0

printf:	LXI	H,0
	SHLD	.hb
	SHLD	.i
	LXI	H,2
	DAD	SP
	PUSH	H
	LHLD	.d
	CALL	q.
	LHLD	.d
	DCX	H
	DCX	H
	SHLD	.d
	LHLD	.e
	INX	H
	SHLD	.e
	CALL	g.
	SHLD	.j
	CALL	c.not
	JZ	.lb
	RET
.lb:	LXI	H,32
	MOV	A,L
	STA	.k
	LHLD	.j
	LXI	D,-45
	DAD	D
	CALL	c.not
	SHLD	.l
	MOV	A,H
	ORA	L
	JZ	.mb
	LHLD	.e
	INX	H
	SHLD	.e
	DCX	H
	CALL	g.
	SHLD	.j
.mb:	LHLD	.j
	LXI	D,-48
	DAD	D
	MOV	A,H
	ORA	L
	JNZ	.nb
	LXI	H,48
	MOV	A,L
	STA	.k
	LHLD	.e
	INX	H
	SHLD	.e
	DCX	H
	CALL	g.
	SHLD	.j
.nb:	CALL	.q
	SHLD	.h
	LHLD	.j
	LXI	D,-46
	DAD	D
	MOV	A,H
	ORA	L
	JNZ	.ob
	LHLD	.e
	INX	H
	SHLD	.e
	CALL	.q
	SHLD	.i
.ob:	LHLD	.e
	INX	H
	SHLD	.e
	DCX	H
	CALL	g.
	SHLD	.j
	LXI	D,-115
	DAD	D
	CALL	e.0
	JZ	.qb
	LHLD	.i
	LXI	D,7
	CALL	c.lt
.qb:	CALL	e.0
	JZ	.pb
	LXI	H,7
	SHLD	.i
.pb:	LHLD	.j
	JMP	.sb
.tb:	LXI	H,2
	DAD	SP
	PUSH	H
	CALL	h.
	DCX	H
	DCX	H
	CALL	q.
	CALL	h.
	PUSH	H
	CALL	.p
	POP	B
	JMP	.rb
.ub:	LXI	H,2
	DAD	SP
	PUSH	H
	CALL	h.
	DCX	H
	DCX	H
	CALL	q.
	CALL	h.
	PUSH	H
	LXI	H,10
	PUSH	H
	CALL	.r
	POP	B
	POP	B
	JMP	.rb
.vb:	LXI	H,8
	SHLD	.hb
	JMP	.wb
.xb:	LXI	H,10
	SHLD	.hb
	JMP	.wb
.yb:	LXI	H,16
	SHLD	.hb
.wb:	LXI	H,2
	DAD	SP
	PUSH	H
	CALL	h.
	DCX	H
	DCX	H
	CALL	q.
	CALL	h.
	SHLD	.ib
	LHLD	.ib
	PUSH	H
	LHLD	.hb
	PUSH	H
	CALL	.s
	POP	B
	POP	B
	JMP	.rb
.zb:	LXI	H,2
	DAD	SP
	PUSH	H
	CALL	h.
	DCX	H
	DCX	H
	CALL	q.
	CALL	h.
	SHLD	.jb
	SHLD	.kb
.cc:	LHLD	.kb
	INX	H
	SHLD	.kb
	DCX	H
	CALL	g.
	MOV	A,H
	ORA	L
	JZ	.bc
	JMP	.cc
.bc:	LHLD	.kb
	DCX	H
	SHLD	.kb
	PUSH	H
	LHLD	.jb
	CALL	s.
	XCHG
	LHLD	.i
	CALL	c.gt
	JZ	.ec
	LHLD	.i
.ec:	CALL	e.0
	JZ	.dc
	LHLD	.jb
	XCHG
	LHLD	.i
	DAD	D
	SHLD	.kb
.dc:	LHLD	.jb
	PUSH	H
	LHLD	.kb
	PUSH	H
	CALL	.t
	POP	B
	POP	B
	JMP	.rb
.fc:	RET
.gc:	LHLD	.j
	PUSH	H
	CALL	.p
	POP	B
	JMP	.rb
.sb:	CALL	.switch
	DW	.tb,99
	DW	.ub,100
	DW	.vb,111
	DW	.xb,117
	DW	.yb,120
	DW	.zb,115
	DW	.fc,0
	DW	0
	JMP	.gc
.rb:	CALL	.o
	RET
.hc:	DW	0

.q:	LHLD	.hc
	PUSH	H
	LXI	H,0
	SHLD	.hc
.kc:	LHLD	.e
	CALL	g.
	SHLD	.j
	LXI	D,48
	CALL	c.le
	JZ	.lc
	LHLD	.j
	LXI	D,57
	CALL	c.ge
.lc:	CALL	e.0
	JZ	.jc
	LHLD	.hc
	LXI	D,10
	CALL	c.mult
	PUSH	H
	LHLD	.e
	INX	H
	SHLD	.e
	DCX	H
	CALL	g.
	POP	D
	DAD	D
	LXI	D,-48
	DAD	D
	SHLD	.hc
	JMP	.kc
.jc:	LHLD	.hc
.mc:	XCHG
	POP	H
	SHLD	.hc
	XCHG
	RET
.nc:	DW	0
.oc:	DW	0

.w:	LXI	H,2
	DAD	SP
	CALL	h.
	SHLD	.nc
	LXI	H,4
	DAD	SP
	CALL	h.
	SHLD	.oc
.rc:	LXI	H,6
	DAD	SP
	PUSH	H
	CALL	h.
	DCX	H
	CALL	q.
	PUSH	H
	LHLD	.nc
	LXI	D,-10
	DAD	D
	CALL	c.not
	JZ	.sc
	LHLD	.oc
	XCHG
	LXI	H,10
	CALL	c.udv
	XCHG
	JMP	.tc
.sc:	LHLD	.nc
	DCX	H
	PUSH	H
	LHLD	.oc
	CALL	a.
.tc:	PUSH	H
	CALL	.v
	POP	B
	POP	D
	MOV	A,L
	STAX	D
	LHLD	.nc
	LXI	D,-8
	DAD	D
	CALL	c.not
	JZ	.uc
	LHLD	.oc
	XCHG
	LXI	H,3
	CALL	c.usr
	JMP	.vc
.uc:	LHLD	.nc
	LXI	D,-10
	DAD	D
	CALL	c.not
	JZ	.wc
	LHLD	.oc
	XCHG
	LXI	H,10
	CALL	c.udv
	JMP	.xc
.wc:	LHLD	.oc
	XCHG
	LXI	H,4
	CALL	c.usr
.xc:	DS	0
.vc:	SHLD	.oc
.pc:	LHLD	.oc
	MOV	A,H
	ORA	L
	JNZ	.rc
.qc:	LXI	H,6
	DAD	SP
	CALL	h.
	RET
.yc:	DW	0

.r:	LXI	H,-80
	DAD	SP
	SPHL
	LXI	H,84
	DAD	SP
	CALL	h.
	LXI	D,0
	CALL	c.gt
	JZ	.zc
	LXI	H,84
	DAD	SP
	CALL	h.
	CALL	c.neg
	JMP	.ad
.zc:	LXI	H,84
	DAD	SP
	CALL	h.
.ad:	SHLD	.yc
	LXI	H,0
	DAD	SP
	LXI	D,80
	DAD	D
	SHLD	.n
	PUSH	H
	LHLD	.yc
	PUSH	H
	LXI	H,86
	DAD	SP
	CALL	h.
	PUSH	H
	CALL	.w
	POP	B
	POP	B
	POP	B
	SHLD	.m
	LXI	H,84
	DAD	SP
	CALL	h.
	LXI	D,0
	CALL	c.gt
	JZ	.bd
	LDA	.k
	CALL	c.sxt
	LXI	D,-32
	DAD	D
	MOV	A,H
	ORA	L
	JZ	.cd
	LXI	H,45
	PUSH	H
	CALL	.p
	POP	B
	LHLD	.h
	DCX	H
	SHLD	.h
	JMP	.dd
.cd:	LHLD	.m
	DCX	H
	SHLD	.m
	MVI	M,45
.dd:	DS	0
.bd:	LHLD	.m
	PUSH	H
	LHLD	.n
	PUSH	H
	CALL	.t
	POP	B
	POP	B
.ed:	LXI	H,80
	DAD	SP
	SPHL
	RET

.s:	LXI	H,-80
	DAD	SP
	SPHL
	LXI	H,0
	DAD	SP
	LXI	D,80
	DAD	D
	SHLD	.n
	PUSH	H
	LXI	H,86
	DAD	SP
	CALL	h.
	PUSH	H
	LXI	H,86
	DAD	SP
	CALL	h.
	PUSH	H
	CALL	.w
	POP	B
	POP	B
	POP	B
	SHLD	.m
	LHLD	.m
	PUSH	H
	LHLD	.n
	PUSH	H
	CALL	.t
	POP	B
	POP	B
.fd:	LXI	H,80
	DAD	SP
	SPHL
	RET
.gd:	DW	0

.t:	LXI	H,2
	DAD	SP
	CALL	h.
	PUSH	H
	LXI	H,6
	DAD	SP
	CALL	h.
	CALL	s.
	SHLD	.gd
	LHLD	.l
	CALL	c.not
	JZ	.hd
	LDA	.k
	CALL	c.sxt
	PUSH	H
	LHLD	.gd
	PUSH	H
	CALL	.u
	POP	B
	POP	B
.hd:	DS	0
.id:	LHLD	.gd
	DCX	H
	SHLD	.gd
	INX	H
	MOV	A,H
	ORA	L
	JZ	.jd
	LXI	H,4
	DAD	SP
	PUSH	H
	CALL	h.
	INX	H
	CALL	q.
	DCX	H
	CALL	g.
	PUSH	H
	CALL	.p
	POP	B
	LHLD	.h
	DCX	H
	SHLD	.h
	JMP	.id
.jd:	LHLD	.l
	MOV	A,H
	ORA	L
	JZ	.kd
	LXI	H,32
	PUSH	H
	LXI	H,0
	PUSH	H
	CALL	.u
	POP	B
	POP	B
.kd:	RET

.u:	DS	0
.ld:	LXI	H,2
	DAD	SP
	CALL	h.
	XCHG
	LHLD	.h
	CALL	c.lt
	JZ	.md
	LXI	H,4
	DAD	SP
	CALL	h.
	PUSH	H
	CALL	.p
	POP	B
	LHLD	.h
	DCX	H
	SHLD	.h
	JMP	.ld
.md:	RET

.v:	LXI	H,2
	DAD	SP
	CALL	h.
	LXI	D,9
	CALL	c.ge
	JZ	.nd
	LXI	H,48
	JMP	.od
.nd:	LXI	H,55
.od:	XCHG
	LXI	H,2
	DAD	SP
	CALL	h.
	DAD	D
	RET

main:	CALL	prnt_1
	LXI	H,.c+1
	PUSH	H
	CALL	prnt_2
	POP	B
	RET
.c:
	DB	0
	DB	'Hi, sailor. New in town?'
	DB	10
	DB	0
$END	DS	0
	END	$INIT
