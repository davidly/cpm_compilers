;
; TITLE		patch for speed.com and fast.com for
;		skew factor of 3
; FILENAME	SKEW3PAT.ASM
; AUTHOR	Robert A. Van Valzah  11/19/79
;
	ORG	139H		;track buffer skew table
	DB	24, 21, 18, 15
	DB	12, 09, 06, 03
	DB	26, 23, 20, 17
	DB	14, 11, 08, 05
	DB	02, 25, 22, 19
	DB	16, 13, 10, 07
	DB	04, 01
	DB	0		;end of table marker
;
	ORG	174H		;directory buffer skew table
	DB	15, 09, 03, 23
	DB	19, 13, 07, 02
	DB	25, 21, 17, 14
	DB	11, 08, 05, 01
	DB	0		;end of table marker
;
	end
