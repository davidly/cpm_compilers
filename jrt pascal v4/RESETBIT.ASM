;resetbit.asm
;external procedure which reset bit in a byte
;
; procedure resetbit ( var x : char; bit : integer );
;		extern;
; bit# in range 0..7
;
;entry code
	db 95,6,0	;int vmcode
	db 92		;lpn vmcode
	db 0		;mode vmcode
;on entry  bc=wtos  de=wb  hl=wbase
;
;get bit# in b_reg,  addr(x) in hl,  x into c_reg
resetbit xchg		;hl=wb
	dcx h! dcx h! dcx h! dcx h
	mov b,m		;bit#
	dcx h! mov d,m! dcx h! mov e,m ;addr(x)
	xchg		;hl=addr(x)
	mov c,m		;c=x
;create mask
	inr b		;incr loop count
	mvi a,0feh
loop	rrc
	dcr b
	jnz loop
;a=mask  c=byte
	ana c
	mov m,a		;store byte
	ret
;
	end
