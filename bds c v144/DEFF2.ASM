;
; BDS C Standard Library Machine Language Functions  v1.44  4/2/81
;

	maclib bds
	maclib cmac

	direct
	define getchar
	define kbhit
	define ungetch
	define putchar
	define putch
	define gets
	define rand
	define srand
	define srand1
	define nrand

	define csw
	define setmem
	define movmem
	define call
	define calla
	define inp
	define outp
	define peek
	define poke
	define sleep
	define pause

	define setfcb
	define read
	define write
	define open
	define close
	define creat
	define unlink
	define seek
	define tell
	define rename
	define fabort
	define fcbaddr

	define exit
	define bdos
	define bios
	define codend
	define externs
	define endext
	define topofmem
	define exec
	define execl
	define execv
	define sbrk
	define rsvstk
	enddir

;
; Getchar:
;
; Function to get and echo a character from the console input:
;
; If location "ungetl" is non-zero, an ungotten character
; is assumed to be there, and it is returned.
;
; If a control-C is typed, CP/M is rebooted.
; If a control-Z is typed, a -1 is returned.
; If a return is typed, "newlin" (really linefeed) is returned
; and a CR-LF combo is echoed to the console output.
;

	prelude	getchar

	lda ungetl	;any character pushed back?
	ora a
	mov l,a
	reloc jz,gch2
	xra a		;yes. return it and clear the pushback
	sta ungetl	;byte in C.CCC.
	mvi h,0
	ret

gch2:	push b
	mvi c,conin
	call bdos
	pop b
	cpi cntrlc	;control-C ?
	jz base		;if so, reboot.
	cpi 1ah		;control-Z ?
	lxi h,-1	;if so, return -1.
	rz
	mov l,a
	cpi cr		;carriage return?
	reloc jnz,gch3
	push b
	mvi c,conout	;if so, also echo linefeed
	mvi e,lf
	call bdos
	pop b
	mvi l,newlin	;and return newline (linefeed)..

gch3:	mvi h,0
	ret

	postlude getchar

;
; Kbhit:
;
;	int kbhit();
;
; Returns true if a character is present on the console input;
; else returns false.
;

	prelude	kbhit

	lda ungetl	;any character ungotten?
	mvi h,0
	mov l,a
	ora a
	rnz		;if so, return true
	push b
	mvi c,cstat	;else interrogate console status
	call bdos
	ani 1
	mov l,a		;return 1 if character ready, else 0
	mvi h,0
	pop b
	ret

	postlude kbhit

;
; Ungetch:
;
;	ungetch(c)
;	char c;
;
; Un-get a character by putting it at location "ungetl":
; Returns non-zero if there was already a character pushed
; back since the last getchar call.
;

	prelude	ungetch

	lda ungetl
	mov l,a
	push h
	call ma2toh
	sta ungetl
	pop h
	mvi h,0
	ret

	postlude ungetch


;
; Putchar:
;
;	putchar(c);
;
; Write a character to the console output. Turn "newline"
; (really linefeed) into a CR-LF combo. Also check if anything
; is present on the console input; if so, check to see if it is
; a control-C, and if so, reboot CP/M. (This allows a general
; interrupt during profuse unwanted output.)
;

	prelude putchar

	call ma1toh	;get character in A
	push b
	mvi c,conout
	cpi newlin	;newline?
	reloc jnz,put1	;if not, just go put out the character
	mvi e,cr	;else...put out CR-LF
	call bdos
	mvi c,conout
	mvi a,lf

put1:	mov e,a
	call bdos

put2:	mvi c,cstat	;now, is input present at the console?
	call bdos
	ani 1
	reloc jnz,put3
	pop b		;no...all done.
	ret

put3:	mvi c,conin	;yes. sample it (this will always echo the
	call bdos	;	character to the screen, alas)
	cpi cntrlc	;is it control-C?
	jz base		;if so, abort and reboot
	pop b		;else ignore it.
	ret

	postlude putchar

;
; Putch:
;
;	putch(c)
;	char c;
;
; Write a char to console output without testing
; for control-C on console input.
;

	prelude	putch

	call ma1toh
	push b
	mvi c,conout
	mov e,a
	cpi newlin		;newline?
	reloc jnz,putch1	;if not, just put out the character
	mvi e,cr		;if so, put out CR-LF
	call bdos
	mvi c,conout
	mvi e,lf
putch1:	call bdos
	pop b
	ret

	postlude putch


;
; Gets:
;
;	gets(buffer);
;
; Get a string from the console and put it and put it (null terminated)
; at the given buffer. The buffer should be several characters longer than
; the expected maximum length input line, since the BDOS call for getting
; a buffer is used...and it never hurts to overanticipate a user's verbosity!
;

	prelude	gets

	call ma1toh	;get addr of buffer
	push b		;save frame pointer
	mvi m,0ffh	;max length (assume user knows enough to declare
			;a big enough buffer...not that gets can KNOW how
			;big it is...
	mvi c,getlin
	xchg		;put buffer addr in DE
	push d		;save it
	push d		;a coupla times
	push d		;and once more
	call bdos	;get the input line
	mvi c,conout
	mvi e,lf	;put out a linefeed after the automatic cr
	call bdos
	pop h		;get back buffer address
	inx h		;point to returned char count
	mov b,m		;set B equal to char count
	inx h		;HL points to first char of line
	pop d		;DE points to start of buffer
copyl:	mov a,b		;done copying?
	ora a
	reloc jz,gets2	;if so, get out of loop
	mov a,m		;else copy another character
	stax d
	inx h
	inx d
	dcr b
	reloc jmp,copyl	;loop till all done
	
gets2:	xra a		;place terminating null into buffer
	stax d
	pop h		;pop start of buffer again, into HL
	pop b		;get back stack frame pointer
	ret		;and go home.	

	postlude gets


;
; Rand:
;
;	rand();
;
; Original random function, uses 32-bit seed at rseed:
;

	prelude rand

	lhld rseed
	xchg
	mvi a,48h
	ana e
	reloc jz,rand1
	reloc jpe,rand1
	stc
rand1:	lhld rseed+2
	mov a,h
	ral
	mov h,a
	mov a,l
	ral
	mov l,a
	shld rseed+2
	mov a,d
	ral
	mov h,a
	mov a,e
	ral
	mov l,a
	shld rseed
	mov a,h
	ani 7fh
	mov h,a
	ret

	postlude rand


;
; SRAND:
; 
;	srand(n);
;
; Initialize random number generator. If n==0, prints
; message and waits for a key; else, uses n as seed.
;

	prelude	srand

	call ma1toh
	mov a,h
	ora l
	reloc jz,srand2
	shld rseed
	shld rseed+2
	ret

srand2:	reloc <lxi d,>,stg1
	push b
	mvi c,9
	call bdos
	lxi h,0bdbdh
srand3:	push h
	mvi c,11
	call bdos
	pop h
	inx h
	inx h
	inx h
	ani 1
	reloc jz,srand3
	shld rseed
	shld rseed+2
	mvi c,conout
	mvi e,cr
	call bdos
	mvi c,conout
	mvi e,lf
	call bdos
	mvi c,conin	;clear the character
	call bdos
	pop b
	ret

stg1:	db 'Wait a few seconds, and type a CR: $'

	postlude srand


;
; Srand1:
;
;	srand1(string);
;
; New srand, which "hides" itself in a string prompt
;

	prelude	srand1,puts

	call ma1toh
	push h
	exrel call,puts	;print prompt string
	pop h
	push b
	lxi h,5678h
sr1a:	push h
	mvi c,cstat
	call bdos
	pop h
	inx h
	inx h
	inx h
	ani 1
	reloc jz,sr1a
	shld rseed
	shld rseed+2
	pop b
	ret

	postlude srand1


;
; Nrand:
;
; The new random number routine by Paul Gans
; Calling parameters: nrand(n [,s1, s2, s3]);
; 	where if n == -1 then s1,s2,s3 is the 48-bit seed;
;		 n == 0  then initialize like srand1
;		else return next value in sequence.
;

	prelude	nrand,puts

	call arghak
	lhld arg1	;get n (1st arg)
	mov a,h
	ana l
	cpi 255		;was it -1 (set seed) ?
	reloc jnz,nrand1
	lhld arg2	;copy seed
	reloc shld,seed
	lhld arg3
	reloc shld,seed+2
	lhld arg4
	reloc shld,seed+4	
	ret		;all done

nrand1:	push b
	mov a,h		;look at first arg again
	ora l
	reloc jnz,nrand3	;is it 0 (randomize) ?
	lhld arg2
	push h		;yes. print out string
	exrel call,puts	;call puts
	pop d
	lxi h,5a97h	;yes. start w/something odd
nrand2:	push h
	mvi c,cstat	;interrogate console status
	call bdos
	pop h
	inx h		;and keep it odd
	inx h		;and growing
	ani 1
	reloc jz,nrand2	;until user types something.
	reloc shld,seed	;then plaster the value all over the
	reloc shld,seed+2	;seed.
	reloc shld,seed+4
	pop b
	ret

nrand3:	reloc lda,seed	;now compute next random number. from this
	ori 1		; point on, the code is that of Prof. Paul Gans
	reloc sta,seed	;lsb of SEED must be 1
	
	mvi b,6		;clear 6 PROD bytes to 0
	reloc <lxi h,>,prod
randm1:	mvi m,0
	inx h
	dcr b
	reloc jnz,randm1

	lxi b,6		;set byte counter
randm2:	reloc <lxi h,>,plier-1
	dad b		;make addr of lsb of PLIER
	mov a,m		;PLIER byte
	push b		;save byte counter
	mvi b,8		;set bit counter

randm3:	mov d,a		;save PLIER byte
	reloc <lxi h,>,prod	;shift whole PROD left one bit
	mvi c,6
	xra a
randm4:	mov a,m		;get byte	
	ral		;shift left
	mov m,a		;put byte
	inx h
	dcr c
	reloc jnz,randm4

	mov a,d		;recover PLIER byte
	ral		;look at current high bit
	reloc jnc,randm6	;0 means no add cycle

	push psw	;add SEED to PROD
	xra a
	mvi c,6
	reloc <lxi h,>,prod
	reloc <lxi d,>,seed
randm5:	ldax d
	adc m
	mov m,a
	inx h
	inx d
	dcr c
	reloc jnz,randm5
	pop psw

randm6:	dcr b		;test bit counter
	reloc jnz,randm3	;go cycle more bits
	pop b		;recover byte counter
	dcr c		;test it
	reloc jnz,randm2	;go process more bytes

	mvi b,6		;complement PROD, add 1 to it,
	reloc <lxi h,>,seed	;and transfer it to SEED.
	reloc <lxi d,>,prod
	xra a
	cmc
randm7:	ldax d
	cma
	aci 0
	mov m,a
	inx h
	inx d
	dcr b
	reloc jnz,randm7

	dcx h		;put the two high order bytes
	mov a,m		;into HL for return to C, not
	ani 7fh		;neglecting to zero the high
	mov h,a		;order bit so a positive int
	reloc lda,seed+4	;is returned
	mov l,a
	pop b
	ret

plier:	db 0c5h,87h,1
	db 0eh,9ah,0e0h	

seed:	db 1,0,0,0,0,0

prod:	db 0,0,0,0,0,0

	postlude nrand

;
; Csw:
;
; Get the value at port 255 (console switch register)
;
	prelude	csw

	in 255
	mov l,a
	mvi h,0
	ret

	postlude csw

;
; Setmem:
;
;	setmem(addr,length,val);
;
; Fill a block of memory with a given constant
;

	prelude	setmem

	call arghak
	push b
	lhld arg2
	xchg
	lhld arg1
	lda arg3
	mov c,a
	inx d
setm2:	dcx d
	mov a,d
	ora e
	reloc jnz,setm3
	pop b
	ret

setm3:	mov m,c
	inx h
	reloc jmp,setm2

	postlude setmem

;
; Movmem:
;
; Move a block of memory, optimizing for Z-80 when
; possible and also insuring integrity of the data
; no matter WHAT the logistics of the source and
; destination addresses.
;
	prelude	movmem

	call arghak
	lhld arg3	;get block length
	mov a,h
	ora l
	rz		;do nothing if zero length
	push b
	mov b,h
	mov c,l		;set BC to length
	lhld arg2	;get dest addr
	xchg		;put in DE
	lhld arg1	;get source addr in HL
	reloc call,cmphd	;if source < dest, do tail-first
	reloc jc,tailf	;else do head-first

headf:	mvi a,2		;test for Z-80
	inr a
	reloc jpe,m8080h	;Z80?
	db 0edh,0b0h	;yes. do block move.
	pop b
	ret		;and done.

m8080h:	mov a,m
	stax d
	inx h
	inx d
	dcx b
	mov a,b
	ora c
	reloc jnz,m8080h
	pop b
	ret

tailf:	dcx b		;tail first. Compute new source
	dad b		;and destination addresses
	xchg
	dad b
	xchg
	inx b
	mvi a,2		;test for Z80
	inr a
	reloc jpe,m8080t	;Z80?
	db 0edh,0b8h	;yes. do block move.
	pop b
	ret

m8080t:	mov a,m
	stax d
	dcx h
	dcx d
	dcx b
	mov a,b
	ora c
	reloc jnz,m8080t
	pop b
	ret

cmphd:	mov a,h
	cmp d
	rnz
	mov a,l
	cmp e
	ret

	postlude movmem

;
; Call:
;
;	call(addr,a,h,b,d);
;
; Call a subroutine at a given location, passing values in CPU
; registers, and accept the value returned by the subroutine
; in HL as return value.
; (See also CALLA for the counterpart of this, that accepts the
; return value in A)
;
	prelude	call

	call arghak
	push b
	lhld arg5
	xchg
	lhld arg4
	mov b,h
	mov c,l
	lda arg2
	reloc <lxi h,>,call2
	push h
	lhld arg1
	push h
	lhld arg3
	ret

call2:	pop b
	ret

	postlude call

;
; Calla:
;
;	calla(addr,a,h,b,d);
;
; And here it is, the same routine as above except that the
; return value is expected in A instead of HL:
;

	prelude	calla

	call arghak
	push b
	lhld arg5	;get de value
	xchg
	lhld arg4	;get bc value
	mov b,h
	mov c,l
	lda arg2	;get a value
	reloc <lxi h,>,calla2	;get return address
	push h		;push it
	lhld arg1	;get address of routine
	push h
	lhld arg3	;get hl value	
	ret		;call routine
	
calla2:	mov l,a		;put A value in HL
	mvi h,0		;clear high byte
	pop b
	ret

	postlude calla

; Inp:
;
; 	char inp(port);
;
; Sample data at an input port:
;
	prelude	inp
	
	call ma1toh
	sta iohack+1	;store as arg to ram area input subroutine
	call iohack	;call the subroutine to get value
	mov l,a		;and put into HL
	mvi h,0
	ret

	postlude inp

;
; Outp:
;
;	outp(port,val);
;
; Output a byte to an output port:
;
	prelude	outp

	call ma1toh	;get port number
	sta iohack+4	;store as arg to ram area output subroutine
	call ma2toh	;get data byte
	call iohack+3	;output it
	ret

	postlude outp

;
; Peek:
;
;	peek(addr);
;
; Return the byte value of a memory location:
;
	prelude	peek

peek:	call ma1toh
	mov l,m
	mvi h,0
	ret

	postlude peek

;
; Poke:
;
;	poke(addr,val)
;
; Deposit a byte value at a memory location:
;
	prelude	poke

	call arghak
	lhld arg1
	lda arg2
	mov m,a
	ret

	postlude poke

;
; Sleep:
;
;	sleep(n);
;
; Sleep for a given number of tenths of a
; second (or twentieths on a Z80).
;
	prelude sleep

	call ma1toh
	push b
	inx h
sl1:	dcx h
	mov a,h
	ora l
	reloc jnz,sl1a
	pop b
	ret

sl1a:	lxi d,10000
sl2:	dcx d
	mov a,d
	ora e
	reloc jnz,sl2
	push h
	mvi c,cstat
	call bdos
	ani 1
	pop h
	reloc jz,sl1
	push h
	mvi c,conin
	call bdos
	cpi cntrlc
	jz base
	pop h
	reloc jmp,sl1

	postlude sleep

;
; Pause:
;
; Sleep until a character is typed
; (but don't sample the character)
;
	prelude pause

	push b
paus1:	mvi c,cstat
	call bdos
	ani 1
	reloc jz,paus1
	pop b
	ret

	postlude pause

;
; Setfcb:
;
; Function to perform the "setfcb" function on user
; supplied text and fcb addresses.
;
; NOTE THAT THE FCB MUST BE 36 BYTES LONG, SINCE THE
; RANDOM RECORD FIELD IS ALWAYS CLEARED FOR COMPATIBILITY
; WITH THE SPECIAL CP/M 2.x RANDOM RECORD CALLS.
;
; format:
;	setfcb(fcbaddr,filename)
;	char *fcbaddr, *filename;
;

	prelude	setfcb

	call arghak
	push b
	lhld arg2	;get pointer to name text
igsp:	mov a,m
	inx h
	cpi ' '		;space?
	reloc jz,igsp
	cpi tab		;tab?
	reloc jz,igsp
	dcx h
	xchg		;set DE pointing to 1st non-space char
	lhld arg1	;get --> fcb area
	call setfcb	; do it
	lxi h,0		;all OK.
	pop b
	ret

	postlude setfcb


;
; Read:
;
;	read(fd, buf, nbl)
;
; Reads nbl sectors, and fudges the next-sector
; byte in the fcb after encountering an EOF on an extent boundary,
; so "write" won't screw up in that special case.
;

	prelude	read
	
	call arghak
	lda arg1
	call fgfd
	jc error	;error if illegal fd
	mov a,m
	ani 2		;open for read?
	jz error	;error if not
	push b
	lda arg1
	call fgfcb
	shld tmp2	;tmp2 will hold dma addr
	lxi h,0		;count of # of successful sectors read
	shld tmp2a	; will be kept at tmp2a
read2:	lhld arg3	;done?
	mov a,h
	ora l
	reloc jz,read4

read2a:	lhld arg2	;else read another sector
	xchg		;DE is dma addr
	mvi c,sdma
	call bdos	;set DMA
	lhld tmp2
	xchg		;DE is fcb addr
	mvi c,reads
	push d		;save de so we can fudge nr field if
	call bdos	;we stop reading on extent boundary...
	pop d		; CP/M sucks!
	cpi 2
	pop b
	jz error	;if error, abort
	push b
	cpi 1
	reloc jnz,read6	;EOF?

read3:	lxi h,32	;yes. are we on extent boundary?
	dad d		;if so, adjust for CP/M's stupidity here
	mov a,m		;by turning an 80h sector count into 00h.
	cpi 80h
	reloc jnz,read4
	mvi m,0		;yes. reset nr to 0...CP/M leaves it at 80h!
read4:	lhld tmp2a
read5:	pop b
	ret

read6:	lhld arg3
	dcx h
	shld arg3
	lhld arg2
	lxi d,128
	dad d
	shld arg2
	lhld tmp2a
	inx h
	shld tmp2a
	reloc jmp,read2

	postlude read


;
; Write:
;
; Format:
;	write(fd, buf, nbl)
;	
; Writes nbl block of data from memory at buf to file having
; descriptor fd. File must have been opened for writing.
;

	prelude	write

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

writ1:	lhld arg3	;done yet?
	mov a,h
	ora l
	lhld tmp2a	;if so, return count
	reloc jz,writ3
	lhld arg2	;else copy next 128 bytes down to tbuff
	lxi d,tbuff	;80 for normal CP/M, else 4280
	mvi b,128
writ2:	mov a,m
	stax d
	inx h
	inx d
	dcr b
	reloc jnz,writ2
	shld arg2	;save -> to next 128 bytes
	lhld tmp2	;get addr of fcb
	xchg
	mvi c,writs	;go write
	call bdos
	ora a		;error?
	lhld tmp2a	;if so, return # of successfully written
	reloc jnz,writ3	;  sectors.
		
	inx h		; else bump successful sector count,
	shld tmp2a
	lhld arg3	; debump countdown,
	dcx h
	shld arg3
	reloc jmp,writ1	; and go try next sector
writ3:	pop b
	ret

	postlude write

;
; Open:
;
;	open(filename,mode)
;
; Open a file for raw (non-bufferred) read (0), write(1), or both(2).
;
	prelude	open

	call arghak
	xra a
	call fgfcb	;any fcb's free?
	jc error	;if not, error
	sta tmp
	xchg
	lhld arg1
	xchg
	push b
	call setfcb
	mvi c,openc
	call bdos
	cpi errorv	;successful open?
	pop b
	jz error	;if not, error
	lda tmp
	call fgfd	;get HL pointing to fd table entry
	lda arg2
	ora a		;open for read?
	mvi d,3
	reloc jz,open1
	dcr a
	mvi d,5
	reloc jz,open1	;write?
	dcr a
	jnz error	;else must be both or bad mode.
	mvi d,7
open1:	mov m,d
	lda tmp
	mov l,a
	mvi h,0
	ret

	postlude open

;
; Close:
;
;	close(fd);
;
; Close a file
; (jumps to the close routine built into C.CCC, the runtime package)
;
	prelude	close

	jmp close	;jump to the close routine in C.CCC

	postlude close


;
; Creat:
;
;	creat("filename");
;
; Create a new file on the filesystem,
; then, open it for output.
;
	prelude	creat,<unlink,open>

	call arghak
	lhld arg1
	push b
	push h
	exrel call,unlink	;erase any old versions of file
	pop d
	mvi c,creatc
	lxi d,fcb
	call bdos
	cpi errorv
	pop b
	jz error
	lxi h,1
	push h
	lhld arg1
	push h
	exrel call,open
	pop d
	pop d
	ret

	postlude creat


;
; Unlink:
; 
;	unlink("filename");
;
; Delete a file from the filesystem:
;
	prelude	unlink

	call ma1toh
	push b
	xchg	
	lxi h,fcb
	call setfcb
	mvi c,delc
	call bdos
	lxi h,0
	pop b
	ret

	postlude unlink


;
; Seek:
;
;	seek(fd, offset, origin);
;
; Seek to a particular sector in an open file, where the new sector
; address is:
;	offset		if origin == 0
;	current+offset	if origin == 1
; Returns -1 when asked to seek into non-existant extent, but seeking
; into unwritten portion of current extent is allowed (although subsequent
; read and write calls will return errors.)
;
	prelude	seek,tell

	call arghak	;copy arguments to args area
	lda arg1
	call fgfcb
	jc error	;error if file not open
	push b
	push h		;save fcb address

	lhld arg1
	push h
	exrel call,tell	;get r/w pointer position for the file
	pop d

	xchg		;put present pos in DE
	lda arg3
	lhld arg2	;get offset in HL
	ora a		;absolute offset?
	reloc jz,seek2	;if so, offset is new position
	dad d		;else add offset to current position
seek2:	mov a,l		;convert to extent and sector values
	rlc
	mov a,h
	ral
	ani 7fh
	sta tmp
	xthl
	lxi d,12
	push h
	dad d
	cmp m		;jumping over extent boundary?
	reloc jz,seek5
	xthl		;yes.
	xchg
	mvi c,closec	;close old extent
	push d
	call bdos
	pop d
	pop h
	cpi errorv
	reloc jnz,seek4
seek3:	pop d
	pop b
	jmp error

seek4:	lda tmp
	mov m,a
	push d
	mvi c,openc	;and open new one.
	call bdos
seek5:	pop d
	cpi errorv
	reloc jz,seek3
	lxi h,32	;and set nr field
	dad d
	pop d
	mov a,e
	ani 7fh
	mov m,a
	xchg		;return new sector # in HL
	pop b
	ret

	postlude seek

;
; Tell:
;
;	tell(fd);
;
; Return position of r/w pointer associated with a particular file:
;
	prelude	tell

	call ma1toh	;get fd value in A
	call fgfcb
	jc error
	push b
	lxi d,12
	dad d
	mov b,m		;put extent # in B
	lxi d,20
	dad d
	mov c,m		;put sector # in C
	xra a		;rotate extent right one bit, old b0 --> Carry
	mov a,b
	rar
	mov h,a		;rotated value becomes high byte of tell position
	mvi a,0		;rotate b0 of extent into A
	rar
	mov b,a		;save rotated extent number in B
	add c		;add rotated extent number to sector number
	mov l,a		;and result becomes low byte of tell position
	mov a,c		;if both rotated extent # and sector # has bit 7 hi,
	ana b		;then the sum had an overflow, so...
	reloc jp,tell2
	inr h		;bump position number by 256
tell2:	pop b		;and all done.
	ret

	postlude tell

;
; Rename:
;
;	rename(old,new)
;
; Function to rename a file:
;
	prelude	rename

	call arghak
	push b
renam:	lhld arg1
	xchg
	reloc <lxi h,>,wfcb
	call setfcb
	lhld arg2
	xchg
	reloc <lxi h,>,wfcb+16
	call setfcb
	reloc <lxi d,>,wfcb
	mvi c,renc
	call bdos
	pop b
	cpi errorv
	jz error
	lxi h,0
	ret

wfcb:	ds 53

	postlude rename

;
; Fabort:
;
;	fabort(fd);
;
; Free up the file descriptor given as argument, or return
; -1 if not open:
;
	prelude	fabort

	call ma1toh
	call fgfd
	jc error
	mvi m,0		;clear entry in fd table
	lxi h,0
	ret

	postlude fabort

;
; Fcbaddr:
;
; Return address of fcb associated with the file associated
; with the fd given as arg:
;
	prelude	fcbaddr

	call ma1toh
	call fgfd	;is it an open file?
	jc error
	call ma1toh
	call fgfcb	;get fcb addr in HL
	ret

	postlude fcbaddr  


;
; Exit:
;
;	exit();
;
; Close all open files and reboot (jumps to C.CCC exit routine...)
;
	prelude exit

	jmp exit

	postlude exit

;
; Bdos:
;
;	bdos(c,de)
;
; Call to bdos routine c, with BC set to c, DE set to de..
;
; Returns H equal to the value returned by the BDOS in B,
; and L equal to the value returned by the BDOS in A.
;
; (Note: User's Guide incorrectly says return value is 0-255)
;
	prelude	bdos
	
	call arghak	
	push b
	lda arg1	;get C value
	mov c,a
	lhld arg2	;get DE value
	xchg		;put in DE
	call bdos	;make the bdos call
	mov l,a		;move return value from A into HL
	mov h,b
	pop b
	ret		;and return to caller

	postlude bdos

;
; Bios:
;
;	bios(n,c)
;
; Call to bios jump table routine n, with BC set to c. n=0 for boot,
; n=1 for wboot, n=2 for const, etc.
;
	prelude	bios
	
	call arghak	
	push b
	lhld base+1	;get addr of jump table + 3
	dcx h		;set to addr of first jump
	dcx h
	dcx h
	lda arg1	;get function number (1-85)
	mov b,a		;multiply by 3
	add a
	add b
	mov e,a		;put in DE
	mvi d,0
	dad d		;add to base of jump table
	push h		;and save for later
	lhld arg2	;get value to be put in BC
	mov b,h		;and put it there
	mov c,l
	reloc <lxi h,>,retadd	;where call to bios will return to
	xthl		;get address of vector in HL
	pchl		;and go to it...
retadd:	mov l,a		;all done. now put return value in HL
	mvi h,0
	pop b
	ret		;and return to caller

	postlude bios


;
; Codend:
;
; Returns address of byte after last byte of compiled code:
;
	prelude	codend

	lhld codend
	ret

	postlude codend

;
; Externs:
;
; Returns address of start of external data area:
;
	prelude	externs

	lhld extrns
	ret

	postlude externs

;
; Endext:
;
; Returns address of byte following the end of the external data area:
;
	prelude	endext

	lhld freram
	ret

	postlude endext

;
; Topofmem:
;
; Returns address of last byte of available user ram:
;
	prelude	topofmem  

	lhld base+6
	dcx h
	ret

	postlude topofmem 

;
; Exec:
;
; A simpler chaining function, which doesn't support arg
; passing:
;
	prelude	exec

	call arghak
	push b
	lhld arg1
	xchg
	lxi h,-60
	dad sp
	push h
	push h
	push h
	call setfcb
	pop h
	lxi b,9
	dad b
	mvi m,'C'
	inx h
	mvi m,'O'
	inx h
	mvi m,'M'
	pop d
	mvi c,openc
	call bdos
	cpi errorv
	reloc jnz,noerr
	pop h
	pop b
	jmp error

noerr:	reloc <lxi d,>,code
	lxi h,tbuff
	xra a
	mov m,a		;zero tbuff
	inx h
	mov m,a		; and tbuff+1
	inx h

	mvi b,42	;length of loader code segment
exec2:	ldax d		;copy loader down to tbuff+2
	mov m,a
	inx h
	inx d
	dcr b
	reloc jnz,exec2

	pop b			;get fcb pointer in BC
	lda tpa			;sequence to reset SP
	cpi 2ah			;are we using an lhld?
	lhld base+6
	reloc jz,go1		;if so, use regular bdos addr
	lhld tpa+1		;else get special SP value
go1:	sphl
	lxi h,base
	push h			;set base of ram as return addr
	jmp tbuff+2		;(`code:')

code:	lxi d,tpa
loop:	push d
	push b			;save fcb pointer
	mvi c,sdma
	call bdos
	pop d			;get fcb pointer in DE
	push d			;and resave it
	mvi c,reads
	call bdos
	pop b			;get fcb pointer back in BC
	pop d
	ora a			;end of file?
	jz tbuff+24h		;if not, get another sector (jz `loop1:')
	mvi c,sdma		;reset DMA pointer (stupid CP/M transients
	lxi d,tbuff		;        ASSUME the DMA pointer is at 80h)
	call bdos
	jmp tpa			;and go run the program

loop1:	lxi h,80h
	dad d
	xchg
	jmp tbuff+5		;loop address (`loop:')

	postlude exec

;
; Execl:
;
; Function to chain to another C-generated COM file, with
; text argument passing.
;
	prelude	execl

	call arghak
	push b
	lhld arg1
	xchg
	lxi h,-60	;compute &nfcb for use here
	dad sp
	push h		; save for much later (will pop into BC)
  	push h		;make a few copies for local use below
	push h
	call setfcb	;set up COM file for execl-ing
	pop h		;get new fcb addr
	lxi b,9		;set extension to COM
	dad b
	mvi m,'C'
	inx h
	mvi m,'O'
	inx h
	mvi m,'M'
	pop d		;get new fcb addr again
	mvi c,openc	;open the file for reading
	call bdos
	cpi errorv
	reloc jnz,noerrr
	pop h
	pop b
	jmp error

noerrr:	lhld arg2	;stick first parameter string
	mov a,h
	ora l
	reloc jnz,excl0
	lxi d,arg2
	push d
	lxi h,fcb
	call setfcb
	pop h
	reloc jmp,excl0a

excl0:	xchg		;into first default fcb slot
	lxi h,fcb
	call setfcb
	lhld arg3	;and stick second param string
	mov a,h
	ora l
	reloc jnz,excl0a
	lxi h,arg3

excl0a:	xchg		;into second default fcb slot
	lxi h,fcb+16
	call setfcb	
	lxi d,tbuff+1   ;now construct command line:
	xra a		;  zero tbuff+1 just in case there
	stax d		;  are no arg strings
	lxi h,arg2	;pointer to 1st arg string pointer
	mvi b,0		;char count for com. line buf.
excl1:	push h		;and construct command line
	mov a,m		;get addr of next arg string pointer
	inx h
	mov h,m
	mov l,a		;0000 indicates end of list.
	ora h		;end of list?
	reloc jz,excl3

	mvi a,' '	;no. install next string
	dcx h
excl2:	reloc call,mpuc	;convert to upper case for command line buffer
	stax d
	inx d
	inr b
	inx h
	mov a,m
	ora a		;end of string?
	reloc jnz,excl2
	pop h		;yes.
	inx h		;bump param pointer
	inx h	
	reloc jmp,excl1	;and go do next string

mpuc:	cpi 'a'		;convert character in A to upper case
	rc
	cpi 'z'+1
	rnc
	sui 32
	ret

excl3:	pop h		;clean up stack
	lxi h,tbuff	;set length of command line
	mov m,b		;at location tbuff

excl3a:	reloc <lxi d,>,code0	;copy loader down to end of tbuff
	lxi h,tpa-42
	mvi b,42	;length of loader
excl4:	ldax d
	mov m,a
	inx d
	inx h
	dcr b
	reloc jnz,excl4

	pop b			;get back working fcb pointer
	lda tpa			;sequence to reset SP
	cpi 2ah			;are we using an lhld?
	lhld base+6
	reloc jz,go		;if so, use regular bdos addr
	lhld tpa+1		;else get special SP value
go:	sphl
	lxi h,base
	push h			;set base of ram as return addr
	jmp tpa-42		;(go to `code0:')

;
; This loader code is now: 42 bytes long.
;

code0:	lxi d,tpa		;destination address of new program
code1:	push d			;push dma addr
	push b			;push fcb pointer
	mvi c,sdma		;set DMA address for new sector
	call bdos
	pop d			;get pointer to working fcb in DE
	push d			;and re-push it
	mvi c,reads		;read a sector
	call bdos
	pop b			;restore fcb pointer into BC
	pop d			;and dma address into DE
	ora a			;end of file?
	jz tpa-8		;if not, get next sector (goto `code2:')
	mvi c,sdma		;reset DMA pointer
	lxi d,tbuff
	call bdos
	jmp tpa			;and go invoke the program

code2:	lxi h,80h		; bump dma address
	dad d
	xchg
	jmp tpa-39 		;and go loop (at code1)

	postlude execl

;
; Little CRL function to do an "execv" in terms of "execl"...
;
; Usage:
;	execv(prog,args)
;	char *prog, **args;
;
; prog points to the name of the command to be chained to, and args
; points to an array of pointers to the arguments--the last pointer
; must be null. If prog.COM does not exist, the message "Broken pipe"
; will be printed on the console (since the most common use of this
; function is when processing pipes with DIO.C.) Note that the "putc"
; library function MUST recognize a special I/O buffer value of 4 as
; a direct BDOS console output operation (pre-1.44 versions do not.)
;

	prelude execv,<execl,fprintf,exit>

	call arghak
	lhld arg2		;get -> arg list
	mvi b,0			;clear arg count
execv1:	inr b			;bump arg count
	mov e,m
	inx h
	mov d,m
	inx h
	mov a,d
	ora e			;last arg?
	reloc jnz,execv1	;if not, keep looking for last one

	dcx h			;HL -> next to last arg
execv2:	mov d,m
	dcx h
	mov e,m			;look at next previous arg
	dcx h
	push d			;push arg
	dcr b			;done with all args?
	reloc jnz,execv2	;if so, go do it!

execv3:	lhld arg1		;get program name
	push h			;save as first arg to execl
	exrel call,execl	;go do it; shouldn't come back.
	
	reloc <lxi h,>,errmsg
	push h
	lxi h,4			;direct console output via "putc"
	push h
	exrel call,fprintf
	exrel jmp,exit

errmsg:	db 'Broken pipe',cr,lf,0
	
	postlude execv


;
; Sbrk:
; 
; sbrk(n)
;
; Allocate n bytes of ram and return a pointer to the base of the
; allocated area. Update allocp by n, and make sure that the the new
; value of allocp is less than (SP - alocmx). If it isn't, return -1. If it
; is, just return the address of the allocated area.
;

	prelude	sbrk

	call ma1toh	;get # of bytes needed in HL
	xchg		;put into DE
	lhld allocp	;get current allocation pointer
	push h		;save it
	dad d		;get tentative last address of new segment
	reloc jc,brkerr	;better not allow it to go over the top!
	dcx h
	xchg		; now last addr is in DE

	lhld alocmx	;get safety factor
	mov a,h		;negate
	cma
	mov h,a
	mov a,l
	cma 
	mov l,a		
	inx h
	dad sp		;get HL = (SP - alocmx)

	reloc call,cmpdh  ;is DE less than HL?
	reloc jnc,brkerr  ;if not, can't provide the needed memory.
	xchg		;else OK.
	inx h
	shld allocp	;save start of next area to be allocated
	pop h		;get pointer to this area
	ret		;and return with it.

brkerr:	pop h		;clean up stack
	jmp error	;and return with -1 to indicate can't allocate.

cmpdh:	mov a,d
	cmp h
	rc
	rnz
	mov a,e
	cmp l
	ret

	postlude sbrk

;
; Rsvstk:
;
; rsvstk(nbytes)
;
; Makes sure that "sbrk" never allocates storage closer than "nbytes"
; bytes to the current stack top. 
;

	prelude rsvstk

	call ma1toh	;get the value to reserve
	shld alocmx	;and set new safety factor
	ret

	postlude rsvstk

	end
