;
; More assembly-language BDS C library functions
; This file contains the DMA-video and CP/M 2.0 random-access
; file I/O routines. The 2.0 functions have NOT been documented in the
; User's Guide because they are non-portable to pre-2.x CP/M systems.
;

	maclib bds
	maclib cmac

	direct
	define setplot		;define video board dimensions
	define clrplot		;clear the screen
	define line		;draw a crooked line
	define plot		;plot a point
	define txtplot		;put text up

	define rread		;random read
	define rwrite		;random write
	define rseek		;random seek
	define rtell		;random tell
	define rsrec		;random set record field
	define rcfsiz		;random set (and return) file size

	enddir


;
; Setplot:
;
; Set up plotting paramters for the DMA video plotting
; routines:
;

	prelude setplot

	call arghak
	push b
 	lhld arg1		;get base address
	shld pbase		;	initialize
	lhld arg3		;get y size
	shld ysize		;	initialize
	xchg			;leave it in DE
	lhld arg2		;get x size
	shld xsize		;	initialize
	call usmul		;figure out screen size
	shld psize		;	initialize
	pop b
	ret

	postlude setplot

;
; Clrplot:
;
; Clear screen on DMA plotting device:
;

	prelude clrplot

	lhld psize		;put screen size
	xchg			;	in DE
	lhld pbase		;get screen base in HL
clr2:	mvi m,' '		;and
	inx h			;   clear
	dcx d			; 	each
	mov a,d			;	  location
	ora e			;		(all DE of 'em)
	reloc jnz,clr2
	ret

	postlude clrplot
;
; Line:
;
; This function draws a line between any 2 points on a device
; such as the VDM-1.
;
; The address of the VDM-1 screen is stored at pbase.
; This routine will only work for 16x64-orgranized video
; displays.
;

	prelude line

	call arghak		;get args
	push b
	lda arg2		;put one set of endpoint data in DE in
	mov c,a			;format:  D = x = arg2, E = y = arg3
	lda arg3
	mov b,a
	mov d,b
	mov e,c
	reloc call,put		; put up one endpoint at BC
	lda arg4		;put other endpoint data in HL
	mov c,a
	lda arg5
	mov b,a
	reloc call,put		;(but first put up the point from BC)
	mov h,b
	mov l,c
	reloc call,liner		;now connect them...
	pop b
	ret			;all done.


;
;  This routine draws a line between points specified by DE
;  and HL (it assumes that the two endpoints are already up
;  on the screen):
;

liner:	mov a,d
	sub h
	reloc call,abs
	cpi 2
	reloc jnc,line2		;are points far enough apart
				;in both dimensions to warrant
	mov a,e			;drawing a line?
	sub l
	reloc call,abs
	cpi 2
	reloc jnc,line2
	ret			;if not, return.


;
; Yes, the two points are sufficiently far apart to warrant a 
; line. So, draw it:
;

line2:	reloc call,midp		;find midpoint
	reloc call,put		;put it up
	push d			;set up recursive call
	mov d,b
	mov e,c
;
; Draw a line between one original point and the midpoint:
;

	reloc call,liner
	xthl
;
; Draw a line between the other original point and the midpoint:
; 	(Isn't recursion fun?)
;
	reloc call,liner
	xchg
	pop h
	ret			;and we are done!

;
; This routine finds the point as close as possible to the 
; midpoint between the two points specified in HL and DE.
; Coordinates of the midpoint are returned in BC:
;

midp:	push h
	push d

	mov a,h
	sub d
	ani 1
	reloc jz,mid3

	mov a,h
	cmp d
	reloc jc,mid2a
	inr d
	reloc jmp,mid3

mid2a:	dcr h

mid3:	mov a,l
	sub e
	ani 1
	reloc jz,mid4

	mov a,l
	cmp e
	reloc jc,mid3a
	inr e
	reloc jmp,mid4

mid3a:	dcr l

mid4:	mov a,h
	add d
	ora a
	rrc
	mov b,a
	mov a,l
	add e
	ora a
	rrc
	mov c,a
	pop d
	pop h
	ret

;
; Subroutine to put a point on the screen at the location
; specified by BC, where B=y,  C=x:
;

put:	push b
	push h
	mvi a,1bh
	call writc
	mvi a,'Y'
	call writc
	mvi a,32
	add b
	call writc
	mvi a,32
	add c
	call writc		
	pop h
	pop b
	ret

writc:	push b
	mvi c,2
	mov e,a
	call 5
	pop b
	ret

;
; Subroutine to return A=abs(A):
;

abs:	ora a
	rp
	cma
	inr a
	ret

	postlude line		;end of "line" function


;
; Plot:
;
; Put a point on the DMA device:
;

	prelude plot

	call arghak
	lda arg1
	lhld ysize
	xchg
	lhld pbase
	inr a
plot1:	dcr a
	reloc jz,plotc
	dad d
	reloc jmp,plot1

plotc:	lda arg2
	mov e,a
	mvi d,0
	dad d
	lda arg3
	mov m,a
	ret

	postlude plot


;
; Txtplot:
;
; Put some text up on the DMA device:
;


	prelude txtplot

	call arghak
	push b
	lhld arg2
	xchg
	lhld ysize
	call usmul
	xchg
	lhld arg3
	dad d
	xchg
	lhld pbase
	dad d
	xchg
	lhld arg1
	mvi b,0
	lda arg4
	ora a
	reloc jz,txt2
	mvi b,80h
txt2:	mov a,m
	ora a
	reloc jnz,txt3
	pop b
	ret

txt3:	ora b
	stax d
	inx h
	inx d
	reloc jmp,txt2
	
	postlude txtplot



;
; Here are the new random-access file I/O routines
; for use with CP/M version 2.x ONLY...these functions
; will NOT work under pre-2.x CP/M's.
;
; The new functions are: rread, rwrite, rtell, rseek,
;			 rsrec, rcfsiz
;


;
; Rread:
;
; Read a number of sectors randomly
; Usage:
;
;	i = rread(fd, buf, n);
;
; The return value is either the number of sectors successfully
; read, 0 for EOF, or 1000 + (BDOS ERROR CODE)
; 
; The Random Record Field is incremented following each successful
; sector is read, just as if the normal (sequentail) read function
; were being used. Rseek must be used to go back to a previous 
; sector.
;

	prelude rread

	call arghak
	lda arg1
	call fgfd
	jc error
	mov a,m
	ani 2
	jz error
	push b
	lda arg1
	call fgfcb
	shld tmp2
	lxi h,0
	shld tmp2a
r2:	lhld arg3
	mov a,h
	ora l
	lhld tmp2a
	reloc jnz,r2a
	pop b
	ret

r2a:	lhld arg2
	xchg
	mvi c,sdma
	call bdos
	lhld tmp2
	xchg
	mvi c,readr	;code for BDOS random read
	push d		;save de so we can fudge nr field if
	call bdos	;we stop reading on extent boundary...
	pop d		; CP/M sucks!
	ora a
	reloc jz,r4		;go to r4 if no problem
	cpi 1
	reloc jz,r2b		;EOF?
	mov c,a		;put return error code in BC
	mvi b,0
	lxi h,1000	;add to 1000
	dad b
	pop b
	ret

r2b:	lxi h,32	;yes. are we on extent boundary?
	dad d
	mov a,m
	cpi 80h
	reloc jnz,r3
	mvi m,0		;yes. reset nr to 0...CP/M leaves it at 80!
r3:	lhld tmp2a	;(note: the above "bug" in CP/M was supposedly fixed
	pop b		; for 2.x, but one can never be sure...)
	ret

r4:	lhld arg3
	dcx h
	shld arg3
	lhld arg2
	lxi d,128
	dad d
	shld arg2
	lhld tmp2a
	inx h
	shld tmp2a
	lhld tmp2	;get address of fcb
	lxi b,33	;get addr of random record field
	dad b
	mov c,m		;bump
	inx h		;    value
	mov b,m		;	  of 
	inx b		;	    random
	mov m,b		;		  field
	dcx h		;			by one
	mov m,c
	reloc jmp,r2

	postlude rread


;
; Rwrite:
;
; The random "write" routine, which always copies the sector
; to be written down to tbuff before writing. Returns
; the # of sectors successfully written, or -1 on hard error.
; (the "1000 + error code" business is not used for rwrite)
;

	prelude rwrite

	call arghak
	lda arg1
	call fgfd
	jc error
	mov a,m
	ani 4
	jz error
	push b
	lda arg1
	call fgfcb
	shld tmp2
	lxi h,0
	shld tmp2a
	lxi d,tbuff 	;80 for normal CP/M, else 4280
	mvi c,sdma
	call bdos

nwr2:	lhld arg3	;done yet?
	mov a,h
	ora l
	lhld tmp2a	;if so, return count
	reloc jnz,nwr2a
	pop b
	ret

nwr2a:	lhld arg2	;else copy next 128 bytes down to tbuff
	lxi d,tbuff	;80 for normal CP/M, else 4280
	mvi b,128
nwr3:	mov a,m
	stax d
	inx h
	inx d
	dcr b
	reloc jnz,nwr3
	shld arg2	;save -> to next 128 bytes
	lhld tmp2	;get addr of fcb
	xchg
	mvi c,writr	;go write randomly
	call bdos
	ora a		;error?
	lhld tmp2a	;if so, return # of successfully written
	pop b		;  sectors.
	rnz
	push b
		
	inx h		; else bump successful sector count,
	shld tmp2a
	lhld arg3	; debump countdown,
	dcx h
	shld arg3
	lhld tmp2	; get address of fcb
	lxi b,33	; get address of random field
	dad b
	mov c,m		; bump 16-bit value at random
	inx h		; record
	mov b,m		;	field
	inx b		;	     of
	mov m,b		;	       fcb
	dcx h		;		  by one
	mov m,c
	reloc jmp,nwr2	; and go try next sector

	postlude rwrite


;
; rseek:
;
; rseek(fd, offset, origin)
;	   seeks to offset records if origin == 0,
;     to present position + offset if origin == 1,
;	or to end of file + offset if origin == 2.
; (note that in the last case, the offset must be non-positive)
;

	prelude rseek

	call arghak
	lda arg1
	call fgfcb
	jc error
	push h
	reloc call,rtell2
	lhld arg2
	lda arg3	;is origin == 0?
	ora a
	reloc jz,rseek2	;if so, HL holds new position
	dcr a		;no. is origin == 1?
	reloc jnz,rseek1
	dad d		;yes. add offset to current position
	reloc jmp,rseek2	;and result is in HL

rseek1:	pop d		;else origin must be 2...
	push d
	push b
	mvi c,cfsizc	;compute end of file position
	call bdos
	pop b
	pop h		;get back fcb
	push h
	reloc call,rtell2	;get DE = position
	lhld arg2	;add offset
	dad d		;and HL holds new position
rseek2:	xthl		;get fcb, push new position
	lxi d,33
	dad d		;HL points to random field of fcb
	pop d		;get new position in DE
	mov m,e		;and put into fcb
	inx h
	mov m,d
	xchg		;and return the position value
	ret

rtell2:	lxi d,33
	dad d
	mov e,m	
	inx h
	mov d,m
	ret

	postlude rseek


;
; Rtell:
;
; Return random record position of file:
;

	prelude rtell

	call arghak
	lda arg1
	call fgfcb
	jc error
	lxi d,33	;go to random record field
	dad d
	mov e,m		;get value into DE
	inx h
	mov d,m
	xchg		;put into HL
	ret

	postlude rtell


;
; Rsrec:
;
; Set random field from serial access mode:
;

	prelude rsrec

	call arghak
	lda arg1
	call fgfcb
	jc error
	push h
	xchg
	push b
	mvi c,srrecc
	call bdos
	pop b
	pop h
	lxi d,33
	dad d
	mov a,m
	inx h
	mov h,m
	mov l,a
	ret

	postlude rsrec


;
; Rcfsiz:
;
; set random record field to end-of-file:
;

	prelude rcfsiz

	call arghak
	lda arg1
	call fgfcb
	jc error
	push h
	xchg
	push b
	mvi c,cfsizc
	call bdos
	pop b
	pop h
	lxi d,33
	dad d
	mov a,m
	inx h
	mov h,m
	mov l,a
	ret

	postlude rcfsiz


 m,e		;and put into fcb
	inx h
	mov m,d
	xchg		;and return the position value
	ret

rtell2:	lxi 