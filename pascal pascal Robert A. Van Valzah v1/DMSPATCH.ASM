;
; TITLE		PATCH FOR FAST.COM FOR DOUBLE DENSITY, DIGITAL MU SYSTEMS
; FILENAME	DMSPATCH.ASM
; AUTHOR	Robert A. Van Valzah   5/23/79
;
;
; TRACK BUFFER SECTOR ORDER TABLE
;
	ORG	139H		;PATCH ADDRESS
	DB	50, 32
	DB	14, 54, 36, 18
	DB	58, 40, 22, 04
	DB	44, 26, 08, 48
	DB	30, 12, 52, 34
	DB	16, 56, 38, 20
	DB	02, 42, 24, 06
	DB	46, 28, 10, 41
	DB	23, 05, 45, 27
	DB	09, 49, 31, 13
	DB	53, 35, 17, 57
	DB	39, 21, 03, 43
	DB	25, 07, 47, 29
	DB	11, 51, 33, 15
	DB	55, 37, 19, 01
	DB	0		;END-OF-TABLE MARKER
;
; DIRECTORY BUFFER SECTOR ORDER TABLE
;
	DB	32, 14, 18, 31
	DB	13, 17, 30, 12
	DB	16, 29, 11, 15
	DB	28, 10, 23, 05
	DB	27, 09, 22, 04
	DB	26, 08, 21, 03
	DB	25, 07, 20, 02
	DB	24, 06, 19, 01
	DB	0		;END-OF-TABLE MARKER
;
	END
