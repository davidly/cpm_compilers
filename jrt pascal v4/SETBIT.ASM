;setbit.asm
;external procedure which sets a bit on in a byte
;
; procedure setbit ( var x : char; bit : integer );
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
setbit	xchg		;hl=wb
	dcx h! dcx h! dcx h! dcx h
	mov b,m		;bit#
	dcx h! mov d,m! dcx h! mov e,m ;addr(x)
	xchg		;hl=addr(x)
	mov c,m		;c=x
;create mask
	inr b		;incr loop count
	mvi a,1
loop	rrc
	dcr b
	jnz loop
;a=mask  c=byte
	ora c
	mov m,a		;store byte
	ret
;
	end
