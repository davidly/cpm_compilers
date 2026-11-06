; i8080 version of an app that proves you can't win at tic-tac-toe
; this app takes one optional argument -- the # of iterations
;
; copy / assemble, link, and run on cp/m using:
; r tttcpm.asm      -- cp/m emulators sometimes allow reading files like this.
; asm tttcpm
; load tttcpm
; tttcpm
;
; The board positions:
;   0 1 2
;   3 4 5
;   6 7 8
;

; cp/m-specific constants

BDOS  equ 5
WCONF equ 2
PRSTR equ 9

; app constants

DEFLOOPS    equ     1               ; default # of times to run (max 32767)
XSCO        equ     9               ; maximum score
NSCO        equ     2               ; minimum score
WSCO        equ     6               ; winning score
TSCO        equ     5               ; tie score
LSCO        equ     4               ; losing score
XPIECE      equ     1               ; X move piece
OPIECE      equ     2               ; Y move piece
BLANKPIECE  equ     0               ; empty move piece
TAILCOUNT   equ     128             ; where the # of bytes in the command tail is located

org     100h
        lxi     h, DEFLOOPS         ; setup the default number of iterations
        shld    LOOPS               ; in the global variable LOOPS

        lda     TAILCOUNT           ; was there a command-line argument?
        cpi     0
        jz      Again               ; if not, use the default value for LOOPS
        mvi     d, 0                ; get ready to null-terminate the string
        mov     e, a                ; # of characters
        lxi     h, TAILCOUNT + 1    ; start of the string
        dad     d                   ; now hl points just beyond the argument
        mvi     m, 0                ; null-terminate the tail string
        lxi     h, TAILCOUNT + 1    ; convert the tail string in hl to a number in hl
        call    atou                ; null-terminated string in hl => unsigned integer in hl
        shld    LOOPS               ; store the value for use in the loop below

        mov     a, l                ; if they asked for 0 or it wasn't a number, do nothing
        cpi     0
        jnz     Again
        mov     a, h
        cpi     0
        jnz     Again
        lxi     h, STRINVARG        ; the value is 0 then so show an error and exit
        call    DISPLY
        jmp     0                    

  Again:
        lxi     h, 0
        shld    MOVES               ; set to 0 each iteration to avoid overflow

        mvi     a, 0
        call    RUNMINMAX           ; first of 3 unique board configurations

        mvi     a, 1
        call    RUNMINMAX           ; second

        mvi     a, 4
        call    RUNMINMAX           ; third
                                 
        lhld    ITERS               ; increment iteration count and loop until done
        inx     h
        shld    ITERS
        xchg
        lhld    LOOPS
        mov     a, h
        cmp     d
        jnz     AGAIN
        mov     a, l
        cmp     e
        jnz     AGAIN

        lxi     h, STRMOVES         ; all done -- display related information
        call    DISPLY
        lhld    MOVES
        call    PUTHL
        lxi     h, CRLF
        call    DISPLY

        lxi     h, STRITERS
        call    DISPLY
        lhld    LOOPS
        call    PUTHL
        lxi     h, CRLF
        call    DISPLY

        jmp     0                   ; cp/m call to terminate the app

RUNMINMAX:                          ; Run the MINMAX function for a given first move
        lxi     h, BOARD
        add     l                   ; the board is in one page: no carry into h
        mov     l, a
        mvi     m, XPIECE           ; store the first move
        push    h                   ; save the pointer to the move location for later
        mov     e, l                ; the move, as its board address low byte
        mvi     b, NSCO             ; alpha
        mvi     c, XSCO             ; beta
        call    MINIMIZE
        pop     h                   ; restore the move location
        mvi     m, BLANKPIECE       ; restore a blank on the board
        ret

; Separate maximize (X to move) and minimize (O to move) routines.
; Arguments in registers:
;   b - alpha     c - beta
;   e - the most recent move, as the low byte of its board address
; Register usage:
;   d - the best score so far (value)
;   e - after the win check, the move being tried. A child returns with e
;       unchanged, so the parent rebuilds hl from it instead of saving hl.
;   hl - the board position being tried. The board is page-aligned and followed
;        by a zero sentinel, so the scan only increments l and compares with a = 0.
; A maximize node only raises alpha and a minimize node only lowers beta, and
; the parent saves b/c and d/e around each call, so no globals are needed.
; There is no depth counter. With fewer than five pieces placed nobody has three
; in a row, so the win check simply finds none. A minimize node at depth 8 finds
; the board full: its value stays at the maximum score, which no other node can
; produce, and becomes the tie score.

MAXIMIZE:                           ; the recursive scoring function
        lxi     h, MOVES            ; count the move
        inr     m
        jnz     XCOUNTED
        inr     l
        inr     m
XCOUNTED:
        mvi     d, OPIECE           ; the piece that took the move
        call    CALLSCOREPROC       ; look for a winning position
        cpi     OPIECE              ; see if O won
        mvi     a, LSCO             ; losing score since O won
        rz

        mvi     d, NSCO             ; maximizing odd depths, so start with minimum score
        lxi     h, BOARD - 1

XNEXT:
        xra     a                   ; BLANKPIECE is 0
XLOOP:
        inr     l
        cmp     m                   ; is the board space free (or the sentinel)?
        jnz     XLOOP
        mov     a, l
        cpi     ( BOARD + 9 ) AND 0FFH   ; the sentinel: every move has been tried
        jz      XDONE

        mvi     m, XPIECE           ; make the move
        mov     e, l                ; the move for the child's win check and our resume point
        push    d                   ; save value in d and the move in e
        push    b                   ; save alpha and beta
        call    MINIMIZE
        pop     b
        pop     d
        mov     l, e                ; the child clobbers hl; e has the move's address
        mvi     h, BOARD SHR 8
        mvi     m, BLANKPIECE       ; restore the 0 on the board where the turn was placed

        cpi     WSCO                ; SC - WSCO. If zero, can't do better.
        rz
        cmp     d                   ; compare score with value
        jz      XNEXT               ; scores are small positive numbers: unsigned compares
        jc      XNEXT
        cmp     c                   ; compare score with beta
        rnc                         ; beta pruning
        mov     d, a                ; update value with score
        cmp     b                   ; compare value with alpha
        jz      XNEXT
        jc      XNEXT
        mov     b, a                ; update alpha with value
        jmp     XNEXT

XDONE:
        mov     a, d
        ret

MINIMIZE:                           ; the recursive scoring function
        lxi     h, MOVES            ; count the move
        inr     m
        jnz     NCOUNTED
        inr     l
        inr     m
NCOUNTED:
        mvi     d, XPIECE           ; the piece that took the move
        call    CALLSCOREPROC       ; look for a winning position
        cpi     XPIECE              ; see if X won
        mvi     a, WSCO             ; winning score. avoid branch by always loading
        rz

        mvi     d, XSCO             ; minimizing, so start with maximum score
        lxi     h, BOARD - 1

NNEXT:
        xra     a                   ; BLANKPIECE is 0
NLOOP:
        inr     l
        cmp     m                   ; is the board space free (or the sentinel)?
        jnz     NLOOP
        mov     a, l
        cpi     ( BOARD + 9 ) AND 0FFH   ; the sentinel: every move has been tried
        jz      NDONE

        mvi     m, OPIECE           ; make the move
        mov     e, l                ; the move for the child's win check and our resume point
        push    d                   ; save value in d and the move in e
        push    b                   ; save alpha and beta
        call    MAXIMIZE
        pop     b
        pop     d
        mov     l, e                ; the child clobbers hl; e has the move's address
        mvi     h, BOARD SHR 8
        mvi     m, BLANKPIECE       ; restore the 0 on the board where the turn was placed

        cpi     LSCO                ; SC - LSCO. If zero, can't do worse.
        rz
        cmp     d                   ; compare score with value
        jnc     NNEXT
        mov     d, a                ; update value with score
        cmp     b                   ; compare value with alpha
        rz                          ; alpha pruning
        rc                          ; alpha pruning
        cmp     c                   ; compare value with beta
        jnc     NNEXT
        mov     c, a                ; update beta with value
        jmp     NNEXT

NDONE:
        mov     a, d
        cpi     XSCO                ; no move was possible: the board is full
        rnz
        mvi     a, TSCO             ; tie score
        ret

; e = the move, as the low byte of its board address
; d = the player who just took a move, O or X
; Returns that piece in a if it completed a line, else 0. Preserves b, c, d, e.
CALLSCOREPROC:
        mov      a, e               ; the board is at 540h and the procs at 580h,
        add      a                  ; so twice the board address low byte indexes WINPROCS
        mov      l, a
        mvi      h, WINPROCS SHR 8
        mov      a, m               ; load the low byte of the proc address
        inr      l                  ; the table fits in one page
        mov      h, m               ; load the high byte of the proc address
        mov      l, a
        mov      a, d               ; put the player move (X or O) in a
        pchl                        ; jump to the winner proc

proc0:
        lxi      h, BOARD + 1
        cmp      m
        jnz      proc0nextwin
        inx      h ; to 2
        cmp      m
        rz

  proc0nextwin:
        lxi      h, BOARD + 3
        cmp      m
        jnz      proc0nextwin2
        lxi      h, BOARD + 6
        cmp      m
        rz

  proc0nextwin2:
        lxi      h, BOARD + 4
        cmp      m
        jnz      proc0no
        lxi      h, BOARD + 8
        cmp      m
        rz

  proc0no:
        xra      a
        ret
        
proc1:
        lxi      h, BOARD + 0
        cmp      m
        jnz      proc1nextwin
        lxi      h, BOARD + 2
        cmp      m
        rz

  proc1nextwin:
        lxi      h, BOARD + 4
        cmp      m
        jnz      proc1no
        lxi      h, BOARD + 7
        cmp      m
        rz

  proc1no:
        xra      a
        ret
        
proc2:
        lxi      h, BOARD + 0
        cmp      m
        jnz      proc2nextwin
        inx      h ; to 1
        cmp      m
        rz

  proc2nextwin:
        lxi      h, BOARD + 5
        cmp      m
        jnz      proc2nextwin2
        lxi      h, BOARD + 8
        cmp      m
        rz

  proc2nextwin2:
        lxi      h, BOARD + 4
        cmp      m
        jnz      proc2no
        lxi      h, BOARD + 6
        cmp      m
        rz

  proc2no:
        xra      a
        ret
        
proc3:
        lxi      h, BOARD + 0
        cmp      m
        jnz      proc3nextwin
        lxi      h, BOARD + 6
        cmp      m
        rz

  proc3nextwin:
        lxi      h, BOARD + 4
        cmp      m
        jnz      proc3no
        lxi      h, BOARD + 5
        cmp      m
        rz

  proc3no:
        xra      a
        ret
        
proc4:
        lxi      h, BOARD + 0
        cmp      m
        jnz      proc4nextwin
        lxi      h, BOARD + 8
        cmp      m
        rz

  proc4nextwin:
        lxi      h, BOARD + 2
        cmp      m
        jnz      proc4nextwin2
        lxi      h, BOARD + 6
        cmp      m
        rz

  proc4nextwin2:
        lxi      h, BOARD + 1
        cmp      m
        jnz      proc4nextwin3
        lxi      h, BOARD + 7
        cmp      m
        rz

  proc4nextwin3:
        lxi      h, BOARD + 3
        cmp      m
        jnz      proc4no
        lxi      h, BOARD + 5
        cmp      m
        rz

  proc4no:
        xra      a
        ret

proc5:
        lxi      h, BOARD + 3
        cmp      m
        jnz      proc5nextwin
        inx      h ; to 4
        cmp      m
        rz

  proc5nextwin:
        lxi      h, BOARD + 2
        cmp      m
        jnz      proc5no
        lxi      h, BOARD + 8
        cmp      m
        rz

  proc5no:
        xra      a
        ret

proc6:
        lxi      h, BOARD + 4
        cmp      m
        jnz      proc6nextwin
        lxi      h, BOARD + 2
        cmp      m
        rz

  proc6nextwin:
        lxi      h, BOARD + 0
        cmp      m
        jnz      proc6nextwin2
        lxi      h, BOARD + 3
        cmp      m
        rz

  proc6nextwin2:
        lxi      h, BOARD + 7
        cmp      m
        jnz      proc6no
        inx      h ; to 8
        cmp      m
        rz

  proc6no:
        xra      a
        ret
        
proc7:
        lxi      h, BOARD + 1
        cmp      m
        jnz      proc7nextwin
        lxi      h, BOARD + 4
        cmp      m
        rz

  proc7nextwin:
        lxi      h, BOARD + 6
        cmp      m
        jnz      proc7no
        lxi      h, BOARD + 8
        cmp      m
        rz

  proc7no:
        xra      a
        ret
        
proc8:
        lxi      h, BOARD + 0
        cmp      m
        jnz      proc8nextwin
        lxi      h, BOARD + 4
        cmp      m
        rz

  proc8nextwin:
        lxi      h, BOARD + 2
        cmp      m
        jnz      proc8nextwin2
        lxi      h, BOARD + 5
        cmp      m
        rz

  proc8nextwin2:
        lxi      h, BOARD + 6
        cmp      m
        jnz      proc8no
        inx      h ; to 7
        cmp      m
        rz

  proc8no:
        xra      a
        ret

; negate the de register pair.
; negate using complement then add 1

negatede:
        mov      a, d
        cma
        mov      d, a
        mov      a, e
        cma
        mov      e, a
        inx      d
        ret

; negate the hl register pair.
; negate using complement then add 1

negatehl:
        mov      a, h
        cma
        mov      h, a
        mov      a, l
        cma
        mov      l, a
        inx      h
        ret

; multiply de by hl, result in hl
; incredibly slow iterative addition.

imul:
        mov      a, l               ; first check if hl is 0 and just return if so
        cpi      0
        jnz      mul$start
        mov      a, h
        cpi      0
        jnz      mul$start
        ret

  mul$start:
        push     b
        mvi      b, 80h
        mov      a, h
        ana      b
        jz       mul$notneg
        call     negatehl
        call     negatede
  mul$notneg:
        push     h
        pop      b
        lxi      h, 0
        shld     mulTmp
  mul$loop:
        dad      d
        jnc      mul$done
        push     h
        lhld     mulTmp
        inx      h
        shld     mulTmp
        pop      h
  mul$done:
        dcx      b
        mov      a, b
        ora      c
        jnz      mul$loop
        pop      b
        ret

atou:                               ; in: hl points to string. out: hl has integer value. positive base-10 is assumed
        push   b
        push   d
        lxi    b, 0                 ; running total is in bc

  atouSpaceLoop:                    ; skip past spaces
        mov    a, m
        cpi    ' '
        jnz    atouNext
        inx    h
        jmp    atouSpaceLoop

  atouNext:
        mov    a, m                 ; check if we're at the end of string or the data isn't a number
        cpi    '0'
        jm     atouDone             ; < '0' isn't a digit
        cpi    '9' + 1
        jp     atouDone             ; > '9' isn't a digit

        lxi    d, 10                ; multiply what we have so far by 10
        push   h
        mov    h, b
        mov    l, c
        call   imul
        mov    b, h
        mov    c, l
        pop    h

        mov    a, m                 ; restore the digit in a because imul trashed it
        sui    '0'                  ; change ascii to a number
        add    c                    ; add this new number to the running total in bc
        mov    c, a
        mov    a, b
        aci    0                    ; if there was a carry from the add, reflect that
        mov    b, a

        inx    h                    ; move to the next character
        jmp    atouNext             ; and process it

  atouDone:
        mov    h, b                 ; the result goes in hl
        mov    l, c
        pop    d
        pop    b
        ret

DisplayOneCharacter:                ; display the character in a
        push    b ! push d ! push h

        mvi     c, WCONF
        mov     e, a
        call    BDOS

        pop     h ! pop d ! pop b
        ret

DisplayDigit:                       ; Argument # 0-9 is in register B
        push    b ! push d ! push h

        mvi     a, 48
        add     b
        call    DisplayOneCharacter

        pop     h ! pop d ! pop b
        ret

DISPLY:                             ; display null-terminated string pointed to by hl
        push    b ! push d ! push h

        mov     b, h
        mov     c, l

  DNEXT:
        ldax    b
        cpi     0
        jz      DDONE
        call    DisplayOneCharacter
        inx     b
        jmp     DNEXT

  DDONE:
        pop     h ! pop d ! pop b
        ret

PUTHL:                              ; print the signed 16-bit number in HL
        mov     a, h                ; Get the sign bit of the integer,
        ral                         ; which is the top bit of the high byte
        sbb     a                   ; A=00 if positive, FF if negative
        sta     NEGF                ; Store it as the negative flag
        cnz     negatehl            ; And if HL was negative, make it positive
        lxi     d, NUM              ; Load pointer to end of number string
        push    d                   ; Onto the stack
        lxi     b, -10              ; Divide by ten (by trial subtraction)
  DIGIT:
        lxi     d, -1               ; DE = quotient. There is no 16-bit subtraction,
  DGTDIV:
        dad     b                   ; so we just add a negative value,
        inx     d                   
        jc      DGTDIV              ; while that overflows.
        mvi     a, '0'+10           ; The loop runs once too much so we're 10 out
        add     l                   ; The remainder (minus 10) is in L
        xthl                        ; Swap HL with top of stack (i.e., the string pointer)
        dcx     h                   ; Go back one byte
        mov     m, a                ; And store the digit
        xthl                        ; Put the pointer back on the stack
        xchg                        ; Do all of this again with the quotient
        mov     a, h                ; If it is zero, we're done
        ora     l
        jnz     DIGIT               ; But if not, there are more digits
        mvi     c, PRSTR            ; Prepare to call CP/M and print the string
        pop     d                   ; Put the string pointer from the stack in DE
        lda     NEGF                ; See if the number was supposed to be negative
        inr     a                   
        jnz     bdos                ; If not, print the string we have and return
        dcx     d                   ; But if so, we need to add a minus in front
        mvi     a, '-'              
        stax    d                   
        jmp     bdos                ; And only then print the string. bdos will return to caller

org     500h                        ; the board and win procedure table share one 256-byte page.
                                    ; the assembler won't warn if data and code overlap!
                                    ; there is no way to force alignment, which would be better.
                                    ; the board is at 540h with a zero sentinel after it; WINPROCS
                                    ; is at 580h, so the entry for board address low byte L is
                                    ; at 500h + 2 * L.

org     540h
BOARD:     db      0,0,0,0,0,0,0,0,0
SENTINEL:  db      0                ; never written: stops the move scan
MOVES:     dw      0                ; Count of moves examined (to validate the app)

org     580h
WINPROCS:  dw      proc0, proc1, proc2, proc3, proc4, proc5, proc6, proc7, proc8
NEGF:      db      0                ; Space for negative flag
           db      '-00000'            
NUM:       db      '$'              ; Space for number. cp/m strings end with a dollar sign
CRLF:      db      13,10,0
STRITERS:  db     'iterations: ', 0
STRINVARG: db     'iteration argument invalid; it must be 1 - 32767', 13,10,0
STRMOVES:  db     'moves: ', 0
ITERS:     dw      0                ; iterations of running the app so far
LOOPS:     dw      0                ; # of iterations to make
mulTmp:    dw      0

end

