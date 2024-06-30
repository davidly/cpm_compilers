bdos	equ	5
cr	equ	0dh
lf	equ	0ah
;	MATHS ROUTINES FOR NIGHT PARROT PASCAL
;
;	(C) NIGHT PARROT JUNE 83
;	base	d
;	option	mult16$,p$muli,itoi
MULT16$:
MULT16:		;MULTIPLY 2 16 BIT VALUES
		;GIVING A 16 BIT RESULT 
		;THE VALUES ARE IN DE AND HL
;
;	REGISTER USE:
;	HL CONTAINS RESULT BEING FORMED
;	B CONTAINS ITERATION COUNTER
;	A AND C CONTAIN OPERAND BEING SHIFTED
;	DE CONTAIN THE OTHER OPERAND
;
	LD	B,17
	LD	A,H	;A IS MORE SIG BYTE 
	LD	C,L
	LD	HL,0
;	START OF LAST BIT WAS ZERO LOOP
MLT1:	SRA	H	;SHIFT 32 BIT WORK AREA 
	RR	L
	RRA		;TOP BIT DOESN'T MATTER	
	RR	C
	JP	C,MLT5	;ON BOTTOM BIT WAS SET
	DJNZ	MLT1
;
;	40 CLOCK CYCLES PER LOOP
;
	JR	MLT6	;RETURN WITH RESULT IN HL
;
;	FIRST 1 BIT FOUND
;	SUBTRACT VALUE
;
;	
MLT3:	SRA	H	;SHIFT 32 BIT WORK AREA 
	RR	L
	RRA		;TOP BIT FROM RESULT
	RR	C
	JP	NC,MLT4	;ON BOTTOM BIT WAS NOT SET
	DJNZ	MLT3
	JR	MLT6		;RETURN WITH RESULT IN HL a and c
MLT4:	ADD	HL,DE
	DJNZ	MLT1
	JR	MLT6
MLT5:	CCF		;CLEAR CARRY (SET TO GET HERE)
	SBC	HL,DE
	DJNZ	MLT3
MLT6:	RET		;RETURN WITH RESULT IN HL A AND C
;
;
;	TIMING INFO:
;	40*16 CHCLES FOR BASIC LOOP 
;	WITH AN ADDITIONAL 16 TO 26 PER BIT CHANGE
;	= 160US + 5*(0..16) AVERAGE ABOUT 200US (AT 4 MHZ) 
;	option	p$muli,itoi
	label			;1
P$MULI:	ld	a,h
	xor	d
	push	af
	CALL	MULT16
	ld	b,a
	xor	a
	cp	h
	jp	nz,pmuli1
	cp	l
	jp	z,pmuli2
pmuli1:	inc	a		;set carry flag
pmuli2:	ld	e,a
	pop	af
	xor	b
	and	80h
	jp	z,pmuli3	;on no overflow
	ld	a,4
	or	e
	ld	e,a
pmuli3:	LD	H,b
	LD	L,C
	push	de
	pop	af
	RET
;	option	p$divi
;
;		DIVISION ROUTINE
;
;		HL DIV DE
DIV16:	LD	BC,0
	XOR	A
;
;		SCALE DE
;
DIV1:	INC	B
	SBC	HL,DE
	JP	c,DIV2
	SRL	H	;SHIFT 32 BIT WORK AREA 
	RR	L
	RRA		;TOP BIT DOESN'T MATTER	
	RR	C
	JP	DIV1
;
;	hl<0
;
DIV2:	ADD	HL,DE
	JP	C,DIV5	;ON BIT IS  PART OF RESULT
DIV3:	SLA	C
	RLA
	RL	L
	RL	H
	DJNZ	DIV2
	JP	DIV6
;
;	hl>0
;
DIV4:	OR	A
	SBC	HL,DE
	JP	C,DIV3
DIV5:	SLA	C
	RLA
	RL	L
	RL	H
	INC	C
	DJNZ	DIV4
DIV6:	RET	
divby0:	ld	de,divzer
	jp	abort
modby0:	ld	de,modzer
	jp	abort
;
;	p$divi and p$modi
;
	label			;2
P$DIVI:	ld	a,d
	or	e
	jp	z,divby0
	BIT	7,H
	JP	NZ,PDIV2
	BIT	7,D
	JP	NZ,PDIV3
;
;	BOTH POSITIVE
;
PDIV1:	CALL	DIV16
	LD	H,A
	LD	L,C
	DEC	HL
	RET
PDIV2:	PUSH	DE
	CALL	P$NEGI
	POP	DE
	BIT	7,D
	JP	Z,PDIV4
	EX	DE,HL
	PUSH	DE
	CALL	P$NEGI
	POP	DE
	EX	DE,HL
	JP	PDIV1
PDIV3:	EX	DE,HL
	PUSH	DE
	CALL	P$NEGI
	POP	DE
	EX	DE,HL
PDIV4:	CALL	DIV16
	LD	H,A
	LD	L,C
	DEC	HL
	CALL	P$NEGI	
	RET
;
;	option	p$modi
	label			;3
P$MODI:	ld	a,e
	or	d
	jp	z,modby0
	BIT	7,H
	JP	NZ,PMOD2
	BIT	7,D
	JP	NZ,PMOD3
;
;	BOTH POSITIVE
;
PMOD1:	push	de		;save divisor
	CALL	DIV16
	SRA	H
	RR	L
	pop	de
	bit	7,h
	ret	z
	add	hl,de		;adjust remainder
	RET
PMOD2:	PUSH	DE
	CALL	P$NEGI
	POP	DE
	BIT	7,D
	JP	Z,PMOD4
	PUSH	HL
	CALL	NEGI1
	POP	DE
	EX	DE,HL
	JP	PMOD1
PMOD3:	PUSH	HL
	CALL	NEGI1
	POP	DE
	EX	DE,HL
PMOD4:	push	de
	CALL	DIV16
	SRA	H
	RR	L
	pop	de
	bit	7,h
	jp	z,pmod5
	add	hl,de
pmod5:	CALL	P$NEGI	
	RET
;
;	P$NEGI - INTEGER NEGATE
;
;	option	p$negi,p$absi
	label			;4
P$NEGI:	EX	DE,HL
NEGI1:	LD	HL,0
	OR	A
	SBC	HL,DE
	RET
;	option	p$absi
	label			;5
P$ABSI:	pop	bc
	pop	de
	pop	hl		;remove space for result
	BIT	7,d
	JP	NZ,P$absi1
	push	de
	push	bc
	RET
p$absi1:ld	hl,0
	or	a
	sbc	hl,de
	push	hl
	push	bc	
	ret
;
;	p$odd - return true if odd
;
;	option	p$odd
	label			;6
p$odd:	pop	de
	pop	hl
	pop	bc		;space for result
	ld	h,0
	ld	a,1
	and	l
	ld	l,a
	push	hl
	ex	de,hl
	jp	(hl)
;
;	
;	option	p$cmpl
	label			;7
p$cmpl:	push	af	;save length diff
	ld	a,c	;exchange b and c so we can use djnz
	ld	c,b
	ld	b,a
	cp	0
	jp	nz,p$c1	;if b is zero, 256 loops will be performed
	dec	c
p$c1:	ld	a,(de)
	cp	(hl)
	jp	nz,p$c5
	cp	0
	jp	z,p$c5
	inc	de
	inc	hl
	djnz	p$c1
	dec	c
	jp	p,p$c1
;
	pop	af
;	
	cp	0
	ret	z	;equal lengths so equal strings
	jp	p,p$c2	
	ld	a,(de)
	cp	0
	ret
p$c2:	xor	a
	cp	(hl)
	ret
p$c5:	pop	hl	;clear stack
	ret
;
;	p$mvfm - move from stack
;	
;	de points to result
;	bc gives bytes to move
;	option	p$mvfm
	label			;8
p$mvfm:	pop	iy	;return address
	ld	hl,0
	add	hl,sp
	ldir		;move data
	ld	sp,hl	;cut back stack
	push	iy
	ret
;
;	floating point was here - dummy labels to take care
;
	label			;9
	label			;10
	label			;11
	label			;12
	label			;13
	label			;14
	label			;15
	label			;16
	label			;17
;
;	convert value to capitals
;
	label			;18
p$cap:	pop	hl		;return address
	pop	de		;parameter
	pop	bc		;space for result
	ld	a,e
	cp	'a'
	jp	m,p$cap1
	cp	'z'+1
	jp	p,p$cap1
	and	0dfh
p$cap1:	ld	e,a
	push	de
	jp	(hl)
	label			;19 - now in real$
;
;	integer compare routines
;	de contains lhs
;	hl contains rhs
;	return carry set if de>hl
;	       zero set if =
;
;	(*modified 8 nov 85 -
;		now supports do loops too by
;		returning subtract result in hl
	label			;20
p$cmpi:	ld	a,d
	xor	h
	rla
	jp	c,p$cmpi1	;on opposite signs, so may overflow
	sbc	hl,de
	scf
	ret	m
	ccf
	ret
p$cmpi1:ld	a,h
	ccf		;clear carry (must be set to get here)
	sbc	hl,de
	rla		;if h<0, de>hl
	ret
	label		;21
P$DIVc:	ld	a,e
	or	d
	jp	z,divby0
	CALL	DIV16
	LD	H,A
	LD	L,C
	DEC	HL
	RET
	label			;22
P$MODc: ld	a,e
	or	d
	jp	z,modby0
	xor	a
	cp	h
	jr	nz,p$modc1
	cp	l
	ret	z
p$modc1:push	de
	CALL	DIV16
	SRA	H
	RR	L
	pop	de
	bit	7,h
	ret	z
	add	hl,de
	RET
	label			;23 - symmetric difference
;
;	symmetric difference
;
;	returns elements in one set or t'other but not both
;
symdif: call	setpntr
	dec	bc
symdif1:ld	a,(de)
	and	(hl)
	cpl
	push	bc
	ld	b,a
	ld	a,(de)
	or	(hl)
	and	b
	ld	(hl),a
	pop	bc
	inc	de
	inc	hl
	djnz	symdif1
	jp	setret
;
;	add two sets
;
	label			;24 - add sets
adds:	call	setpntr
adds1:	ld	a,(de)
	or	(hl)
	ld	(hl),a
	inc	de
	inc	hl
	djnz	adds1
	jp	setret
;
;	multiply two sets
;
	label			;25 - multiply sets
muls:	call	setpntr
muls1:	ld	a,(de)
	and	(hl)
	ld	(hl),a
	inc	de
	inc	hl
	djnz	muls1
	jp	setret
;
;	subtract sets
;
	label			;26 - subtract sets
subs:	call	setpntr
subs1:	ld	a,(de)
	cpl	
	and	(hl)
	ld	(hl),a
	inc	de
	inc	hl
	djnz	subs1
	jp	setret
;
;	compare sets
;
;	set carry if lhs(hl)>rhs(de)
;	zero if equal
;
	label			;27 - compare sets
cmps:	call	setpntr
	jp	z,cmpso		;on 1 byte sets
cmps1:	ld	a,(de)
	cp	(hl)
	jp	nz,cmps2
	inc	de
	inc	hl
	djnz	cmps1
;
;	sets are equal
;
cmpsr:	pop	de		;return address
	ld	sp,hl		;remove from stack
	ex	de,hl		;return with zero flag
	jp	(hl)
cmps2:	ld	e,(hl)
	ld	c,b
	ld	b,0
	add	hl,bc		;allow for rest of set
	or	a		;clear carry
	cpl
	and	e
	jp	nz,cmpsr
	sub	1			;set carry and non-zero
	jp	cmpsr
cmpso:	ld	a,(de)
	cp	(hl)
	jp	nz,cmps2
	inc	hl
	inc	hl
	cp	a
	jp	cmpsr
;
;	see if in set		;
;
;	hl contains value to look for
;	stack contains set
;
bitmap:	db	80h,40h,20h,10h,8h,4h,2h,1h
	label			;28 - inset
inset:	ex	de,hl
	ld	hl,2
	add	hl,sp		;least sig end of set
	ex	de,hl
	bit	7,h
	jp	m,insetf	;if out of range
	ld	a,l
	srl	h
	rr	l
	srl	h
	rr	l
	srl	h
	rr	l		;now contains byte index
	push	hl
	or	a		;clear carry
	sbc	hl,bc
	jp	p,insete	;on out of range the other way
	pop	hl
	add	hl,de		;byte to inspect
	push	hl
	pop	iy
	and	7
	ld	l,a
	ld	h,0
	push	de
	call	chek2		;check bc at least 2
	ld	de,bitmap
	add	hl,de
	pop	de
	ld	a,(iy+0)
	and	(hl)
	jp	z,insetf
;
;	was in set
;
	ex	de,hl
	add	hl,bc
	pop	de
	ld	sp,hl
	push	de
	ld	hl,1
	ret
insete: pop	hl
insetf:	call	chek2
	ex	de,hl
	add	hl,bc
	pop	de
	ld	sp,hl
	push	de
	ld	hl,0
	ret
;
;	setrange - enter de..hl into the set on the stack
;
	label			;29 set range
setrnge:or	a		;clear carry
	sbc	hl,de		;number of elements to enter-1
	ex	de,hl
	pop	iy		;save return address
setr1:	bit	7,d
	jp	nz,setr2	;on end of range
	call	setbuild	;add hl element to set
	dec	de
	inc	hl
	jp	setr1
setr2:	jp	(iy)
;
;	setbuild - add an element to a set
; 
	label			;30 - ass element to set
	pop	iy		;return address
	call	setbuild
	jp	(iy)
setbuild:push	hl		;save value to add
	push	de		;save for set range (not used on direct call)
	push	iy		;and iy for same reason
	ex	de,hl
	ld	hl,8
	add	hl,sp		;least sig end of set
	ex	de,hl
	bit	7,h
	jp	m,setorng	;if out of range
	ld	a,l		;save value low order
	srl	h		;and divide by 8
	rr	l
	srl	h
	rr	l
 	srl	h
	rr	l		;now contains byte index
	push	hl
	or	a		;clear carry
	sbc	hl,bc		;(bc is set size)
	pop	hl
	jp	p,setorng	;on out of range the other way
	add	hl,de		;byte to inspect
	push	hl
	pop	iy
	and	7
	ld	l,a
	ld	h,0
	ld	de,bitmap
	add	hl,de
	ld	a,(iy+0)
	or	(hl)
	ld	(iy+0),a
	pop	iy
	pop	de		;retrieve de for setrange
	pop	hl		;and hl
	ret
setorng:ld	de,setofl	
	jp	abort
;
;	set up hl and de to point to the two operand on the stack
;	hl points to the rhs
;
setpntr:ld	hl,4		
	add	hl,sp		;start of right hand parameter
	call	chek2
	push	af
	ld	d,h
	ld	e,l
	add	hl,bc		;start of second parameter
	ld	b,c		;ready for djnz
	pop	af		;return flags to caller
	ret
;
;	check bc is 2 or greater
;
chek2:	xor	a
	cp	b
	ret	nz
	inc	a
	cp	c
	ret	nz
	inc	c
	cp	a		;set zero flag to denote =1
	ret
;
;	return fro set operation
;
;	tos gives return address
;	de points to set to return on top of stack
;
setret:	pop	hl
	ex	de,hl
	ld	sp,hl
	ex	de,hl
	jp	(hl)
	label			;31 - call indirect
;
;	hl gives address to call
;
indrcall:jp	(hl) 
;
;	subtract from a set
;
	label			;32 - set subtract
setsub:	ex	de,hl
	ld	hl,2
	add	hl,sp		;least sig end of set
	ex	de,hl
	bit	7,h
	jp	m,setorng	;if out of range
	ld	a,l
	srl	h
	rr	l
	srl	h
	rr	l
	srl	h
	rr	l		;now contains byte index
	push	hl
	or	a		;clear carry
	sbc	hl,bc
	pop	hl
	jp	p,setorng	;on out of range the other way
	add	hl,de		;byte to inspect
	push	hl
	pop	iy
	and	7
	ld	l,a
	ld	h,0
	ld	de,bitmap
	add	hl,de
	ld	a,(iy+0)
	xor	0ffh		;flip all bits
	or	(hl)		;set unwanted bit
	xor	0ffh		;ans reflip
	ld	(iy+0),a
	ret
;
;	load value parameter onto stack
;
;
	label		;33 - load p
loadp:	pop	hl	;return address
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl	;de now offset to parameter
	push	ix
	pop	iy
	add	iy,de	;iy now address of parameter pointer
	ld	c,(iy-4)	;size of parameter in bytes
	ld	b,(iy-3)
	call	cbase
	ex	de,hl
	ld	hl,0
	add	hl,sp
	or	a
	sbc	hl,bc
	ld	sp,hl
	push	de		;save return address
	ld	e,(iy+0)
	ld	(iy+0),l
	ld	d,(iy+1)
	ld	(iy+1),h	;change pointer to parameter
	ex	de,hl
loadp1:	ldir
	ret
;
;	make sure bc>0
;
cbase:	xor	a
	cp	c
	ret	nz
	cp	b
	ret	nz
	inc	c
	ret
	label			;34 - out of range
	ld	de,oor
abort:	ld	c,9
	call	bdos
	ld	de,near
	ld	c,9
	call	bdos
	pop	hl		;return address
	ld	a,h
	call	hex
	ld	a,l
	call	hex
	ld	de,crlf
	ld	c,9
	call	bdos
	ld	c,0
	call	bdos
hex:	push	hl
	push	af
	rra
	rra
	rra
	rra
	call	nib
	pop	af
	call	nib
	pop	hl
	ret
nib:	and	0fh
	add	'0'
	cp	'9'+1
	jp	m,nib1
	add	'A'-'0'-10
nib1:	ld	e,a
	ld	c,2
	call	bdos
	ret
setofl:	db	'Set element '
oor:	db	'out of range$'
divzer:	db	'Divide by zero$'
modzer:	db	'Modulus zero$'
near:	db	' near $'
crlf:	db	cr,lf,'$'
	end
          ¹[WÜ(   