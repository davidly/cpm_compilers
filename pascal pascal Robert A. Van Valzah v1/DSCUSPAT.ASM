;
; TITLE		PATCH FOR FAST.COM AND SPEED.COM FOR DOUBLE
;		DENSITY, MORROWS DISCUS
; FILENAME	DSCUSPAT.ASM
; AUTHOR	Robert A. Van Valzah   11/25/79
;		WITH INFO FROM Tom DiGate
;
;
; TRACK BUFFER SECTOR ORDER TABLE
;
	ORG	139H		;PATCH ADDRESS
	db	30h, 2fh ,2ah, 29h
	db	24h, 23h, 1eh, 1dh
	db	18h, 17h, 12h, 11h
	db	0ch, 0bh, 06h, 05h
	db	34h, 33h, 2eh, 2dh
	db	28h, 27h, 22h, 21h
	db	1ch, 1bh, 16h, 15h
	db	10h, 0fh, 0ah, 09h
	db	04h, 03h, 32h, 31h
	db	2ch, 2bh, 26h, 25h
	db	20h, 1fh, 1ah, 19h
	db	14h, 13h, 0eh, 0dh
	db	08h, 07h, 02h, 01h
	db	0		;END-OF-TABLE MARKER
;
; DIRECTORY BUFFER SECTOR ORDER TABLE
;
;
	org	174h
	db	24, 23, 06, 05
	db	40, 39, 22, 21
	db	04, 03, 38, 37
	db	20, 19, 02, 01
	db	0		;end-of-table marker
;
	END
