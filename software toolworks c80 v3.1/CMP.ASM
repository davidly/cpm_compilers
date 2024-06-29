;C/80 Compiler 3.0a (12/6/83) - (c) 1983 The Software Toolworks

	XTEXT A:CLIBRARY.ASM
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
	CALL	h.##
	PUSH	H
	CALL	format
	POP	B

;#asm
@prnt@: DS	0
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
	CALL	h.##
	MOV	A,L
	STA	.f
	LDA	.f
	CALL	c.sxt##
	PUSH	H
	LHLD	.d
	DCX	H
	DCX	H
	SHLD	.d
	CALL	h.##
	PUSH	H
	CALL	fformat
	POP	B
	POP	B
;#asm
	JMP	@prnt@
;#endasm
	RET

prnt_4:	LHLD	.d
	DCX	H
	DCX	H
	SHLD	.d
	CALL	h.##
	SHLD	.g
	LHLD	.g
	PUSH	H
	LHLD	.d
	DCX	H
	DCX	H
	SHLD	.d
	CALL	h.##
	PUSH	H
	CALL	sformat
	POP	B
	POP	B
;#asm
	JMP	@prnt@
;#endasm
	RET

format:	LXI	H,0
	PUSH	H
	LXI	H,4
	DAD	SP
	CALL	h.##
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
	CALL	h.##
	SHLD	.e
	CALL	.o
	RET

sformat:	LXI	H,4
	DAD	SP
	CALL	h.##
	SHLD	.g
	LXI	H,-2
	PUSH	H
	LXI	H,4
	DAD	SP
	CALL	h.##
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
	CALL	c.sxt##
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
	CALL	c.sxt##
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
.lb:	DW	0

printf:	LXI	H,2
	DAD	SP
	PUSH	H
	LHLD	.d
	CALL	q.
	LHLD	.d
	DCX	H
	DCX	H
	SHLD	.d
.mb:	LXI	H,0
	SHLD	.i
	SHLD	.hb
	LXI	H,-1
	SHLD	.ib
	LHLD	.e
	INX	H
	SHLD	.e
	CALL	g.
	SHLD	.j
	CALL	c.not
	JZ	.nb
	RET
.nb:	LXI	H,32
	MOV	A,L
	STA	.k
	LHLD	.j
	LXI	D,-45
	DAD	D
	CALL	c.not
	SHLD	.l
	MOV	A,H
	ORA	L
	JZ	.ob
	LHLD	.e
	INX	H
	SHLD	.e
	DCX	H
	CALL	g.
	SHLD	.j
.ob:	LHLD	.j
	LXI	D,-48
	DAD	D
	MOV	A,H
	ORA	L
	JNZ	.pb
	LXI	H,48
	MOV	A,L
	STA	.k
	LHLD	.e
	INX	H
	SHLD	.e
	DCX	H
	CALL	g.
	SHLD	.j
.pb:	CALL	.q
	SHLD	.h
	LHLD	.j
	LXI	D,-46
	DAD	D
	MOV	A,H
	ORA	L
	JNZ	.qb
	LHLD	.e
	INX	H
	SHLD	.e
	CALL	.q
	SHLD	.i
	SHLD	.ib
.qb:	LHLD	.e
	INX	H
	SHLD	.e
	DCX	H
	CALL	g.
	SHLD	.j
	LXI	D,-115
	DAD	D
	CALL	e.0
	JZ	.sb
	LHLD	.i
	LXI	D,7
	CALL	c.lt
.sb:	CALL	e.0
	JZ	.rb
	LXI	H,7
	SHLD	.i
.rb:	LHLD	.j
	JMP	.ub
.vb:	LXI	H,2
	DAD	SP
	PUSH	H
	CALL	h.##
	DCX	H
	DCX	H
	CALL	q.
	SHLD	.kb
	LHLD	.kb
	PUSH	H
	LHLD	.kb
	INX	H
	PUSH	H
	CALL	.t
	POP	B
	POP	B
	JMP	.tb
.wb:	LXI	H,2
	DAD	SP
	PUSH	H
	CALL	h.##
	DCX	H
	DCX	H
	CALL	q.
	CALL	h.##
	PUSH	H
	LXI	H,10
	PUSH	H
	CALL	.r
	POP	B
	POP	B
	JMP	.tb
.xb:	LXI	H,8
	SHLD	.hb
	JMP	.yb
.zb:	LXI	H,10
	SHLD	.hb
	JMP	.yb
.ac:	LXI	H,16
	SHLD	.hb
.yb:	LXI	H,2
	DAD	SP
	PUSH	H
	CALL	h.##
	DCX	H
	DCX	H
	CALL	q.
	CALL	h.##
	SHLD	.jb
	LHLD	.jb
	PUSH	H
	LHLD	.hb
	PUSH	H
	CALL	.s
	POP	B
	POP	B
	JMP	.tb
.bc:	LXI	H,2
	DAD	SP
	PUSH	H
	CALL	h.##
	DCX	H
	DCX	H
	CALL	q.
	CALL	h.##
	SHLD	.kb
	SHLD	.lb
.ec:	LHLD	.lb
	INX	H
	SHLD	.lb
	DCX	H
	MOV	A,M
	ORA	A
	JZ	.dc
	JMP	.ec
.dc:	LHLD	.lb
	DCX	H
	SHLD	.lb
	PUSH	H
	LHLD	.kb
	CALL	s.
	XCHG
	LHLD	.i
	CALL	c.gt
	JZ	.gc
	LHLD	.i
.gc:	CALL	e.0
	JZ	.fc
	LHLD	.kb
	XCHG
	LHLD	.i
	DAD	D
	SHLD	.lb
.fc:	LHLD	.kb
	PUSH	H
	LHLD	.lb
	PUSH	H
	CALL	.t
	POP	B
	POP	B
	JMP	.tb
.hc:	RET
.ic:	LHLD	.j
	PUSH	H
	CALL	.p
	POP	B
	CALL	.o
	JMP	.mb
	JMP	.tb
.ub:	CALL	.switch
	DW	.vb,99
	DW	.wb,100
	DW	.xb,111
	DW	.zb,117
	DW	.ac,120
	DW	.bc,115
	DW	.hc,0
	DW	0
	JMP	.ic
.tb:	CALL	.o
	RET
.jc:	DW	0

.q:	LHLD	.jc
	PUSH	H
	LXI	H,0
	SHLD	.jc
.mc:	LHLD	.e
	CALL	g.
	SHLD	.j
	LXI	D,48
	CALL	c.le
	JZ	.nc
	LHLD	.j
	LXI	D,57
	CALL	c.ge
.nc:	CALL	e.0
	JZ	.lc
	LHLD	.jc
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
	SHLD	.jc
	JMP	.mc
.lc:	LHLD	.jc
.oc:	XCHG
	POP	H
	SHLD	.jc
	XCHG
	RET
.pc:	DW	0
.qc:	DW	0

.w:	LXI	H,2
	DAD	SP
	CALL	h.##
	SHLD	.pc
	LXI	H,4
	DAD	SP
	CALL	h.##
	SHLD	.qc
.tc:	LXI	H,6
	DAD	SP
	PUSH	H
	CALL	h.##
	DCX	H
	CALL	q.
	PUSH	H
	LHLD	.pc
	LXI	D,-10
	DAD	D
	CALL	c.not
	JZ	.uc
	LHLD	.qc
	XCHG
	LXI	H,10
	CALL	c.udv
	XCHG
	JMP	.vc
.uc:	LHLD	.pc
	DCX	H
	PUSH	H
	LHLD	.qc
	CALL	a.
.vc:	PUSH	H
	CALL	.v
	POP	B
	POP	D
	MOV	A,L
	STAX	D
	LHLD	.pc
	LXI	D,-8
	DAD	D
	CALL	c.not
	JZ	.wc
	LHLD	.qc
	XCHG
	LXI	H,3
	CALL	c.usr
	JMP	.xc
.wc:	LHLD	.pc
	LXI	D,-10
	DAD	D
	CALL	c.not
	JZ	.yc
	LHLD	.qc
	XCHG
	LXI	H,10
	CALL	c.udv
	JMP	.zc
.yc:	LHLD	.qc
	XCHG
	LXI	H,4
	CALL	c.usr
.zc:	DS	0
.xc:	SHLD	.qc
.rc:	LHLD	.qc
	MOV	A,H
	ORA	L
	JNZ	.tc
.sc:	LXI	H,6
	DAD	SP
	CALL	h.##
	RET
.ad:	DW	0

.r:	LXI	H,-80
	DAD	SP
	SPHL
	LXI	H,84
	DAD	SP
	CALL	h.##
	LXI	D,0
	CALL	c.gt
	JZ	.bd
	LXI	H,84
	DAD	SP
	CALL	h.##
	CALL	c.neg
	JMP	.cd
.bd:	LXI	H,84
	DAD	SP
	CALL	h.##
.cd:	SHLD	.ad
	LXI	H,0
	DAD	SP
	LXI	D,80
	DAD	D
	SHLD	.n
	PUSH	H
	LHLD	.ad
	PUSH	H
	LXI	H,86
	DAD	SP
	CALL	h.##
	PUSH	H
	CALL	.w
	POP	B
	POP	B
	POP	B
	SHLD	.m
	LXI	H,84
	DAD	SP
	CALL	h.##
	LXI	D,32768
	CALL	c.tst
	JC	.dd
	LDA	.k
	CALL	c.sxt##
	LXI	D,-32
	DAD	D
	MOV	A,H
	ORA	L
	JZ	.ed
	LXI	H,45
	PUSH	H
	CALL	.p
	POP	B
	LHLD	.h
	DCX	H
	SHLD	.h
	JMP	.fd
.ed:	LHLD	.m
	DCX	H
	SHLD	.m
	MVI	M,45
.fd:	DS	0
.dd:	LHLD	.m
	PUSH	H
	LHLD	.n
	PUSH	H
	CALL	.t
	POP	B
	POP	B
.gd:	LXI	H,80
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
	CALL	h.##
	PUSH	H
	LXI	H,86
	DAD	SP
	CALL	h.##
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
.hd:	LXI	H,80
	DAD	SP
	SPHL
	RET
.id:	DW	0

.t:	LXI	H,2
	DAD	SP
	CALL	h.##
	PUSH	H
	LXI	H,6
	DAD	SP
	CALL	h.##
	CALL	s.
	SHLD	.id
	LHLD	.l
	CALL	c.not
	JZ	.jd
	LDA	.k
	CALL	c.sxt##
	PUSH	H
	LHLD	.id
	PUSH	H
	CALL	.u
	POP	B
	POP	B
.jd:	DS	0
.kd:	LHLD	.id
	DCX	H
	SHLD	.id
	INX	H
	MOV	A,H
	ORA	L
	JZ	.ld
	LXI	H,4
	DAD	SP
	PUSH	H
	CALL	h.##
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
	JMP	.kd
.ld:	LHLD	.l
	MOV	A,H
	ORA	L
	JZ	.md
	LXI	H,32
	PUSH	H
	LXI	H,0
	PUSH	H
	CALL	.u
	POP	B
	POP	B
.md:	RET

.u:	DS	0
.nd:	LXI	H,2
	DAD	SP
	CALL	h.##
	XCHG
	LHLD	.h
	CALL	c.lt
	JZ	.od
	LXI	H,4
	DAD	SP
	CALL	h.##
	PUSH	H
	CALL	.p
	POP	B
	LHLD	.h
	DCX	H
	SHLD	.h
	JMP	.nd
.od:	RET

.v:	LXI	H,2
	DAD	SP
	CALL	h.##
	LXI	D,9
	CALL	c.ge
	JZ	.pd
	LXI	H,48
	JMP	.qd
.pd:	LXI	H,55
.qd:	XCHG
	LXI	H,2
	DAD	SP
	CALL	h.##
	DAD	D
	RET
.rd:	DW	0
.sd:	DW	0
.td:	DW	0
.ud:	DW	0
.vd:	DW	1
.wd:	DW	0
.xd:	DW	0
.yd:	DW	-1

main:	LXI	H,2
	DAD	SP
	CALL	h.##
	INX	H
	INX	H
	CALL	h.##
	CALL	g.
	LXI	D,-45
	DAD	D
	CALL	c.not
	JZ	.ae
	LXI	H,2
	DAD	SP
	CALL	h.##
	INX	H
	INX	H
	CALL	h.##
	INX	H
	CALL	g.
	LXI	D,-108
	DAD	D
	CALL	c.not
	JNZ	.be
	LXI	H,2
	DAD	SP
	CALL	h.##
	INX	H
	INX	H
	CALL	h.##
	INX	H
	CALL	g.
	LXI	D,-76
	DAD	D
	CALL	c.not
.be:	CALL	e.0
.ae:	CALL	e.0
	JZ	.zd
	LHLD	.xd
	INX	H
	SHLD	.xd
	DCX	H
	LXI	H,4
	DAD	SP
	PUSH	H
	CALL	h.##
	DCX	H
	CALL	q.
	INX	H
	LXI	H,2
	DAD	SP
	PUSH	H
	CALL	h.##
	INX	H
	INX	H
	CALL	q.
	DCX	H
	DCX	H
.zd:	LXI	H,4
	DAD	SP
	CALL	h.##
	DCX	H
	DCX	H
	DCX	H
	MOV	A,H
	ORA	L
	JZ	.ce
	CALL	prnt_1
	LXI	H,.c+1
	PUSH	H
	CALL	prnt_2
	POP	B
	CALL	exit
.ce:	LXI	H,2
	DAD	SP
	CALL	h.##
	INX	H
	INX	H
	CALL	h.##
	PUSH	H
	CALL	file
	POP	B
	SHLD	.rd
	LXI	H,2
	DAD	SP
	CALL	h.##
	LXI	D,4
	DAD	D
	CALL	h.##
	PUSH	H
	CALL	file
	POP	B
	SHLD	.sd
.de:	LXI	H,1
	MOV	A,H
	ORA	L
	JZ	.ee
	LHLD	.yd
	INX	H
	SHLD	.yd
	LXI	D,-256
	DAD	D
	MOV	A,H
	ORA	L
	JNZ	.fe
	LHLD	.wd
	INX	H
	SHLD	.wd
	DCX	H
	LXI	H,0
	SHLD	.yd
.fe:	LHLD	.rd
	PUSH	H
	CALL	getc
	POP	B
	SHLD	.td
	LHLD	.sd
	PUSH	H
	CALL	getc
	POP	B
	SHLD	.ud
	LHLD	.td
	LXI	D,-10
	DAD	D
	MOV	A,H
	ORA	L
	JNZ	.ge
	LHLD	.vd
	INX	H
	SHLD	.vd
	DCX	H
.ge:	LHLD	.ud
	PUSH	H
	LHLD	.td
	CALL	e.
	JZ	.he
	LHLD	.td
	LXI	D,32768
	CALL	c.tst
	JC	.ie
	LHLD	.xd
	LXI	D,32766
	CALL	c.tst
	JC	.je
	CALL	prnt_1
	LXI	H,.c+30
	PUSH	H
	CALL	prnt_2
	POP	B
.je:	CALL	exit
.ie:	JMP	.de
.he:	LHLD	.td
	LXI	D,32768
	CALL	c.tst
	JC	.ke
	CALL	prnt_1
	LXI	H,.c+52
	PUSH	H
	LXI	H,4
	DAD	SP
	CALL	h.##
	INX	H
	INX	H
	CALL	h.##
	PUSH	H
	CALL	prnt_2
	POP	B
	POP	B
	CALL	exit
.ke:	LHLD	.ud
	LXI	D,32768
	CALL	c.tst
	JC	.le
	CALL	prnt_1
	LXI	H,.c+52
	PUSH	H
	LXI	H,4
	DAD	SP
	CALL	h.##
	LXI	D,4
	DAD	D
	CALL	h.##
	PUSH	H
	CALL	prnt_2
	POP	B
	POP	B
	CALL	exit
.le:	LHLD	.xd
	MOV	A,H
	ORA	L
	JZ	.me
	CALL	prnt_1
	LXI	H,.c+68
	PUSH	H
	LXI	H,4
	DAD	SP
	CALL	h.##
	INX	H
	INX	H
	CALL	h.##
	PUSH	H
	LHLD	.yd
	PUSH	H
	LHLD	.wd
	PUSH	H
	LHLD	.vd
	PUSH	H
	LHLD	.td
	PUSH	H
	LXI	H,14
	DAD	SP
	CALL	h.##
	LXI	D,4
	DAD	D
	CALL	h.##
	PUSH	H
	LHLD	.ud
	PUSH	H
	CALL	prnt_2
	XCHG
	LXI	H,16
	DAD	SP
	SPHL
	XCHG
	LXI	H,2
	SHLD	.xd
	JMP	.de
.me:	CALL	prnt_1
	LXI	H,.c+113
	PUSH	H
	LHLD	.yd
	PUSH	H
	LHLD	.wd
	PUSH	H
	LHLD	.vd
	PUSH	H
	CALL	prnt_2
	POP	B
	POP	B
	POP	B
	POP	B
	CALL	exit
	JMP	.de
.ee:	RET
.ne:	DW	0

file:	LHLD	.ne
	PUSH	H
	LXI	H,4
	DAD	SP
	CALL	h.##
	PUSH	H
	LXI	H,.c+163
	PUSH	H
	CALL	fopen
	POP	B
	POP	B
	SHLD	.ne
	LHLD	.ne
	LXI	D,32767
	CALL	c.tst
	JNC	.oe
	LHLD	.ne
.pe:	XCHG
	POP	H
	SHLD	.ne
	XCHG
	RET
.oe:	CALL	prnt_1
	LXI	H,.c+166
	PUSH	H
	LXI	H,6
	DAD	SP
	CALL	h.##
	PUSH	H
	CALL	prnt_2
	POP	B
	POP	B
	CALL	exit
	JMP	.pe
.c:
	DB	0
	DB	'Usage: cmp [-l] file1 file2'
	DB	10
	DB	0
	DB	'Files are identical.'
	DB	10
	DB	0
	DB	'%s is shorter.'
	DB	10
	DB	0
	DB	'%s char %d block %d line %d = %3o; %s = %3o'
	DB	10
	DB	0
	DB	'Files differ at character %d, block %d, line %d.'
	DB	10
	DB	0
	DB	'rb'
	DB	0
	DB	'Can'
	DB	39
	DB	't open: %s'
	DB	10
	DB	0
$END	DS	0
	END	$INIT
