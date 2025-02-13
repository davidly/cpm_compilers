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
logging:	DW	0
.pd:	DW	0
.qd:	DW	0

memset_:	DCX	SP
	LHLD	.qd
	PUSH	H
	LHLD	.pd
	PUSH	H
	LXI	H,11
	DAD	SP
	CALL	h.
	SHLD	.pd
	LXI	H,4
	DAD	SP
	PUSH	H
	LXI	H,11
	DAD	SP
	CALL	h.
	MVI	H,0
	POP	D
	MOV	A,L
	STAX	D
	LXI	H,11
	DAD	SP
	CALL	h.
	PUSH	H
	LXI	H,0
	CALL	e.
	JZ	.rd
	CALL	prnt_1
	LXI	H,.c+1
	PUSH	H
	CALL	prnt_2
	POP	B
	LXI	H,1
	PUSH	H
	CALL	exit
	POP	B
.rd:	LHLD	logging
	MOV	A,H
	ORA	L
	JZ	.sd
	CALL	prnt_1
	LXI	H,.c+35
	PUSH	H
	LXI	H,13
	DAD	SP
	CALL	h.
	PUSH	H
	LXI	H,13
	DAD	SP
	CALL	h.
	PUSH	H
	LXI	H,10
	DAD	SP
	CALL	g.
	PUSH	H
	LXI	H,15
	DAD	SP
	CALL	h.
	PUSH	H
	CALL	prnt_2
	POP	B
	POP	B
	POP	B
	POP	B
	POP	B
.sd:	LXI	H,0
	SHLD	.qd
.vd:	LXI	H,7
	DAD	SP
	CALL	h.
	XCHG
	LHLD	.qd
	CALL	c.gt
	JZ	.ud
	JMP	.wd
.td:	LHLD	.qd
	INX	H
	SHLD	.qd
	DCX	H
	JMP	.vd
.wd:	LHLD	.pd
	INX	H
	SHLD	.pd
	DCX	H
	PUSH	H
	LXI	H,6
	DAD	SP
	CALL	g.
	POP	D
	MOV	A,L
	STAX	D
	JMP	.td
.ud:	LXI	H,11
	DAD	SP
	CALL	h.
.xd:	XCHG
	POP	H
	SHLD	.pd
	POP	H
	SHLD	.qd
	INX	SP
	XCHG
	RET
.yd:	DW	0
.zd:	DW	0

chkmem:	DCX	SP
	LHLD	.zd
	PUSH	H
	LHLD	.yd
	PUSH	H
	LXI	H,11
	DAD	SP
	CALL	h.
	SHLD	.yd
	LXI	H,4
	DAD	SP
	PUSH	H
	LXI	H,11
	DAD	SP
	CALL	h.
	MVI	H,0
	POP	D
	MOV	A,L
	STAX	D
	LXI	H,11
	DAD	SP
	CALL	h.
	PUSH	H
	LXI	H,0
	CALL	e.
	JZ	.ae
	CALL	prnt_1
	LXI	H,.c+70
	PUSH	H
	CALL	prnt_2
	POP	B
	LXI	H,1
	PUSH	H
	CALL	exit
	POP	B
.ae:	LXI	H,0
	SHLD	.zd
.de:	LXI	H,7
	DAD	SP
	CALL	h.
	XCHG
	LHLD	.zd
	CALL	c.gt
	JZ	.ce
	JMP	.ee
.be:	LHLD	.zd
	INX	H
	SHLD	.zd
	DCX	H
	JMP	.de
.ee:	LHLD	.yd
	CALL	g.
	PUSH	H
	LXI	H,6
	DAD	SP
	CALL	g.
	CALL	n.
	JZ	.fe
	CALL	prnt_1
	LXI	H,.c+104
	PUSH	H
	LXI	H,13
	DAD	SP
	CALL	h.
	PUSH	H
	LXI	H,13
	DAD	SP
	CALL	h.
	PUSH	H
	LXI	H,13
	DAD	SP
	CALL	h.
	PUSH	H
	LHLD	.yd
	CALL	g.
	PUSH	H
	CALL	prnt_2
	POP	B
	POP	B
	POP	B
	POP	B
	POP	B
	LXI	H,1
	PUSH	H
	CALL	exit
	POP	B
.fe:	LHLD	.yd
	INX	H
	SHLD	.yd
	DCX	H
	JMP	.be
.ce:	DS	0
.ge:	POP	H
	SHLD	.yd
	POP	H
	SHLD	.zd
	INX	SP
	RET

malloc:	LXI	H,2
	DAD	SP
	CALL	h.
	PUSH	H
	CALL	alloc
	POP	B
	RET
.he:	DW	0
.ie:	DW	0

calloc:	LHLD	.ie
	PUSH	H
	LHLD	.he
	PUSH	H
	LXI	H,8
	DAD	SP
	CALL	h.
	XCHG
	LXI	H,6
	DAD	SP
	CALL	h.
	CALL	c.mult
	SHLD	.he
	LHLD	.he
	PUSH	H
	CALL	malloc
	POP	B
	SHLD	.ie
	LHLD	.ie
	PUSH	H
	LXI	H,0
	CALL	n.
	JZ	.je
	LHLD	.ie
	PUSH	H
	LXI	H,0
	PUSH	H
	LHLD	.he
	PUSH	H
	CALL	memset_
	POP	B
	POP	B
	POP	B
.je:	LHLD	.ie
.ke:	XCHG
	POP	H
	SHLD	.he
	POP	H
	SHLD	.ie
	XCHG
	RET
.le:	DW	0
.me:	DW	0
.ne:	DW	0
.oe:	DW	0
.pe:	DW	0

main:	LXI	H,-132
	DAD	SP
	SPHL
	LHLD	.pe
	PUSH	H
	LHLD	.oe
	PUSH	H
	LHLD	.ne
	PUSH	H
	LHLD	.me
	PUSH	H
	LHLD	.le
	PUSH	H
	LXI	H,146
	DAD	SP
	CALL	h.
	LXI	D,1
	CALL	c.lt
	SHLD	logging
	LXI	H,144
	DAD	SP
	CALL	h.
	CALL	h.
	SHLD	.pe
	LXI	H,0
	SHLD	.oe
.se:	LHLD	.oe
	LXI	D,10
	CALL	c.gt
	JZ	.re
	JMP	.te
.qe:	LHLD	.oe
	INX	H
	SHLD	.oe
	DCX	H
	JMP	.se
.te:	LHLD	logging
	MOV	A,H
	ORA	L
	JZ	.ue
	CALL	prnt_1
	LXI	H,.c+156
	PUSH	H
	CALL	prnt_2
	POP	B
.ue:	LXI	H,0
	SHLD	.le
.xe:	LHLD	.le
	LXI	D,66
	CALL	c.gt
	JZ	.we
	JMP	.ye
.ve:	LHLD	.le
	INX	H
	SHLD	.le
	DCX	H
	JMP	.xe
.ye:	LHLD	.le
	LXI	D,10
	CALL	c.mult
	LXI	D,8
	DAD	D
	SHLD	.me
	LHLD	.me
	LXI	D,5
	DAD	D
	SHLD	.ne
	LHLD	logging
	MOV	A,H
	ORA	L
	JZ	.ze
	CALL	prnt_1
	LXI	H,.c+171
	PUSH	H
	LHLD	.le
	PUSH	H
	LHLD	.me
	PUSH	H
	CALL	prnt_2
	POP	B
	POP	B
	POP	B
.ze:	LHLD	.ne
	PUSH	H
	LXI	H,1
	PUSH	H
	CALL	calloc
	POP	B
	POP	B
	SHLD	.pe
	LHLD	.pe
	PUSH	H
	LXI	H,0
	PUSH	H
	LHLD	.ne
	PUSH	H
	CALL	chkmem
	POP	B
	POP	B
	POP	B
	LHLD	.pe
	PUSH	H
	LXI	H,204
	PUSH	H
	LHLD	.ne
	PUSH	H
	CALL	memset_
	POP	B
	POP	B
	POP	B
	LHLD	.le
	DAD	H
	XCHG
	LXI	H,10
	DAD	SP
	DAD	D
	PUSH	H
	LHLD	.me
	PUSH	H
	CALL	malloc
	POP	B
	CALL	q.
	LHLD	.le
	DAD	H
	XCHG
	LXI	H,10
	DAD	SP
	DAD	D
	CALL	h.
	PUSH	H
	LXI	H,170
	PUSH	H
	LHLD	.me
	PUSH	H
	CALL	memset_
	POP	B
	POP	B
	POP	B
	LHLD	.pe
	PUSH	H
	LXI	H,204
	PUSH	H
	LHLD	.ne
	PUSH	H
	CALL	chkmem
	POP	B
	POP	B
	POP	B
	LHLD	.pe
	PUSH	H
	CALL	free
	POP	B
	JMP	.ve
.we:	LHLD	logging
	MOV	A,H
	ORA	L
	JZ	.af
	CALL	prnt_1
	LXI	H,.c+187
	PUSH	H
	CALL	prnt_2
	POP	B
.af:	LXI	H,0
	SHLD	.le
.df:	LHLD	.le
	LXI	D,66
	CALL	c.gt
	JZ	.cf
	JMP	.ef
.bf:	LHLD	.le
	INX	H
	INX	H
	SHLD	.le
	JMP	.df
.ef:	LHLD	.le
	LXI	D,10
	CALL	c.mult
	LXI	D,8
	DAD	D
	SHLD	.me
	LHLD	.me
	INX	H
	INX	H
	INX	H
	SHLD	.ne
	LHLD	logging
	MOV	A,H
	ORA	L
	JZ	.ff
	CALL	prnt_1
	LXI	H,.c+171
	PUSH	H
	LHLD	.le
	PUSH	H
	LHLD	.me
	PUSH	H
	CALL	prnt_2
	POP	B
	POP	B
	POP	B
.ff:	LHLD	.ne
	PUSH	H
	LXI	H,1
	PUSH	H
	CALL	calloc
	POP	B
	POP	B
	SHLD	.pe
	LHLD	.pe
	PUSH	H
	LXI	H,0
	PUSH	H
	LHLD	.ne
	PUSH	H
	CALL	chkmem
	POP	B
	POP	B
	POP	B
	LHLD	.pe
	PUSH	H
	LXI	H,204
	PUSH	H
	LHLD	.ne
	PUSH	H
	CALL	memset_
	POP	B
	POP	B
	POP	B
	LHLD	.le
	DAD	H
	XCHG
	LXI	H,10
	DAD	SP
	DAD	D
	CALL	h.
	PUSH	H
	LXI	H,170
	PUSH	H
	LHLD	.me
	PUSH	H
	CALL	chkmem
	POP	B
	POP	B
	POP	B
	LHLD	.le
	DAD	H
	XCHG
	LXI	H,10
	DAD	SP
	DAD	D
	CALL	h.
	PUSH	H
	LXI	H,255
	PUSH	H
	LHLD	.me
	PUSH	H
	CALL	memset_
	POP	B
	POP	B
	POP	B
	LHLD	.le
	DAD	H
	XCHG
	LXI	H,10
	DAD	SP
	DAD	D
	CALL	h.
	PUSH	H
	CALL	free
	POP	B
	LHLD	.pe
	PUSH	H
	LXI	H,204
	PUSH	H
	LHLD	.ne
	PUSH	H
	CALL	chkmem
	POP	B
	POP	B
	POP	B
	LHLD	.pe
	PUSH	H
	CALL	free
	POP	B
	JMP	.bf
.cf:	LHLD	logging
	MOV	A,H
	ORA	L
	JZ	.gf
	CALL	prnt_1
	LXI	H,.c+213
	PUSH	H
	CALL	prnt_2
	POP	B
.gf:	LXI	H,1
	SHLD	.le
.jf:	LHLD	.le
	LXI	D,66
	CALL	c.gt
	JZ	.if
	JMP	.kf
.hf:	LHLD	.le
	INX	H
	INX	H
	SHLD	.le
	JMP	.jf
.kf:	LHLD	.le
	LXI	D,10
	CALL	c.mult
	LXI	D,8
	DAD	D
	SHLD	.me
	LHLD	.me
	LXI	D,7
	DAD	D
	SHLD	.ne
	LHLD	logging
	MOV	A,H
	ORA	L
	JZ	.lf
	CALL	prnt_1
	LXI	H,.c+171
	PUSH	H
	LHLD	.le
	PUSH	H
	LHLD	.me
	PUSH	H
	CALL	prnt_2
	POP	B
	POP	B
	POP	B
.lf:	LHLD	.ne
	PUSH	H
	LXI	H,1
	PUSH	H
	CALL	calloc
	POP	B
	POP	B
	SHLD	.pe
	LHLD	.pe
	PUSH	H
	LXI	H,0
	PUSH	H
	LHLD	.ne
	PUSH	H
	CALL	chkmem
	POP	B
	POP	B
	POP	B
	LHLD	.pe
	PUSH	H
	LXI	H,204
	PUSH	H
	LHLD	.ne
	PUSH	H
	CALL	memset_
	POP	B
	POP	B
	POP	B
	LHLD	.le
	DAD	H
	XCHG
	LXI	H,10
	DAD	SP
	DAD	D
	CALL	h.
	PUSH	H
	LXI	H,170
	PUSH	H
	LHLD	.me
	PUSH	H
	CALL	chkmem
	POP	B
	POP	B
	POP	B
	LHLD	.le
	DAD	H
	XCHG
	LXI	H,10
	DAD	SP
	DAD	D
	CALL	h.
	PUSH	H
	LXI	H,255
	PUSH	H
	LHLD	.me
	PUSH	H
	CALL	memset_
	POP	B
	POP	B
	POP	B
	LHLD	.le
	DAD	H
	XCHG
	LXI	H,10
	DAD	SP
	DAD	D
	CALL	h.
	PUSH	H
	CALL	free
	POP	B
	LHLD	.pe
	PUSH	H
	LXI	H,204
	PUSH	H
	LHLD	.ne
	PUSH	H
	CALL	chkmem
	POP	B
	POP	B
	POP	B
	LHLD	.pe
	PUSH	H
	CALL	free
	POP	B
	JMP	.hf
.if:	JMP	.qe
.re:	CALL	prnt_1
	LXI	H,.c+236
	PUSH	H
	CALL	prnt_2
	POP	B
	LXI	H,0
.mf:	XCHG
	POP	H
	SHLD	.le
	POP	H
	SHLD	.me
	POP	H
	SHLD	.ne
	POP	H
	SHLD	.oe
	POP	H
	SHLD	.pe
	LXI	H,132
	DAD	SP
	SPHL
	XCHG
	RET
.nf:	DW	0,-1
.of:	DW	0
.pf:	DW	0
.qf:	DW	0

alloc:	LXI	H,2
	DAD	SP
	PUSH	H
	CALL	h.
	INX	H
	INX	H
	CALL	q.
	LXI	D,4
	CALL	c.ugt
	JZ	.rf
	LXI	H,2
	DAD	SP
	MVI	M,4
	INX	H
	MVI	M,0
.rf:	DS	0
.uf:	LXI	H,.nf
	SHLD	.of
.xf:	LHLD	.of
	INX	H
	INX	H
	CALL	h.
	SHLD	.pf
	INX	H
	CALL	e.0
	JZ	.wf
	JMP	.yf
.vf:	LHLD	.pf
	SHLD	.of
	JMP	.xf
.yf:	LHLD	.pf
	CALL	h.
	PUSH	H
	LXI	H,4
	DAD	SP
	CALL	h.
	POP	D
	CALL	c.uge
	JZ	.zf
	LXI	H,2
	DAD	SP
	CALL	h.
	LXI	D,4
	DAD	D
	PUSH	H
	LHLD	.pf
	CALL	h.
	POP	D
	CALL	c.ule
	JZ	.ag
	LHLD	.of
	INX	H
	INX	H
	PUSH	H
	LHLD	.pf
	XCHG
	LXI	H,4
	DAD	SP
	CALL	h.
	DAD	D
	CALL	q.
	SHLD	.of
	LHLD	.of
	PUSH	H
	LHLD	.pf
	CALL	h.
	PUSH	H
	LXI	H,6
	DAD	SP
	CALL	h.
	CALL	s.
	CALL	q.
	LHLD	.pf
	PUSH	H
	LXI	H,4
	DAD	SP
	CALL	h.
	CALL	q.
.ag:	LHLD	.of
	INX	H
	INX	H
	PUSH	H
	LHLD	.pf
	INX	H
	INX	H
	CALL	h.
	CALL	q.
	LHLD	.pf
	INX	H
	INX	H
	RET
.zf:	JMP	.vf
.wf:	LXI	H,2
	DAD	SP
	CALL	h.
	LXI	D,1024
	CALL	c.ugt
	JZ	.cg
	LXI	H,1024
	JMP	.dg
.cg:	LXI	H,2
	DAD	SP
	CALL	h.
.dg:	SHLD	.qf
	PUSH	H
	CALL	sbrk
	POP	B
	SHLD	.of
	INX	H
	CALL	c.not
	JZ	.bg
	LXI	H,-1
	RET
.bg:	LHLD	.of
	PUSH	H
	LHLD	.qf
	CALL	q.
	LHLD	.of
	INX	H
	INX	H
	PUSH	H
	CALL	free
	POP	B
	JMP	.uf
.tf:	RET
.eg:	DW	0
.fg:	DW	0

free:	LXI	H,2
	DAD	SP
	PUSH	H
	CALL	h.
	DCX	H
	DCX	H
	CALL	q.
	LXI	H,.nf
	SHLD	.eg
.ig:	LHLD	.eg
	INX	H
	CALL	e.0
	JZ	.hg
	JMP	.jg
.gg:	LHLD	.fg
	SHLD	.eg
	JMP	.ig
.jg:	LHLD	.eg
	INX	H
	INX	H
	CALL	h.
	SHLD	.fg
	PUSH	H
	LXI	H,4
	DAD	SP
	CALL	h.
	POP	D
	CALL	c.ugt
	JZ	.kg
	LXI	H,2
	DAD	SP
	CALL	h.
	CALL	h.
	XCHG
	LXI	H,2
	DAD	SP
	CALL	h.
	DAD	D
	PUSH	H
	LHLD	.fg
	CALL	e.
	JZ	.lg
	LXI	H,2
	DAD	SP
	CALL	h.
	PUSH	H
	CALL	h.
	PUSH	H
	LHLD	.fg
	CALL	h.
	POP	D
	DAD	D
	CALL	q.
	LHLD	.fg
	INX	H
	INX	H
	CALL	h.
	SHLD	.fg
.lg:	LHLD	.eg
	CALL	h.
	XCHG
	LHLD	.eg
	DAD	D
	PUSH	H
	LXI	H,4
	DAD	SP
	CALL	h.
	CALL	e.
	JZ	.mg
	LHLD	.eg
	PUSH	H
	CALL	h.
	PUSH	H
	LXI	H,6
	DAD	SP
	CALL	h.
	CALL	h.
	POP	D
	DAD	D
	CALL	q.
	LXI	H,2
	DAD	SP
	PUSH	H
	LHLD	.eg
	CALL	q.
.mg:	LHLD	.eg
	INX	H
	INX	H
	PUSH	H
	LXI	H,4
	DAD	SP
	CALL	h.
	CALL	q.
	LXI	H,2
	DAD	SP
	CALL	h.
	INX	H
	INX	H
	PUSH	H
	LHLD	.fg
	CALL	q.
	RET
.kg:	JMP	.gg
.hg:	RET
.c:
	DB	0
	DB	'request to memset a null pointer'
	DB	10
	DB	0
	DB	'  memset p %u, v %d, val %x, c %d'
	DB	10
	DB	0
	DB	'request to chkmem a null pointer'
	DB	10
	DB	0
	DB	'memory isn'
	DB	39
	DB	't as expected! p %u, v %d, c %d, *pc %d'
	DB	10
	DB	0
	DB	'in alloc mode'
	DB	10
	DB	0
	DB	'  i, cb: %d %d'
	DB	10
	DB	0
	DB	'in free mode, even first'
	DB	10
	DB	0
	DB	'in free mode, now odd'
	DB	10
	DB	0
	DB	'success'
	DB	10
	DB	0
$END	DS	0
	END	$INIT
