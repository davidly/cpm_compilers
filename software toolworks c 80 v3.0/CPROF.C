/* CPROF - Profile library and print routines for C/80.

	8/11/83 - C/80 3.0 version
	2/26/82 - C/80 2.0 version
	9/23/81 - M80 compatibility.
	1/7/81 - add CP/M distinction; sort printout by time
	9/6/80 - add percentages of runtime
	4/13/80 - compile with c -l32600 */

#define CPM 1			/* Defined for CP/M, undefined for HDOS */

/* To generate version which does not use in-memory clock, delete
	following 5 lines, and recompile by "c -l32600 cprof"
	(omit the -l for M80 compatibility).  For non-Heath/Zenith
	systems with clocks, code may be modified by changing all
	references to TICCNT. */

#ifdef CPM
#define TICCNT 11
#else
#define TICCNT 8219
#endif

int *LINKPT -1; 		/* Chain of routines */

/* Routines to handle call and return */
#asm
; CPROF - C/80 Execution Profile (8/11/83)
;  Note - for use on other than Heath/Zenith systems,
;	CPROF.ASM must be regenerated.	See C/80 documentation.
CURRTN: DW 0		;CURRENT RTN
CALLTP: DW 0		;TEMP FOR TIME
CALLED: DW 0		;HOLDS RTN CALLED
FIRSTM: DB 0		;FIRST TIME FLAG

CALL::	DS 0
#ifdef TICCNT
#ifdef CPM
	LDA FIRSTM
	XRI 1
	JZ CALL1
	STA FIRSTM
#endif
	LXI H,0
	SHLD TICCNT
CALL1:	LHLD TICCNT
	SHLD CALLTP
#endif
	POP H
	MOV A,M
	STA CALLED
	INX H
	MOV A,M
	STA CALLED+1
	INX H
	MOV A,M
	STA CURRTN
	INX H
	MOV A,M
	STA CURRTN+1
	INX H
	PUSH H		;FIX RETURN ADDRESS
	PUSH B
	PUSH D
	CALL SCORET
	LHLD CALLED
	PUSH H
	LXI H,exit	;CHECK IF QUITTING
	CALL e.
	CNZ PrinPr
	POP D
	POP B
	LHLD CALLED
	PCHL		;CALL ROUTINE

RET::	XTHL		;SAVE RETURN VALUE
	PUSH B
	PUSH D
#ifdef TICCNT
	PUSH H
	LHLD TICCNT
	SHLD CALLTP
	POP H		;GET CURRENT SUBR
#endif
	CALL h.##
	SHLD CURRTN
	CALL SCORET
	PUSH H		;INCREMENT COUNT
	CALL h.
	INX H
	CALL q.##
	LHLD CURRTN
	PUSH H
	LXI H,main	;IF RETURN FROM MAIN
	CALL e.##
	CNZ PrinPr	 ;PRINT SUMMARY
	POP D
	POP B
	POP H		;RESTORE RETURN VAL
	RET

SCORET: LHLD CURRTN
	DCX H		;PREPARE TO STORE VALUES
	DCX H
	PUSH H		;PUSH ADDRESS OF COUNT
	DCX H
	DCX H
	PUSH H		;ADDRESS OF TIME
	PUSH H
	DCX H
	DCX H
	PUSH H		;GET PTR TO LINK
	CALL h.
	MOV A,H 	;CHECK LINK=0?
	ORA L
	JNZ CALL2	;YES - ADD TO CHAIN
	LHLD LINKPT
	XCHG
	LHLD CURRTN	;IF NO LINK,
	SHLD LINKPT	;LINK IT IN
	XCHG
CALL2:	CALL q.
	POP H		;ADD TO TIME
	CALL h.
	XCHG
	LHLD CALLTP
	DAD D
	CALL q.
#ifdef TICCNT
	LXI H,0 	;ERASE TICCNT
	SHLD TICCNT
#endif
	POP H		;GET ADDR OF COUNT
	RET		;AND RETURN
#endasm
PrinPr() {
	static char *p,*besticks,*n;
	static int *q,time,count,*best;
	static unsigned totime;
#ifdef TICCNT
	for (p="ROUTINE\tCALLS\tTICKS\t% TIME (Approx.)\n"; *p; putchar(*p++));
#else
	for (p="ROUTINE\tCALLS\n"; *p; putchar(*p++));
#endif
	totime = 0;
	for (q = LINKPT; q != -1; q = q[-3]) {
		if (0100000 & (time = 100 + q[-2]))
			{ totime =+ 164; time =& 077777; }
		totime =+ time / 200; }
	for (;;) {
		for (best = besticks = 0, q = LINKPT; q != -1; q = q[-3]) {
			n = q[-2];			/* Find highest time */
			if (q[-1]) if (n >= besticks) {
				besticks = n;
				best = q;
			}	}
		if (best == 0) break;			/* Quit if all out */
		count = *--best;			/* Print it. */
		*best = 0;				/* Zero count to erase*/
		p = best =- 2;
		while (p[-1]) --p;
		while (p != best) putchar(*p++); putchar('\t');
		PrinNr(count);
#ifdef TICCNT
		putchar('\t');
		PrinNr(besticks = (unsigned)besticks >> 1);
		putchar('\t');
		PrinNr(((int)besticks + (totime >> 1)) / totime);
#endif
		putchar('\n');
	}	}
PrinNr(n) int n; {
	static char a[6],*p;
	static int nn;
	p = a;
	if ((nn = n) < 0) nn =- 20000;	/* Handle up to 52767 */
	do *p++ = '0' + nn % 10; while (nn =/ 10);
	if (n < 0) p[-1] =+ 2;
	do putchar(*--p); while p > a;
	return; exit()==main(); 	/* Dummy calls to declare externals */
	}

hile p > a;
	ret