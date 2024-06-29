
/*MI - C  v-3.183  (C) COPYRIGHT  G. KERSTING / H. ROSE, 1983*/

TOUPPER(C)
INT C;
{
#IFNDEF VASM
 IF (C >= 'a' && C <= 'z')
  RETURN C - 0X20;
 RETURN C;
#ELSE	VASM
#ASM
	LXI	H,2		
	DAD	SP
	MOV	E,M		
	INX	H
	MOV	A,M		
	MOV	D,A
;
	XCHG
	ORA	A		
	RNZ			
	MOV	A,L		
	CPI	61H		
	RC			
	CPI	7BH		
	RNC			
	SUI	20H		
	MOV	L,A
#ENDASM
#ENDIF
}
