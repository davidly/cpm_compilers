;
;	Floating point routines
;
;	Dave Moore September 84
;
;	These routines support the following format:
;
;	<exponent (1 byte)>  <mantissa (7 bytes)>
;
;	Hexadecimally normalised, so the numbers are in the range:
;
;	16^-128 * 0.5 to 16^127 * 0.5 
;
;	biggest number is about 10e152
;	precision is about 16 decimal digits
;
size	equ	8		;size of real number in bytes
size2	equ	16
bdos	equ	5
cr	equ	0dh
lf	equ	0ah
	label			;1
p$negr:	ld	hl,size-1+2
;
;	alternate entry point for when number is not top of stack
;	hl must already contain offset from top of stack
;
p$neg0:	add	hl,sp
p$nega:	ld	b,size-2
p$neg1:	ld	a,(hl)
	neg
	ld	(hl),a
	dec	hl
	jp	nz,p$neg2
	djnz	p$neg1
;
;	every byte was zero
;
	ld	a,(hl)
	neg	
	ld	(hl),a
	cp	80h
	ret	nz	;on not special case
	ld	b,size-1
	dec	hl
	inc	(hl)	;increment exponent
	xor	a
p$neg4:	inc	hl
	rrd
	djnz	p$neg4	
	ret
p$neg2:	ld	a,(hl)
	cpl
	ld	(hl),a
	dec	hl
	djnz	p$neg2
	ret
;
;	p$subr - real subtract
;
	label			;2
p$subr:	pop	de		;save return address
	call	p$negr
	push	de		;put return address back
	jp	p$addr		;simulate call
;
;	p$addr - real add
;
	label			;3
p$addr:	ld	iy,2
	add	iy,sp			;start of first addend
	ld	c,(iy+size+1)		;top byte of top mantissa
	push	bc
	push	iy
	ld	a,(iy+0)
	sub	(iy+size)		;subtract other exponent
	jp	z,p$addr3		;on no shift required
	jp	c,p$addr1		;on shift rhs
	ld	de,size
	add	iy,de
	call	shift
	ld	a,(iy-size)
	ld	(iy+0),a		;exponent is exponent from rhs
	jp	p$addr3	
p$addr1:neg
	call	shift
;
;	numbers are normalized - now do add
;	iy points to start of left hand op
;	
p$addr3:pop	hl			;address of first operand
	ld	de,8
	add	hl,de			;address of second operand
	ex	de,hl
	add	hl,de
	ex	de,hl
	or	a			;clear carry
	call	longad7
;
;	code replaced by longad7
;
;p$addr4:dec	iy
;	ld	a,(iy+0)
;	ld	c,(iy+size)
;	adc	c
;	ld	(iy+size),a
;p$add4a:djnz	p$addr4
;
;	if carry has occured, we must shift one place (half byte)
;	and adjust everything
;
	pop	bc		;get old top byte 
	inc	hl
	inc	de
	push	hl
	pop	iy
	ld	b,a
	ld	a,(hl)	;get old top byte
	xor	c
	and	80h
	jp	nz,p$addr5	;if top bits different, no overflow (diff sign)
	ld	a,b
	xor	c
	and	80h
	jp	z,p$addr5	;bit is same, so no carry
	ld	a,(de)
	xor	80h		;comp changed bit
	ld	(de),a
	ld	a,1		;shift one place
	dec	de
	push	de
	pop	iy
	call	shift
	ld	a,(iy+0)
	add	1		;increment exponent
	jp	c,p$addr6
	ld	(iy+0),a
	ld	a,(iy+1)
	xor	8h
	ld	(iy+1),a
	call	normal
	jp	return
p$addr5:ld	de,size-1
	add	iy,de
	call	normal
	jp	return 
p$addr6:ld	de,addofl
	jp	abort
;
;	p$itor 	-	convert integer to real
;
	label			;4
p$itor:	pop	de	;return address
	pop	hl	;value to float
	ld	bc,0
	ld	a,l
	cp	0
	jp	nz,p$itor2
	ld	a,h
	cp	0
	jp	nz,p$itor2
	push	bc
	push	bc
	push	bc
	push	bc
	push	de
	ret
p$itor2:push	bc
	push	bc
	sra	h
	rr	l
	rr	b
	ld	c,l
	push	bc
	ld	b,h
	ld	c,84h
	push	bc
	ld	iy,0
	add	iy,sp	
	push	de
	jp	normal
;
;	p$trnc - convert real to integer by truncation
;
	label			;
p$trnc:	ld	iy,2
	add	iy,sp		;address of number
;
;	the number is normalised, so iy+1 and iy+2 contain value
;
	ld	de,trnneg
	ld	a,(iy+1)
	and	80h
	jp	nz,abort
	ld	hl,0		;assume too small 
	ld	a,(iy+0)	;exponent
	sub	84h
	jp	z,p$trnc1
	ld	de,ovrflo
	jp	nc,abort	;exponent>84h implies too big
	jp	p,p$trnc5	;was too small
	neg			;places to shift
	cp	5
	jp	p,p$trnc5	; on less than 1 so return zero
;
;	a now contains shift count
;
p$trnc1:call	shift
	ld	h,(iy+1)
	ld	l,(iy+2)
	ld	b,(iy+3)
	rl	b
	rl	l
	rl	h
p$trnc5:pop	bc
	pop	de
	pop	de
	pop	de
	pop	de
	push	bc
	ret
;
;	p$rnd - convert real to integer by truncation
;
	label			;6
p$round:ld	iy,2
	add	iy,sp		;address of number
;
;	the number is normalised, so iy+1 and iy+2 contain value
;
	ld	hl,0		;assume too small 
	ld	a,(iy+0)	;exponent
	sub	84h
	ld	de,ovrflo
	jp	nc,abort	;exponent>84h implies too big
	jp	p,p$rnd5	;on very small
	neg
	cp 	5
	jp	m,p$rnd5	; on less than 1 so return zero
;
;	a now contains shift count
;
	call	shift
	ld	h,(iy+1)
	ld	l,(iy+2)
	ld	b,(iy+3)
	rl	b
	rl	l
	rl	h
	rl	b
	jp	nc,p$rnd5
	inc	hl		;round up
p$rnd5:	pop	bc
	pop	de
	pop	de
	pop	de
	pop	de
	push	bc
	ret
	label			;7
p$mulr:	ld	hl,temp
	xor	a
	ld	(normed+1),a
;
;	zero work area
;
;
;	we shift the addend 1 bit right 8 times
;	after each shift, each bit of the multiplicand is checked. 
;	If it is one, we do an add
	call	zero
	call	zero
	call	zero
	ld	(hl),a
	inc	hl
	ld	(hl),a
	call	design
	ld	hl,2+1
	add	hl,sp		;hl points to addend
	ld	de,temp+size2+1	;addend in temp+size2+1..temp+size2+size-1
	ld	bc,7
	ldir			;move addend into temporary area
	ld	b,8		;shifts to do
	ld	c,80h		;first bit to do
;
;	perform adds as required
;
p$mul1:	ld	hl,2+size+1
	add	hl,sp		;second operand mantissa
	push	bc		;save count/bit
	ld	b,size-1	;bytes to check
	ld	de,temp+size	;pointer to place at which to add
p$mul2:	ld	a,c	
	and	(hl)
	jp	z,p$mul6	;on no add required
	push	de
	push	bc
	push	hl
	ld	hl,temp+size2+size	;rh end of addend+1 for shift
	call	longadd
;
;	continue until no carry
;
	jp	nc,p$mul5
p$mul4:	ld	a,(de)
	adc	0		;(was adc (hl))
	ld	(de),a
	dec	de
;	dec	hl
	jp	c,p$mul4
p$mul5:	pop	hl
	pop	bc
	pop	de
p$mul6:	inc	hl
	inc	de
	djnz 	p$mul2
;
;	shift addend 1 bit right
;
	ld	hl,temp+size2+1		;start of addend
	ld	b,size		;bytes to shift
	or	a		;clear carry
p$mul7:	rr	(hl)
	inc	hl
	djnz	p$mul7
	pop	bc		;retrieve total tomes count
	srl	c		;position to next bit
	djnz	p$mul1 
;
;	this completes the multiply
;	the number starts at temp+1 but may have overflowed into temp
;
	ld	iy,2
	add	iy,sp		;start of first number
	ld	a,(iy+0)	;first exponent
	sub	128		;remove bias
	jp	c,p$mul8	;on was less than 128
	add	(iy+size)	;add second exponent
	jp	nc,p$mul9	;on no overflow
p$mul7a:ld	de,mulofl
	jp	abort
p$mul8:	add	(iy+size)	;add second exponent
	jp	c,p$mul9	;on carries cancel so not too small
;
;	number is too small - set to zero
;
	ld	hl,size+2
	add	hl,sp
	call	zero
	jp	return
p$mul9:	add	4
	jp	c,p$mul7a
	ld	(normed),a
	ld	iy,normed
	ld	b,size2		;set size bigger for better precision
	ld	de,size+3
	call	norm0		;normalise result
	ld	hl,normed
p$mul9a:ld	a,(sign)
	ld	hl,normed+size-1
	cp	0
	call	nz,p$nega	;if negative result required
	ld	hl,size+2
	add	hl,sp
	ex	de,hl		;put destination in de
	ld	hl,normed
	ld	bc,size
	ldir			;replace top number
	jp	return
	dsect
rhpntr:	ds	2		;right hand end for add/subtract
respnt:	ds	2
shcnt:	ds	1
sign:	ds	1
normed:	ds	2
temp:	ds	size2+size+2
save:	ds	size
	ds	1
subjmp:	ds	2
	ds	1
addjmp:	ds	2
	csect
;	
;	real divide
;
;	the divisor (the rhs) is top of stack
;	the dividend (the lhs) is next to top
;
	label			;8
;
;	convert both numbers to positive
;
p$divr:	ld	hl,2
	add	hl,sp
	ld	a,(hl)
	or	a
	jp	z,divby0
	ld	hl,temp+size
	call	zero		;clear second half of lhs
	call	zero		;clear result area
	ld	(hl),a
	inc	hl
	ld	(hl),a
	call	design		;remove sign bits
	ld	hl,2+size
	add	hl,sp		;start of lhs
	ld	a,(hl)
	ld	(normed),a	;save exponent
	xor	a
	ld	(hl),a		;and zero as 8th bit of rhs mantissa
	inc	hl
	ld	de,temp+1
	ld	bc,size-1
	ldir			;move lhs to work area
	ld	a,80h
	ld	(de),a		;rund next byte
	pop	bc		;return address
	ld	hl,-56		;set up shift area
	add	hl,sp
	ld	sp,hl
	push	bc
	ld	hl,2+56
	add	hl,sp
	ld	a,(hl)
	ld	(normed+1),a	;rhs exponent
	inc	hl		;point to exponent to shift
	call	setshft
	ld	hl,subm1	;first jump for subman
	ld	(subjmp),hl
	ld	hl,addm1
	ld	(addjmp),hl
	ld	a,0c3h
	ld	(subjmp-1),a
	ld	(addjmp-1),a
	ld	a,8
	ld	(shcnt),a	;set shifts to go before increment
;
;	we are now ready to divide
;
	ld	b,61		;count shifts (two guard nibbles)
	ld	hl,56+2+size-1+1 ;least sig byte of divisor (unshifted)
	add	hl,sp
	ld	(rhpntr),hl
;
;	both values are now +ve
;	perform non-restoring divide
;
	ld	c,0
;
;	we must first subtract the divisor until sign changes
;	as because of hex normalisation, dividend may be 16 times divisor
;
p$diva:	call	subman
	jp	c,p$divb
	inc	c
	jp	p$diva
p$divb:	sla	c
	sla	c
	sla	c
	ld	hl,temp+size+size	;next byte in result
	ld	(hl),c		;set whole number bits
	ld	(respnt),hl
	ld	c,08h		;next bit to change in result
	jp	p$div6
;
;	the first bit represents 1 and so is top bit of second nibble
;
;
;	dividend>0
;
;	increment quotient
;
p$div1:	srl	c
	jp	nc,p$div1a
	rr	c
	ld	hl,(respnt)
	inc	hl
	ld	(respnt),hl
p$div1a:call	subman
	jp	c,p$div6	;on went -ve
p$div2:	ld	hl,(respnt)
	ld	a,(hl)
	or	c
	ld	(hl),a
	ld	a,(shcnt)
	ld	de,-8
	dec	a
	call	z,rshman
	ld	(shcnt),a
	ld	hl,(rhpntr)
	add	hl,de
	ld	(rhpntr),hl
  	djnz	p$div1
	jp	p$div9
;
;	dividend<0
;
p$div5:	srl	c
	jp	nc,p$div5a
	rr	c
	ld	hl,(respnt)
	inc	hl
	ld	(respnt),hl
p$div5a:call	addman
	jp	c,p$div2		;on changed sign
;
;	if we don't change sign, it means that this value would
;	not have divided anyway
;
p$div6:	ld	a,(shcnt)
	ld	de,-8
	dec	a
	call	z,rshman
	ld	(shcnt),a
	ld	hl,(rhpntr)
	add	hl,de
	ld	(rhpntr),hl  ;shift right
	djnz	p$div5
;
;	end of division - set result and normalise
;
;
;	calculate exponent
;
p$div9:	ld	hl,normed
	ld	a,(hl)		;dividend exponent
	inc	hl
	sub	(hl)		;divisor exponent
	rl	e		;save carry flag
	add	81h		;81 because of placement of 1 bit	
	ld	(temp+size+size-1),a	;set exponent
	rla
	xor	e
	rra
	jp	nc,p$div9a	;carries cancel out
	rr	e
	jp	c,p$div10	;on went zero 
	ld	de,divofl
	jp	abort
;
;	check sign and normalise
;
p$div9a:ld	a,(sign)
	ld	hl,temp+size+size+size-2
	cp	0
	call	nz,p$nega	;if negative result required
	ld	iy,temp+size+size-1
	ld	b,size2+2
	ld	de,size+1
	call	norm0 
	ld	de,temp+size+size-1	;start of result
	ld	hl,56+2+size
	add	hl,sp
	ex	de,hl
	ld	bc,size
	ldir			;put back on heap
	jp	p$div11
p$div10:ld	hl,56+size+2
	add	hl,sp
	call	zero
p$div11:ld	hl,56+size
	pop	bc
	add	hl,sp
	ld	sp,hl
	push	bc
	ret
;
;	roll over to next byte
;
roll:	rr	c		;shift back into top of c
	inc	hl		;and move to next byte
	ret
;
;	addman - add mantissas
;		iy points at end of mantissa of divisor
;		the first byte to add to is in rhpntr
;
addman:	push	bc		;save shift count
	ld	de,(rhpntr)
	ld	hl,temp+size
	jp	addjmp-1
;				1
addm1:	ld	a,(de)
	add	(hl)
	ld	(hl),a
	dec	hl
	dec	de
;				2
	ld	a,(de)
	adc	(hl)
	ld	(hl),a
	dec	hl
	dec	de
;				3
	ld	a,(de)
	adc	(hl)
	ld	(hl),a
	dec	hl
	dec	de
;				4
	ld	a,(de)
	adc	(hl)
	ld	(hl),a
	dec	hl
	dec	de
;				5
	ld	a,(de)
	adc	(hl)
	ld	(hl),a
	dec	hl
	dec	de
;				6
	ld	a,(de)
	adc	(hl)
	ld	(hl),a
	dec	hl
	dec	de
;				7
	ld	a,(de)
	adc	(hl)
	ld	(hl),a
	dec	hl
	dec	de
;				8
	ld	a,(de)
	adc	(hl)
	ld	(hl),a
	dec	hl
;	ld	a,(carcnt)
;	ld	b,a
;	jp	addm3
;addm2:	ld	a,(hl)
;	adc	0
;	ld	(hl),a
;	dec	hl
;addm3:	jp	nc,addm4
;	djnz	addm2
addm4:	pop	bc
	ret
;
;	subman - subtract mantissas
;		iy points at end of mantissa of divisor
;		the first byte to add to is temp+size
;
subman:	push	bc		;save shift count
	ld	hl,(rhpntr)
	ld	de,temp+size
	jp	subjmp-1
;					1
subm1:	ld	a,(de)
	sub	(hl)
	ld	(de),a
	dec	hl
	dec	de
;					2
subm2:	ld	a,(de)
	sbc	(hl)
	ld	(de),a
	dec	hl
	dec	de
;					3
	ld	a,(de)
	sbc	(hl)
	ld	(de),a
	dec	hl
	dec	de
;					4
	ld	a,(de)
	sbc	(hl)
	ld	(de),a
	dec	hl
	dec	de
;					5
	ld	a,(de)
	sbc	(hl)
	ld	(de),a
	dec	hl
	dec	de
;					6
	ld	a,(de)
	sbc	(hl)
	ld	(de),a
	dec	hl
	dec	de
;					7
	ld	a,(de)
	sbc	(hl)
	ld	(de),a
	dec	hl
	dec	de
;					8
	ld	a,(de)
	sbc	(hl)
	ld	(de),a
	dec	de
;	ld	a,(carcnt)
;	ld	b,a
;	jp	subm3
;subma2:	ld	a,(de)
;	sbc	0
;	ld	(de),a
;	dec	de
;subm3:	jp	nc,subm4
;	djnz	subma2
subm4:	pop	bc
	ret
;
;	rshman - right shift divisor
;
rshman:	ld	de,subm2-subm1
	ld	hl,(addjmp)
	add	hl,de
	ld	(addjmp),hl
	ld	hl,(subjmp)
	add	hl,de
	ld	(subjmp),hl
	ld	de,+55
	ld	a,8
	ret
;
;	normal - normalize number pointed to by iy
;
normal:	ld	b,size2-2	;max shifts	(2*(size-1) nibbles) 
	ld	de,size-1
norm0:	push	bc
	ld	a,(iy+0)
	cp	0
	jp	z,norm5
	ld	a,(iy+1)
	push	iy
	pop	hl		;address of exponent
	add	hl,de		;point to last byte of mantissa
	ld	b,e		;bytes in mantissa
	sla	a		;carry is now sign bit
	jp	c,norm1		;on negative number
	and	0f0h
	jp	nz,norm4	;on already normalized
	jp	norm2
norm1:	and	0f0h
	xor	0f0h
	jp	nz,norm4	;on normalised
norm2:	ld	b,e		;bytes to shuft
norm3:	rld
	dec	hl
	djnz	norm3
	ld	a,(iy+0)
	dec	a
	jp	z,norm5		;on became zero
	ld	(iy+0),a	;reduce exponent by 1 because shifted
	pop	bc
	djnz	norm0
;
;	shift count expired - must be zero
;
	push	iy
	pop	hl
	call	zero
	ret
norm4:	pop	bc
	ret
norm5:	push	iy
	pop	hl
	call	zero
	pop	bc
	ret
;
;	shift - perform a shift to the right
;
;	iy points to number to shift
;	a gives nibbles to shift
shift:	cp	size2-2
	jp	nc,shift7	;on shift is longer than mantissa
	sra	a
	jp	nc,shift2	;on nibble shift not required
	push	af
	push	iy
	pop	hl
	inc	hl
	ld	a,(hl)
	and	80h
	jp	z,shift1
	ld	a,0fh		;if sign entend required
shift1:	rrd
	inc	hl
;			2
	rrd
	inc	hl
;			3
	rrd
	inc	hl
;			4
	rrd
	inc	hl
;			5
	rrd
	inc	hl
;			6
	rrd
	inc	hl
;			7
	rrd
	inc	hl
;
	pop	af		;restore byte shift count
;
;	shift to right
;
shift2:	cp	0
	ret	z		;if we have finished
	ld	de,size
	push	iy
	pop	hl
	add	hl,de		;address of last byte+1
	ld	e,a
	ld	c,a		;save shift count
	ld	d,0
	push	hl
	xor	a
	sbc	hl,de		;address of first byte to move+1
	pop	de
	ld	a,size-1
	sub	c		;a now is bytes to move
	ld	b,a
shift3:	dec	hl
	dec	de
	ld	a,(hl)
	ld	(de),a
	djnz	shift3
;
;	now sign extend remaining bytes
;
	ld	b,c		;bytes to sign extend
	and	80h
	jp	z,shift4
	ld	a,0ffh		;sign extend with 1's
shift4:	dec	de
	ld	(de),a
	djnz	shift4
	ret
shift7:	push	iy
	pop	hl
	call	zero
	ret
;
;	p$cmpr - compare two reals
;
	label			;9
;
;	de is set as follows
;
;	0 = values are equal
;	1 = rhs>lhs
;	2 = rhs<lhs
p$cmpr:	ld	iy,2
	add	iy,sp		;point to numbers
	ld	a,(iy+0)
	cp	0
	jp	z,p$cmprrz	;on rhs is zero
	ld	a,(iy+size)
	cp	0
	jp	z,p$cmprlz	;on lhs is zero
	ld	a,(iy+1)
	xor	(iy+size+1)
	and	80h
	jp	z,p$cmpr2	;equal signs
	ld	a,(iy+1)
	and	80h
	ld	e,1		;assume rhs>lhs
	jp	z,p$cmpr9	;on rhs +ve so lhs<rhs
	ld	e,2		;rhs is negative so lhs>rhs
	jp	p$cmpr9
;
;	left or right hand exponent is zero
;
p$cmprrz:ld	e,0		;assume equal
	ld	a,(iy+size)	;get left exponent
	cp	0
	jp	z,p$cmpr9
	ld	a,(iy+size+1)
	ld	e,2		;assume rhs=0<lhs
	and	80h
	jp	z,p$cmpr9
	dec	e	
	jp	p$cmpr9
p$cmprlz:ld	a,(iy+1)
	ld	e,1
	and	80h
	jp	z,p$cmpr9
	inc	e
	jp	P$cmpr9
	
;
;	signs are the same see if exponents are the same also
;
p$cmpr2:ld	a,(iy+0)	;get rhs exponenet
	cp	(iy+size)	;>0=> rhs>lhs if +ve
	jp	z,p$cmpr5	;on equal exponents
;
;	exponents differ
;
	ld	e,1		;assume rhs<lhs
	jp	nc,p$cmpr3
	ld	e,2
;
;	if numbers are -ve, must change sense of result
;
p$cmpr3:ld	a,(iy+1)
	and	80h
	jp	z,p$cmpr9
	ld	a,3
	sub	e
	ld	e,a
	jp	p$cmpr9
;
;	exponents and signs match - look for difference in mantissa
;	
p$cmpr5:push	iy
	pop	de
	ld	hl,size
	add	hl,de		
	ld	b,size-1
;
;	de points to rhs, hl to lhs
;
p$cmpr6:inc	de
	inc	hl
	ld	a,(de)
	cp	(hl)
	jp	nz,p$cmpr7
	djnz	p$cmpr6
;
;	numbers are equal
;
	ld	e,0
	jp	p$cmpr9
;
;	first differing byte found
;
p$cmpr7:ld	e,1	;assume rhs>lhs
	jp	nc,p$cmpr9	;was 3
	ld	e,2
	jp	p$cmpr9		;was 3
;
;	cut back stack,set register flags etc
;
p$cmpr9:pop	bc	;return address
	ld	hl,size2
	add	hl,sp
	ld	sp,hl
	ld	a,e
	cp	0	;zero if equal
	rra		;and set carry flag (carry=>e=1>=lhs<rhs)
	push	bc
	ret
;
;	set a number to zero
;	hl points to start of number
;
zero:	ld	bc,size-1
	xor	a
	ld	d,h
	ld	e,l
	inc	de
	ld	(hl),a
	ldir
	ex	de,hl
	ret
;
;	remove sign bits and store required result sign in sign
design:	ld	iy,4
	add	iy,sp		;pointer to rhs
	ld	a,(iy+1)
	ld	hl,4+size-1+2	;extra two for forthcoming call
	and	80h
	ld	e,a		;save sign bit
	call	nz,p$neg0	;on -ve
	ld	a,(iy+size+1)
	ld	hl,size-1+4+size+2
	and	80h
	ld	d,a
	call 	nz,p$neg0
	ld	a,e
	xor	d
	ld	(sign),a	;80h if sign change needed at end
	ret
	label			;10
;
;	Real absolute value
;
p$absr: pop	iy
	ld	hl,0
	add	hl,sp
	ld	de,8
	ex	de,hl
	add	hl,de		;move parameter into result area and cut stack
	ex	de,hl
	ld	bc,size
	ldir
	ld	sp,hl
	push	iy
	inc	hl
	ld	a,(hl)	;get most sig bit
	and	80h
	jp	nz,p$negr	;do negate of minue
	ret			;otherwise, leave unchanged
;
;	p$ctor 	-	convert cardinal to real
;
	label			;11
p$ctor:	pop	de	;return address
	pop	hl	;value to float
	ld	bc,0
	ld	a,l
	cp	0
	jp	nz,p$ctor2
	ld	a,h
	cp	0
	jp	nz,p$ctor2
	push	bc
	push	bc
	push	bc
	push	bc
	push	de
	ret
p$ctor2:push	bc
	push	bc
	srl	h
	rr	l
	rr	b
	ld	c,l
	push	bc
	ld	b,h
	ld	c,84h
	push	bc
	ld	iy,0
	add	iy,sp	
	push	de
	jp	normal
;
;	return - return from binary operator
;
return:	pop	hl		;return address
	pop	de
	pop	de
	pop	de
	pop	de		;cut back stack
	jp	(hl)
divby0:	ld	de,divzer
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
near:	db	' near $'
crlf:	db	cr,lf,'$'
ovrflo:	db	'real too large for TRUNC ','$'
mulofl:	db	'MULR - floating overflow','$'
divofl:	db	'DIVR - floating overflow','$'
divzer:	db	'Divide by zero','$'
addofl:	db	'Floating add/subtract overflow','$'
trnneg:	db	'Trunc of negative real','$'
;
;	longadd - perform a rolled out add
;	add hl to de
;
longadd:ld	a,(de)
	add	(hl)	
	ld	(de),a
longad7:dec	de
	dec	hl
;			2
	ld	a,(de)
	adc	(hl)	
	ld	(de),a
	dec	de
	dec	hl
;			3
	ld	a,(de)
	adc	(hl)	
	ld	(de),a
	dec	de
	dec	hl
;			4
	ld	a,(de)
	adc	(hl)	
	ld	(de),a
	dec	de
	dec	hl
;			5
	ld	a,(de)
	adc	(hl)	
	ld	(de),a
	dec	de
	dec	hl
;			6
	ld	a,(de)
	adc	(hl)	
	ld	(de),a
	dec	de
	dec	hl
;			7
	ld	a,(de)
	adc	(hl)	
	ld	(de),a
	dec	de
	dec	hl
;			8
	ld	a,(de)
	adc	(hl)	
	ld	(de),a
	dec	de
	dec	hl
	ret
;
;	set up shifts on the stack
;	hl points to mantissa to shift, which is also first
;	entry in shift table
;
setshft:ld	b,7		;shifted rhs's to set up
p$divx:	ld	de,-8
	ex	de,hl
	add	hl,de	
;
;	hl now points to next exponent
;	de points to last
;
	push	hl
;				1				
	ld	a,(de)
	srl	a
	ld	(hl),a
	inc	hl
	inc	de
;				2		
	ld	a,(de)
	rra
	ld	(hl),a
	inc	hl
	inc	de
;				3
	ld	a,(de)
	rra
	ld	(hl),a
	inc	hl
	inc	de
;				4
	ld	a,(de)
	rra
	ld	(hl),a
	inc	hl
	inc	de
;				5
	ld	a,(de)
	rra
	ld	(hl),a
	inc	hl
	inc	de
;				6
	ld	a,(de)
	rra
	ld	(hl),a
	inc	hl
	inc	de
;				7
	ld	a,(de)
	rra
	ld	(hl),a
	inc	hl
	inc	de
;				8
	ld	a,(de)
	rra
	ld	(hl),a
	inc	de
;				
	pop	hl
	djnz	p$divx
	ret
	end
CKUP  M_U           ²XZ  J PATCH   MOD           ”tSîR  ROOT    ARC           É¡³[ SIDEWAYSARC           ­=§ý ~  