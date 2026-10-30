; 8080 assembly to compute e to n digits.
; When DIGITS is 200, the first 192 digits are displayed.
; Byte counters, inlined division by adding -n, and page-aligned
; multiply-by-ten tables specialize the inner loop without changing the spigot.
;
; equivalent to:
;     program e;
;     const
;        DIGITS = 200;
;     type
;         arrayType = array[ 0..DIGITS ] of integer;
;     var
;         high, n, x : integer;
;         a : arrayType;
;     begin
;         high := DIGITS;
;         x := 0;
;         n := high - 1;
;         while n > 0 do begin
;             a[ n ] := 1;
;             n := n - 1;
;         end;
;
;         a[ 1 ] := 2;
;         a[ 0 ] := 0;
;
;         while high > 9 do begin
;             high := high - 1;
;             n := high;
;             while 0 <> n do begin
;                 a[ n ] := x MOD n;
;                 x := 10 * a[ n - 1 ] + x DIV n;
;                 n := n - 1;
;             end;
;
;             Write( x );
;         end;
;
;         writeln; writeln( 'done' );
;     end.

; cp/m-specific constants

BDOS  equ 5
WCONF equ 2
PRSTR equ 9

; app constants

true   equ 1
false  equ 0
; Byte indices and the page-aligned array require 10 <= DIGITS <= 255.
digits equ 200

org     100h
        ; why is the loop backwards? no idea.
        ; while n > 0 do begin
        ;     a[ n ] := 1;
        ;     n := n - 1;
        ; end;

        ; C counts initialized bytes; HL addresses the page-aligned array.
        ; B is the byte value 1.

        mvi        b, 1
        mvi        c, DIGITS - 1
        lxi        h, array + DIGITS - 1

  ainit:
        mov        m, b
        dcr        l
        dcr        c
        jnz        ainit

        ; a[ 1 ] := 2;
        ; a[ 0 ] := 0;

        lxi        h, array + 1
        mvi        m, 2
        dcr        l
        mvi        m, 0

        ; register b is both "high" and "n". register de is x at the start of each inner loop

        mvi        b, DIGITS

  outerloop:
        dcr        b                ; high := high - 1; n := high;
        push       b                ; save b/high on the stack
        lxi        d, 0             ; x := 0;

  innerloop:
        ; Divide x by byte n. DAD adds -n; INR preserves its carry.
        ; Include the final failed subtraction, starting the quotient at -1.
        xchg                        ; HL = x
        xra        a
        sub        b
        mov        e, a
        mvi        d, 255           ; DE = -n, with 1 <= n <= 254
        mvi        c, 255
  divloop:
        dad        d
        inr        c
        jc         divloop
        mov        a, l
        add        b                ; restore only the byte remainder
        mvi        h, array / 256
        mov        l, b
        mov        m, a             ; a[n] = remainder
        dcr        l
        mov        l, m             ; a[n-1], used as a table index
        mvi        h, mul10lo / 256
        mov        e, m
        inr        h
        mov        d, m             ; DE = 10*a[n-1]
        mov        a, e
        add        c
        mov        e, a
        mov        a, d
        aci        0
        mov        d, a             ; x = 10*a[n-1] + quotient
        dcr        b                ; n := n - 1;
        jnz        innerloop        ; if n isn't 0 then loop again

        xchg                        ; final x is the next output digit(s)
        call       DisplayUnsigned  ; show the next digit(s) of e

        mvi        a, 9
        pop        b		    ; restore high
        cmp        b                ; while high > 9 do begin (re-written as a do until loop)
        jnz        outerloop

        lxi        h, CRLF
        call       DisplayString
        lxi        h, STRDONE
        call       DisplayString

        ret                         ; return to CP/M

DisplayOneCharacter:                ; display the character in a
        push    b ! push d ! push h
        mvi     c, WCONF
        mov     e, a
        call    BDOS
        pop     h ! pop d ! pop b
        ret

DisplayString:                      ; display null-terminated string pointed to by hl
        push    b ! push d ! push h
        mov     b, h
        mov     c, l
  DS$NEXT:
        ldax    b
        cpi     0
        jz      DS$DONE
        call    DisplayOneCharacter
        inx     b
        jmp     DS$NEXT
  DS$DONE:
        pop     h ! pop d ! pop b
        ret

DisplayUnsigned:                    ; print the unsigned 16-bit number in hl
        push    b ! push d ! push h
        call    PrintUnsigned
        pop     h ! pop d ! pop b
        ret

PrintUnsigned:                      ; print the unsigned 16-bit number in HL
        lxi     d, NUM              ; Load pointer to end of number string
        push    d                   ; Onto the stack
        lxi     b, -10              ; Divide by ten (by trial subtraction)
  PU$DIGIT:
        lxi     d, -1               ; DE = quotient. There is no 16-bit subtraction,
  PU$DGTDIV:
        dad     b                   ; so we just add a negative value,
        inx     d
        jc      PU$DGTDIV           ; while that overflows.
        mvi     a, '0'+10           ; The loop runs once too much so we're 10 out
        add     l                   ; The remainder (minus 10) is in L
        xthl                        ; Swap HL with top of stack (i.e., the string pointer)
        dcx     h                   ; Go back one byte
        mov     m, a                ; And store the digit
        xthl                        ; Put the pointer back on the stack
        xchg                        ; Do all of this again with the quotient
        mov     a, h                ; If it is zero, we're done
        ora     l
        jnz     PU$DIGIT            ; But if not, there are more digits
        mvi     c, PRSTR            ; Prepare to call CP/M and print the string
        pop     d
        jmp     bdos                ; And only then print the string. bdos will return to caller

            db      '00000'
NUM:        db      '$'             ; Space for number. cp/m strings end with a dollar sign
CRLF:       db      13,10,0
STRDONE:    db      'done.', 13, 10, 0
; The low and high multiplication tables occupy adjacent complete pages.
            org     ($+255) AND 0FF00H
mul10lo:
            db      0,10,20,30,40,50,60,70,80,90,100,110,120,130,140,150
            db      160,170,180,190,200,210,220,230,240,250,4,14,24,34,44,54
            db      64,74,84,94,104,114,124,134,144,154,164,174,184,194,204,214
            db      224,234,244,254,8,18,28,38,48,58,68,78,88,98,108,118
            db      128,138,148,158,168,178,188,198,208,218,228,238,248,2,12,22
            db      32,42,52,62,72,82,92,102,112,122,132,142,152,162,172,182
            db      192,202,212,222,232,242,252,6,16,26,36,46,56,66,76,86
            db      96,106,116,126,136,146,156,166,176,186,196,206,216,226,236,246
            db      0,10,20,30,40,50,60,70,80,90,100,110,120,130,140,150
            db      160,170,180,190,200,210,220,230,240,250,4,14,24,34,44,54
            db      64,74,84,94,104,114,124,134,144,154,164,174,184,194,204,214
            db      224,234,244,254,8,18,28,38,48,58,68,78,88,98,108,118
            db      128,138,148,158,168,178,188,198,208,218,228,238,248,2,12,22
            db      32,42,52,62,72,82,92,102,112,122,132,142,152,162,172,182
            db      192,202,212,222,232,242,252,6,16,26,36,46,56,66,76,86
            db      96,106,116,126,136,146,156,166,176,186,196,206,216,226,236,246
mul10hi:
            db      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
            db      0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1
            db      1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
            db      1,1,1,1,2,2,2,2,2,2,2,2,2,2,2,2
            db      2,2,2,2,2,2,2,2,2,2,2,2,2,3,3,3
            db      3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3
            db      3,3,3,3,3,3,3,4,4,4,4,4,4,4,4,4
            db      4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4
            db      5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5
            db      5,5,5,5,5,5,5,5,5,5,6,6,6,6,6,6
            db      6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6
            db      6,6,6,6,7,7,7,7,7,7,7,7,7,7,7,7
            db      7,7,7,7,7,7,7,7,7,7,7,7,7,8,8,8
            db      8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8
            db      8,8,8,8,8,8,8,9,9,9,9,9,9,9,9,9
            db      9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9
ARRAY:      ds      DIGITS

end

; unused code
IF 0

; unsigned multiply de by l, result in hl. overflow is lost.
umul:
        mvi     h, 0
        mov     a, l
        cpi     0
        rz
        mov     a, l
        mvi     l, 0
  umul$loop:
        dad     d
        dcr     a
        jnz     umul$loop
        ret

; negate the de register pair. handy for idiv and imul
; negate using complement then add 1
neg$de:
       mov     a, d
       cma
       mov     d, a
       mov     a, e
       cma
       mov     e, a
       inx     d
       ret

; negate the hl register pair. handy for idiv and imul
; negate using complement then add 1
neg$hl:
        mov     a, h
        cma
        mov     h, a
        mov     a, l
        cma
        mov     l, a
        inx     h
        ret

; signed multiply de by hl, result in hl
imul:
        mov     a, l
        cpi     0
        jnz     imul$notzero
        mov     a, h
        cpi     0
        jnz     imul$notzero
        ret
  imul$notzero:
        push    b ! push d
        mvi     b, 80h
        mov     a, h
        ana     b
        jz      imul$notneg
        call    neg$hl
        call    neg$de
  imul$notneg:
        mov     b, h
        mov     c, l
        lxi     h, 0
        shld    mulTmp
  imul$loop:
        dad     d
        jnc     imul$done
        push    h
        lhld    mulTmp
        inx     h
        shld    mulTmp
        pop     h
  imul$done:
        dcx     b
        mov     a, b
        ora     c
        jnz     imul$loop
        pop     d ! pop b
        ret

; signed divide de by hl, result in hl. remainder in divRem
idiv:
        xra     a
        cmp     e
        jnz     idiv$notzero
        cmp     d
        jnz     idiv$notzero
        lxi     h, 0
        shld    divRem              ; 0 mod x is 0
        ret

  idiv$notzero:
        push    b ! push d
        xchg
        mvi     c, 0
        mvi     b, 80h
        mov     a, d
        ana     b
        jz      idiv$denotneg
        inr     c
        call    neg$de
  idiv$denotneg:
        mov     a, h
        ana     b
        jz      idiv$hlnotneg
        inr     c
        call    neg$hl
  idiv$hlnotneg:
        push    b
        lxi     b, 0
  idiv$loop:
        mov     a, l
        sub     e
        mov     l, a
        mov     a, h
        sbb     d
        mov     h, a
        jc      idiv$done
        inx     b
        jmp     idiv$loop
  idiv$done:
        dad     d
        shld    divRem
        mov     l, c
        mov     h, b
        pop     b
        mov     a, c
        ani     1
        cnz     neg$hl
        pop     d ! pop b
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

PUTHL:                              ; print the signed 16-bit number in HL
        mov     a, h                ; Get the sign bit of the integer,
        ral                         ; which is the top bit of the high byte
        sbb     a                   ; A=00 if positive, FF if negative
        sta     NEGF                ; Store it as the negative flag
        cnz     negatehl            ; And if HL was negative, make it positive
        lxi     d, NUM              ; Load pointer to end of number string
        push    d                   ; Onto the stack
        lxi     b, -10              ; Divide by ten (by trial subtraction)
  PUTHL$DIGIT:
        lxi     d, -1               ; DE = quotient. There is no 16-bit subtraction,
  PUTHL$DGTDIV:
        dad     b                   ; so we just add a negative value,
        inx     d
        jc      PUTHL$DGTDIV        ; while that overflows.
        mvi     a, '0'+10           ; The loop runs once too much so we're 10 out
        add     l                   ; The remainder (minus 10) is in L
        xthl                        ; Swap HL with top of stack (i.e., the string pointer)
        dcx     h                   ; Go back one byte
        mov     m, a                ; And store the digit
        xthl                        ; Put the pointer back on the stack
        xchg                        ; Do all of this again with the quotient
        mov     a, h                ; If it is zero, we're done
        ora     l
        jnz     PUTHL$DIGIT         ; But if not, there are more digits
        mvi     c, PRSTR            ; Prepare to call CP/M and print the string
        pop     d                   ; Put the string pointer from the stack in DE
        lda     NEGF                ; See if the number was supposed to be negative
        inr     a
        jnz     bdos                ; If not, print the string we have and return
        dcx     d                   ; But if so, we need to add a minus in front
        mvi     a, '-'
        stax    d
        jmp     bdos                ; And only then print the string. bdos will return to caller


NEGF:       db      0, '-'

endif





