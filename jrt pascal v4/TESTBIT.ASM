;testbit.asm
;external function which returns bit value of a byte
;
; function testbit ( x : char; bit : integer ):
;		boolean; extern;
;
; bit number is in range 0..7
;
;entry code
	db 95,6,0	;int vmcode
	db 92		;lpn vmcode
	db 0		;mode vmcode
;on entry  bc=wtos  de=wb  hl=wbase
;
;get bit# into b_reg and x into a_reg
testbit	xchg		;hl=wb
	dcx h! dcx h! dcx h! dcx h ;point to bit lownib
	mov b,m		;low byte of bit
	dcx h! mov a,m	;x
	inr b
;shift loop
loop	rlc
	dcr b
	jnz loop
	jc true		;bit is set
;false : bit is zero
	dcx h! mvi m,0! dcx h! mvi m,0
	ret
;true : bit is one
true	dcx h! mvi m,0! dcx h! mvi m,1
	ret
;
	end
