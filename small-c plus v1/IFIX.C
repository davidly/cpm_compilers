#include <stdio.h>
#include "float.h"
#asm
;
;	convert the floating point number in FA
;	to an integer in hl  (rounds toward negative numbers)
;
QIFIX:	CALL	QFLOOR		;take floor first
	LD	HL,0		;initialize the result
	LD	A,(FA+5)	;get the exponent
	LD	B,A		;  and save it
	OR	A
	RET	Z		;z => number was zero
	LD	HL,(FA+3)	;get most significant bits
	LD	C,H		;save sign bit (msb)
	LD	A,B		;get exponent again
	CP	80H+16
	JP	M,IFIX5		;m => fabs(fa) < 32768
	JP	NZ,OFLOW	;nz => fabs(fa) > 32768
;				(overflow)
	LD	A,H
	CP	80H
	JP	NZ,OFLOW	;nz => fa isn't -32768
	LD	A,L
	OR	A
	JP	NZ,OFLOW	;nz => overflow
	RET			;return -32768.
;
IFIX5:	SET	7,H		;restore hidden bit
IFIX6:	SRL	H		;shift right (0 fill)
	RR	L		;shift right (cy fill)
	INC	A
	CP	16+80H
	JR	NZ,IFIX6	;nz => haven't shifted enough
	RL	C
	RET	NC		;nc => positive number
	EX	DE,HL
	LD	HL,1		;compensate for cy bit
	SBC	HL,DE		;negate result
	RET
#endasm
