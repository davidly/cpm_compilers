;
  TITLE         Pascal Runtime Module
  FILENAME      PASCAL3.ASM
  AUTHOR        Robert A. Van Valzah  30/08/79
  LAST REVISED  Robert A. Van Valzah  10/12/79
; REASON	changed entry of spalod for hl=lsbyte of alfa
;
;
vhu	equ	0	;verision number hundreds
vtn	equ	0	;version number tens
vun	equ	8	;version number units
devrel  equ     'r'     ;development or release version
;
bdos	equ	5
open	equ	15
close	equ	16
delete	equ	19
readrec	equ	20
writerec equ	21
make	equ	22
setdma	equ	26
;
romorg	equ	100h
	org	romorg
	jmp	startup
	jmp	base
	jmp	cmpr
	jmp	csp0
	jmp	csp1
	jmp	$
	jmp	csp3
	jmp	$
	jmp	$
	jmp	$
	jmp	$
	jmp	csp8
	jmp	csp9
	jmp	spalit
	jmp	spalod
	jmp	spasto
	jmp	acmpr
	jmp	opr3
	jmp	opr4
	jmp	opr5
	jmp	$
	jmp	$
	jmp	spcal0
	jmp	spcal
	jmp	spret
br	ds	2
;
; insert version number in object
;
	db	'RTP REV '
	db	vhu+'0', vtn+'0', '.', vun+'0', devrel
;
; startup sets up the i/o and stacks before transfering to
; the object code for execution
;
startup:
	lhld	6	;set stack under bdos
	mvi	l,0
	sphl
	shld	br	;inti base reg
	call	setio	;set ciflag and coflag
	call	openf	;open files if needed
	jmp	ocode	;vector to generated object code
;
; setio sets ciflag to 0ffh (true) if input is to come from
; the console (as opposed to 0h if it is to come from disk)
; and likewise for coflag for console output
;
setio:
	lda	5dh	;first name byte of fcb1
	mvi	b,0ffh	;prepare ciflag value
	cpi	' '	;blank means console in
	jz	set1
	cpi	'?'	;? means console in too
	jz	set1
	inr	b	;reg b = 0
set1:
	mov	a,b	;get ciflag value
	sta	ciflag	;store it
	lxi	h,ifcb	;copy first name into input fcb
	lxi	d,5ch
	call	copynam
	lda	6dh	;get first name byte of fcb2
	mvi	b,0ffh	;same as above
	cpi	' '
	jz	set2
	cpi	'?'
	jz	set2
	inr	b
set2:
	mov	a,b
	sta	coflag
	lxi	h,ofcb	;copy second name into output fcb
	lxi	d,6ch
	call	copynam
	ret
;
; copynam moves a file name from de to hl.
; clobbers reg hl, de, b, a.
;
copynam:
	mvi	b,12	;filename length
cn1:
	ldax	d	;get from source
	mov	m,a	;put to dest
	inx	d
	inx	h
	dcr	b
	jnz	cn1
	ret
;
; openf opens the file name in fcb1 for input if ciflag is
; false and opens the name in fcb2 for output if coflag is
; false
;
openf:
	lda	ciflag	;get ciflag
	ora	a
	jnz	op1	;skip open if true
	xra	a	;zap fcbnr
	sta	ifcb+32
	lxi	d,ifcb
	mvi	c,open
	call	bdos
	inr	a
	jz	diskerr	;not found
	lxi	h,ibuf+80h ;init input buffer pointer
	shld	iptr
op1:
	lda	coflag	;get coflag
	ora	a
	rnz		;skip open if true
	lxi	d,ofcb
	mvi	c,delete
	call	bdos
	lxi	d,ofcb
	mvi	c,make
	call	bdos
	inr	a
	jz	diskerr	;no idrectory space
	xra	a	;zap fcbnr
	sta	ofcb+32
	lxi	h,obuf	;init output buffer pointer
	shld	optr
	ret
;
; base follow static links back reg a levels, return base
; in reg hl
;
base:
	lhld	br	;start with current base
follow:
	mov	e,m	;get a link to reg de
	inx	h
	mov	d,m
	xchg		;link to reg hl
	dcr	a	;enough links followed?
	jnz	follow	;no
	ret		;yes
;
; cmpr is called to set flags like (top)-(top-1) before
; the call to cmpr
; returns reg a non zero if zero flag is reset
;
cmpr:
	pop	h	;cmpr return address to reg hl
	pop	d	;(top) to reg de
	xthl		;(top-1) to reg hl, return address to stack
	mov	a,d	;compare signs
	xra	h
	jp	samsin	;same sign - unsigned compare ok
	mov	a,d	;opposite sign
	ral
	mvi	a,0ffh	;return nonzero value
	ret
samsin:
	mov	a,d	;compre msb's
	sub	h
	rnz
	mov	a,e
	sub	l
	ret
;
; gets gets a character from the pasacl input file.  it
; comes from the console if ciflag is true, else from disk.
; char returned in reg a.
;
gets:
	lda	ciflag
	ora	a
	jnz	ci	;in from console
	lda	idev
	ora	a
	jnz	ci
	call	idiskch	;intput disk character
	ret
ci:
	mvi	c,1
	call	bdos
	ret
;
; idiskch gets a character from the input disk file to reg a
;
idiskch:
	lhld	iptr
	mov	a,l
	cpi	(ibuf+80h) and 0ffh
	jnz	noread	;dont have to read record
	lxi	d,ibuf
	mvi	c,setdma
	call	bdos
	mvi	c,readrec
	lxi	d,ifcb
	call	bdos
	ora	a
	jnz	diskerr
	lxi	d,80h	;restore dma address
	mvi	c,setdma
	call	bdos
	lxi	h,ibuf
noread:
	mov	a,m	;get character
	inx	h
	shld	iptr	;update pointer
	ret
;
; putd puts a character to the pascal output file.  it goes
; to the console if coflag is true, else to the disk.
; char is passed in reg a.
;
putd:
	mov	c,a	;save char while testing coflag
	lda	coflag
	ora	a
	jnz	co	;out to console
	lda	odev	;get output device
	ora	a
	jnz	co	;only device zero can go to disk
	mov	a,c	;get character back
	call	odiskch	;out to disk
	ret
co:
	mov	e,c	;get character back
	mvi	c,2
	call	bdos
	ret
;
; odiskch sends the character in reg to the disk output file
;
odiskch:
	push	psw
	lhld	optr	;see if past end of out buffer
	mov	a,l
	cpi	(obuf+80h) and 0ffh
	jnz	nowrite	;nope
	lxi	d,obuf
	mvi	c,setdma
	call	bdos
	lxi	d,ofcb
	mvi	c,writerec
	call	bdos
	ora	a
	jnz	diskerr
	lxi	d,80h	;restore dma address
	mvi	c,setdma
	call	bdos
	lxi	h,obuf
nowrite:
	pop	psw
	mov	m,a	;store in buffer
	inx	h
	shld	optr	;save new pointer
	ret
;
; csp0 read a character and push it to stack
;
csp0:
	sta	idev	;save input device
	call	gets
	mov	l,a
	mvi	h,0
	xthl
	pchl
;
; csp1 pop stack and write it as a character
;
csp1:
	sta	odev	;save output device for putd
	pop	h	;csp1 return address to reg hl
	xthl		;return adr to stack, (top) to reg hl
	mov	a,l	;char to reg a for putd
	call	putd
	ret
;
; prthl prints the contents of reg hl as a decimal number
; on the pascal output file
;
prthl:
	lxi	b,-10	;divisor
setup:
	lxi	d,-1	;quotient
sub10:
	dad	b	;divide by continued subtraction
	inx	d	;update quotient
	jc	sub10	;keep dividing till under draft
	mvi	a,10	;get remainder to reg a
	add	l
	push	psw	;save on stack
	xchg		;quotient to reg hl
	mov	a,h	;any digits left?
	ora	l
	cnz	setup	;yes - recurse to print next digit
	pop	psw	;no - get digits to print from
	adi	'0'	;stack in reverse order & convert
	jmp	putd	;to ascii and print 'em
;
; csp3 pops the stack and writes it as a decimal number to
; the pascal output file
;
csp3:
	sta	odev	;save output device for putd
	pop	h	;get return address to reg hl
	xthl		;(top) to reg hl, return address back to stack
	call	prthl	;print
	ret
;
; csp8 prints the alfa variable on the stack
;
csp8:
	sta	odev	;save output device for putd
	mvi	d,4	;number of words to pop
csp81:
	pop	h	;top word from stack to hl
	xthl
	push	d	;save word count
	push	h	;save ms char of word
	mov	a,l	;print ls char of word
	call	putd
	pop	h	;get word again
	mov	a,h	;print ms char of word
	call	putd
	pop	d	;get word count
	dcr	d	;doen all 4 words?
	jnz	csp81	;nope
	ret
;
; csp9 returns control to the operating system (boots)
;
csp9:
	lda	coflag	;was output to console?
	ora	a
	jnz	0	;yes - just return to cp/m
seof:
	mvi	a,1ah	;send eof character
	call	odiskch
	lda	optr
	cpi	(obuf+1) and 0ffh
	jnz	seof	;until last record has been written
	lxi	d,ofcb
	mvi	c,close
	call	bdos	;close output file
	inr	a
	jz	diskerr
	jmp	0
diskerr:
	lxi	d,errmsg
	mvi	c,9
	call	bdos
	jmp	0
errmsg:	db	'disk error$'
;
; spalit takes the eight bytes following the call to it
; and pushes them into the stack
;
spalit:
	pop	h	;return address to reg hl
	mvi	a,4	;eight bytes is four words
moralit:
	mov	d,m	;get a word from code and . . .
	inx	h
	mov	e,m
	inx	h
	push	d	;push it into the stack
	dcr	a	;done all words?
	jnz	moralit	;no
	pchl		;return to byte following dw's
;
; spalod enter with a pointer to lsbyte (first character)
; of alfa variable and it
; pushes the variable into the stack
;
spalod:
	lxi	b,7	;bias hl to point to msbyte
	dad	b
	pop	b	;get return address to reg b
	mvi	a,4	;four words per alfa
moralod:
	mov	d,m	;get a word from the alfa
	dcx	h
	mov	e,m
	dcx	h
	push	d	;and push it into the stack
	dcr	a	;done all words yet?
	jnz	moralod	;no
	mov	h,b	;pchl to return address
	mov	l,c
	pchl
;
; spasto enter with reg hl pointing to lsbyte (first character)
; of an alfa variable,
; an alfa is popped from the stack and stored at reg hl
;
spasto:
	pop	b	;get return address
	mvi	a,4	;four words per alfa
morasto:
	pop	d	;get a word from the stack
	mov	m,e	;and store it into alfa
	inx	h
	mov	m,d
	inx	h
	dcr	a	;done all words yet
	jnz	morasto	;no
	mov	h,b	;pchl to return address
	mov	l,c
	pchl
;
; acmpr compares two alfa variables on the stack, sets flags
; like (top)-(top-1)
;
acmpr:
	lxi	h,18	;compute stack pointer after
	dad	sp	;compare is done
	push	h	;save it
	lxi	d,-8	;compute address of top-1
	dad	d
	xchg		;top-1 ptr to reg de
	dad	d	;top ptr to reg hl
	xchg		;top ptr to reg de, top-1 to hl
	mvi	c,8	;chars per alfa
moracmp:
	ldax	d
	cmp	m
	jnz	exitacm	;miscompare - return with flags
	inx	h
	inx	d
	dcr	c
	jnz	moracmp	;not done comparing
exitacm:
	pop	h	;new stack pointer to reg hl
	pop	d	;return address to reg de
	sphl
	xchg
	pchl
;
; opr3 subtracts (top) from (top-1)
;
opr3:
	pop	h	;return address to reg hl
	pop	d	;(top) to reg de
	xthl		;put back return address, (top-1) to hl
	xra	a	;negate reg de, holding (top)
	sub	e
	mov	e,a
	sbb	d
	sub	e
	mov	d,a
	dad	d	;add -(top) to (top-1)
	xthl		;leave restult on stack and return
	pchl		;address in reg hl
;
; opr4 multiply (top) by (top-1)
;
opr4:
	pop	h
	pop	d
	xthl
	push	b
	mov	b,h
	mov	c,l
	lxi	h,0
mulmor:
	mov	a,c
	ora	b
	jz	muldone
	dcx	b
	dad	d
	jmp	mulmor
muldone:
	pop	b
	xthl
	pchl
;
; opr5 divides (top-1) by (top)
;
opr5:
	pop	h
	pop	d
	xthl
	push	b
	xra	a	;negate reg de
	sub	e
	mov	e,a
	sbb	d
	sub	e
	mov	d,a
	lxi	b,-1
mordiv:
	inx	b
	dad	d
	jc	mordiv
	mov	h,b
	mov	l,c
	pop	b
	xthl
	pchl
;
; call here with adr to call in reg de
;
spcal0:
	lhld	br
	push	h	;static link
	push	h	;dynamic link
	lxi	h,0
	dad	sp
	shld	br
	xchg		;pchl to address to call
	pchl
;
; call here with level difference in reg a and
; address to call in reg de
;
spcal:
	lhld	br	;dynamic link
	push	h
	push	d	;save call address
	call	follow	;get static link
	xthl		;static link to stack, call addresss to hl
	xchg		;call address to reg de
	lxi	h,0
	dad	sp
	shld	br
	xchg		;pchl to call address
	pchl
;
; jump here to return from a procedure
;
spret:
	lhld	br	;get old sp back
	sphl
	pop	psw	;pop and ignore static link
	pop	h	;dynamic link
	shld	br	;restore base register
	ret
;
ifcb	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;a few too many
ofcb	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
ciflag	db	0
coflag	db	0
odev	db	0
idev	db	0
;
iptr	ds	2
optr	ds	2
ibuf	ds	128
obuf	ds	128
;
	org	(($-1) and 0ff00h) + 100h
ocode:			;start of compiled code
;
	end	romorg
