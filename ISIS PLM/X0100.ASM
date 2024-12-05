$title	('PRL Externals')
	name	x0100
	CSEG
offset	equ	0000h

mon1	equ	0005h+offset
mon2	equ	0005h+offset
mon2a	equ	0005h+offset
mon3 	equ	0005h+offset
	public	mon1,mon2,mon2a,mon3
cmdrv	equ	0050h+offset
fcb	equ	005ch+offset
pass0	equ	0051h+offset
len0	equ	0053h+offset
fcb16	equ	006ch+offset
pass1	equ	0054h+offset
len1	equ	0056h+offset
tbuff	equ	0080h+offset
	public	cmdrv,fcb,pass0,len0
	public	fcb16,pass1,len1,tbuff
bdisk	equ	0004h+offset
maxb	equ	0006h+offset
buff	equ	0080h+offset
boot	equ	0000h+offset
	public	bdisk,maxb,buff,boot
	END
