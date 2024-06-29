/*		*/
CHAIN(NAME,PAR)
CHAR *NAME, *PAR;
{
   STATIC INT I;
   STATIC CHAR *PTR;
   IF (STRLEN(PAR) > 0X7E)
	{ PUTS ("CHAIN: PARAMETERLISTE ZU LANG");
	EXIT();
	}
   CLOSAL();
   FOR (I= 0; I < 32; I++)
	((CHAR *) 0X5C) [I] = 0;
   PTR= NGET(PAR,0X5C);
   NGET(PTR,0X6C);
   STRCPY(0X81,PAR);
   *(CHAR *) 0X80= STRLEN(PAR);

   ;

#ASM
BDOS	EQU 0005H
TPA	EQU 0100H
ENDCOM	EQU 0
;
	LXI	H,2
	DAD	SP
	MOV	E,M
	INX	H
	MOV	D,M
	LXI	H,PBASE+FCBF1-TPA
	PUSH	H
	PUSH	D	
	CALL	NAMEIN
	POP	B
	POP	B
	LXI	D,TPA
	LXI	H,PBASE
	LXI	B,ENDPROG-ANFPROG
ANLOP:
	MOV	A,M
	STAX	D
	INX	H
	INX	D
	DCX	B
	MOV	A,B
	ORA	C
	JNZ	ANLOP
	JMP	TPA
PBASE:
	.PHASE	TPA
ANFPROG:
	JMP	DOFILE
JBASE:
	DW 0
FCBF1:
 DB 0,'        ','   ',0,0,0,0
 DB 0,0,0,0,0,0,0,0
 DB 0,0,0,0,0,0,0,0
CR:
 DB 0,0,0,0
DOFILE:
	LHLD	6
	DCX	H
	SPHL
	LXI	B,-40H
	DAD	B
	SHLD	JBASE
	CALL	OPFIL1
	JZ	NOFIL
	XRA	A
	STA	CR
	LXI	H,TPA+ENDPROG-ANFPROG
LOOP:	PUSH	H
	XCHG
	CALL	SETDMA
	LXI	D,FCBF1
	CALL	FREAD
	JNZ	WEITER	
	LHLD	JBASE
	XCHG
	POP	H	
	LXI	B,0100H
	DAD	B	
	MOV	A,L
	SUB	E	
	MOV	A,H
	SBB	D	
	JNC	BADLOA
	LXI	B,-80H
	DAD	B
	JMP	LOOP
WEITER:
;	DCR	A	
;	JNZ	BADLOA
	CALL	S80DMA
	LHLD	JBASE
	SHLD	JMPAD+1
	LXI	D,KMOV
	MVI	B,KMOVE-KMOV
LOP2:
	LDAX	D
	MOV	M,A
	INX	H
	INX	D
	DCR	B
	JNZ	LOP2
	LXI	H,0	
	XTHL		
	PUSH	H
	LHLD	JBASE
	XTHL	
	LXI	B,-ENDPROG
	DAD	B
	MOV	B,H
	MOV	C,L
	LXI	D,TPA
	LXI	H,TPA+ENDPROG-ANFPROG
	RET
KMOV:
	MOV	A,M
	STAX	D
	INX	H
	INX	D
	DCX	B
	MOV	A,B
	ORA	C
JMPAD:
	JNZ	0
	JMP	TPA
KMOVE	EQU $

BADLOA:
	LXI	D,BLOATEXT
PRINT:
	MVI	C,9
	CALL	BDOS
	JMP	ENDCOM
BLOATEXT:
 DB 0DH,0AH,'CHAIN: PROGRAMM ZU GROSS','$'
NOFIL:
	LXI	D,NFTEXT
	JMP	PRINT
NFTEXT:
 DB 0DH,0AH,'CHAIN: PROGRAMM NICHT VORHANDEN','$'
OPFIL1:
	LXI	D,FCBF1
	MVI	C,0FH
	CALL	BDOS
	INR	A
	RET
S80DMA:
	LXI	D,0080H
SETDMA:
	MVI	C,1AH
	JMP	BDOS
FREAD:
	MVI	C,14H
	CALL	BDOS
	ORA	A	
	RET	
ENDPROG	EQU	$
	.DEPHASE
#ENDASM
}
/*		*/
STATIC NGET(NAM,ZIEL)
CHAR *NAM, *ZIEL;
{
   INT HNAM[128];
   STATIC CHAR *RPTR;
   NAMEIN ("        .   ",ZIEL);
   WHILE (ISSPACE(*NAM))
	++NAM;
   RPTR= HNAM;
   WHILE (! ISSPACE(*NAM))
	   { IF (! *NAM)
		BREAK;
	   *RPTR++ = *NAM++;
	   }
   *RPTR= 0;
   NAMEIN(HNAM,ZIEL);
   RETURN NAM;
}
	BDOS
FREAD:
	MVI	C,14H
	CALL	BDOS
	ORA	A	
	RET	
ENDPROG	EQU	$
	.DEPHASE
#ENDASM
}
/*		*/
STATIC NGET(NAM,ZIEL)
CHARееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееее