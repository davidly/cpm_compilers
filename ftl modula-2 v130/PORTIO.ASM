;
;	Portio support routines - see Portio.def
;
;	Copyright (C) Dave Moore Sept 1986
;
	label		;in
	pop	hl	;return address
	pop	bc	;port number
	pop	de	;cut back result area
	in	e,(c)	;get byte
	ld	d,0	;clear high byte
	push	de
	jp	(hl)
	label		;Out
	pop	hl	;return address
	pop	de	;value to out
	pop	bc	;port address
	out	(c),e
	jp	(hl)
	label		;Disable Interrupts
	di
	ret
	label		;Enable Interrupts
	ei
	ret
	label		;set mode2 base
	pop	hl	;return address
	pop	de	;base address
	ld	a,d
	ld	i,a	;set interrupts address
	ret
	end

	��r�*ˡ 	�^��V�����1��	�^  s�,���+�|����"ˡ�C����P�	����t�	�! �!�