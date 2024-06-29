/* exec: function to chain to another C-generated com file, with
/*       text argument passing.                         (9/6/83)
/* Calling sequence:
/*       exec(prog, args);
/*       char *prog, *args;
/* where
/*       prog is the name of the program being executed next
/*       args is a pointer to a string of arguments separated by
/*         blanks or tabs.  Embedded blanks within the arguments are
/*         not allowed, unless the called program does not use the
/*         default FCB parameters (and most don't) and can parse the
/*         command line parameter list itself (like C80 programs can).
*/

exec() {
#asm
        JMP @exec
;
;       CP/M memory pointers
;
@BASE   EQU 0000H       ;either 0 or 4200h for CP/M systems
@FCB    EQU @BASE+5CH   ;default file control block
@TBUFF  EQU @BASE+80H   ;sector buffer
@BDOS   EQU @BASE+5     ;bdos entry point
@TPA    EQU @BASE+100H  ;transient program area
@ERRV   EQU 255         ;error value returned by bdos calls
;
;       CP/M BDOS CALL MNEMONICS
;
@OPENC  EQU 15          ;open a file
@READS  EQU 20          ;read a sector (sequential)
@SDMA   EQU 26          ;set dma
;
;       Argument pointers
;
@ARGS:  DS 0
@ARG1:  DS 2
@ARG2:  DS 2
@ARG3:  DS 2
@ARG4:  DS 2
@ARG5:  DS 2
@ARG6:  DS 2
;
@exec:  LXI H,4
        DAD SP
        MOV E,M
        INX H
        MOV D,M         ;DE points to program name now
        LXI H,-60
        DAD SP          ; compute &newfcb for use here
        PUSH H          ; save for much later (will pop into bc)
        PUSH H          ;make a few copies for local use below
        PUSH H
#endasm
        x_fcb();
#asm
        POP H           ;get new fcb addr
        LXI B,9         ;set extension to com
        DAD B
        MVI M,'C'
        INX H
        MVI M,'O'
        INX H
        MVI M,'M'
        POP D           ;get new fcb addr again
        MVI C,@OPENC    ;open the file for reading
        CALL @BDOS
        CPI @ERRV
        JNZ @NOERR
        POP H           ;if can't (like it doesn't exist), return -1
        LXI H,-1
        RET
@NOERR: LXI H,4         ;get args pointer
        DAD SP
        MOV A,M         ;HL = *HL
        INX H
        MOV H,M
        MOV L,A
        CALL @SPARG     ;separate them into individual strings
        LHLD @ARG1
        MOV A,H
        ORA L
        JNZ @EXCL0
        LXI D,@ARG1     ;no arguments -- create a blank FCB
        PUSH D          ;call x?fcb with null string
        LXI H,@FCB
#endasm
        x_fcb();
#asm
        POP H
        JMP @EXCL6

@EXCL0: XCHG
        LXI H,@FCB
#endasm
        x_fcb();
#asm
        LHLD @ARG2      ;and stick second param string
        MOV A,H
        ORA L
        JNZ @EXCL6
        LXI H,@ARG2

@EXCL6: XCHG            ;into second default fcb slot
        LXI H,@FCB+16
#endasm
        x_fcb();
#asm
        LXI D,@TBUFF+1   ;now construct command line:
        LXI H,4
        DAD SP          ;HL points to arg string pointer
        MOV A,M
        INX H
        MOV H,M
        MOV L,A
        MVI B,0         ;char count for com. line buf.
        MOV A,H         ;are there any arguments?
        ORA L
        JZ @EXCL9
        ORA M           ; (Bug fix 7/83 WB)
        JNZ @EXCL5
@EXCL9: STAX D          ;no--zero TBUFF and TBUFF+1
        JMP @EXCL2
@EXCL5: MVI A,' '       ;yes--start buffer off with a ' '
        STAX D
        INX D
        INR B
@EXCL1: MOV A,M         ;now copy argument string to command line
        CALL NAM@U##    ;Make sure they're upper case
        STAX D
        INX D
        INX H
        INR B
        ORA A
        JNZ @EXCL1
        DCR B

@EXCL2: LXI H,@TBUFF    ;set length of command line
        MOV M,B         ;at location tbuff

        LXI D,@CODE0    ;copy loader down to end of tbuff
        LXI H,@TPA-42
        MVI B,42        ;length of loader
@EXCL4: LDAX D
        MOV M,A
        INX D
        INX H
        DCR B
        JNZ @EXCL4

        POP B                   ;get back working fcb pointer
        LHLD @BASE+6
        SPHL
	LXI H,@BASE
	PUSH H			;set base of ram as return addr
	JMP @TPA-42		;(go to `CODE0:')
;
; THIS LOADER CODE IS NOW: 42 BYTES LONG.
;
@CODE0: LXI D,@TPA		;destination address of new program
@CODE1: PUSH D			;push dma addr
	PUSH B			;push fcb pointer
	MVI C,@SDMA		;set dma address for new sector
	CALL @BDOS
	POP D			;get pointer to working fcb in de
	PUSH D			;and re-push it
	MVI C,@READS		;read a sector
	CALL @BDOS
	POP B			;restore fcb pointer into bc
	POP D			;and dma address into de
	ORA A			;end of file?
	JZ @TPA-8		;if not, get next sector (goto `CODE2:')
	MVI C,@SDMA		;reset dma pointer
	LXI D,@TBUFF
	CALL @BDOS
	JMP @TPA		;and go invoke the program

@CODE2: LXI H,80H		; bump dma address
	DAD D
	XCHG
	JMP @TPA-39		;and go loop (at CODE1)
;
; this routine takes the string pointed to by HL,
; seperates it into non-white strings,
; and places them contiguously in array ARGST.
; also places pointers to these individual strings in ARGS
;
@SPARG: XCHG		;DE = original string
	LXI B,@ARGST	;BC = new string (w/ each substr 0-terminated)
	LXI H,@ARGS	;HL = pointer to ARGS space
@SEP0:	DCX D
@SEP1:	INX D		;scan over white space
	LDAX D
	CPI ' '
	JZ @SEP1
	CPI 9
	JZ @SEP1
	CPI 0		; char = 0?
	JZ @SPRET	; yes -- return
	MOV M,C 	; no -- store local pointer at proper args
	INX H
	MOV M,B 	;argsn = BC
	INX H
@TOWSP: STAX B		;store non-white
	INX B
	INX D		;now scan to next white space
	LDAX D
	CPI 0
	JZ @SEP2
	CPI ' '
	JZ @SEP2
	CPI 9
	JNZ @TOWSP
@SEP2:	XRA A
	STAX B		;store 0 to terminate this string
	INX B
	JMP @SEP0	; and loop
@SPRET: MOV M,A 	;set last argn to 0 and return
	INX H
	MOV M,A
	RET
@ARGST: DS 100
#endasm
}

@SP