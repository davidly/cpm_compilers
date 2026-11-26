; 8080 assembly version of the BYTE magazine October 1982 matrix multiply
; (Jerry Pournelle). Integer version: A, B, and C hold the same small whole
; numbers as the floating point versions, and the sum is 465880.
;
; equivalent to:
;     for i := 1 to 20 do for j := 1 to 20 do A[ i, j ] := i + j;
;     for i := 1 to 20 do for j := 1 to 20 do B[ i, j ] := ( i + j ) div j;
;     for i := 1 to 20 do for j := 1 to 20 do C[ i, j ] := 0;
;     for i := 1 to 20 do for j := 1 to 20 do for k := 1 to 20 do
;         C[ i, j ] := C[ i, j ] + A[ i, k ] * B[ k, j ];
;     summ := sum of C[ i, j ]
;
; A and B fit in bytes (A <= 40, B <= 21) and C in words. The loops run
; i, k, j so that A[ i, k ] is fixed in the inner loop; for each one a
; table of A[ i, k ] * 0..21 is built with additions, and the inner loop
; adds table[ B[ k, j ] ] to C[ i, j ]. The sum is 24 bits.

BDOS  equ 5
WCONF equ 2
PRSTR equ 9

N     equ 20
BMAX  equ 21                    ; largest value in B

org     100h

        ; A[ i, j ] := i + j (0-based: i + j + 2)

        lxi     h, amat
        mvi     b, 0
  fai:  mvi     c, 0
  faj:  mov     a, b
        add     c
        adi     2
        mov     m, a
        inx     h
        inr     c
        mov     a, c
        cpi     N
        jnz     faj
        inr     b
        mov     a, b
        cpi     N
        jnz     fai

        ; B[ i, j ] := ( i + j ) div j (0-based: ( i + j + 2 ) div ( j + 1 ))

        lxi     h, bmat
        mvi     b, 0
  fbi:  mvi     c, 0
  fbj:  mov     a, b
        add     c
        adi     2               ; dividend
        mov     d, c
        inr     d               ; divisor
        mvi     e, 0            ; quotient
  fbd:  cmp     d
        jc      fbdone
        sub     d
        inr     e
        jmp     fbd
  fbdone:
        mov     m, e
        inx     h
        inr     c
        mov     a, c
        cpi     N
        jnz     fbj
        inr     b
        mov     a, b
        cpi     N
        jnz     fbi

        ; C := 0

        lxi     h, cmat
        lxi     b, N * N * 2
        xra     a
  fc:   mov     m, a
        inx     h
        dcx     b
        mov     a, b
        ora     c
        mvi     a, 0
        jnz     fc

        ; multiply

        lxi     h, amat
        shld    pa              ; A[ i, k ]
        lxi     h, cmat
        shld    pcrow           ; C[ i, 0 ]
        mvi     a, N
        sta     icnt
  mi:   lxi     h, bmat
        shld    pbrow           ; B[ k, 0 ]
        mvi     a, N
        sta     kcnt
  mk:   lhld    pa              ; a := A[ i, k ]
        mov     a, m
        inx     h
        shld    pa

        ; table of a * 0 .. a * BMAX; low bytes in tlo, high bytes in thi

        mov     c, a
        mvi     b, 0
        lxi     h, 0
        lxi     d, tlo
  mt:   mov     a, l
        stax    d
        inr     d
        mov     a, h
        stax    d
        dcr     d
        dad     b
        inr     e
        mov     a, e
        cpi     BMAX + 1
        jnz     mt

        ; C[ i, j ] := C[ i, j ] + table[ B[ k, j ] ] for j := 1 to 20

        lhld    pbrow
        mov     b, h
        mov     c, l            ; BC = B[ k, j ]
        lhld    pcrow           ; HL = C[ i, j ]
        mvi     a, N
        sta     jcnt
        mvi     d, tlo shr 8
  mj:   ldax    b
        inx     b
        mov     e, a
        ldax    d               ; low byte of the product
        add     m
        mov     m, a
        inx     h
        inr     d
        ldax    d               ; high byte of the product
        adc     m
        mov     m, a
        inx     h
        dcr     d
        lda     jcnt
        dcr     a
        sta     jcnt
        jnz     mj

        mov     h, b
        mov     l, c
        shld    pbrow           ; B[ k + 1, 0 ]
        lda     kcnt
        dcr     a
        sta     kcnt
        jnz     mk

        lhld    pcrow
        lxi     d, N * 2
        dad     d
        shld    pcrow           ; C[ i + 1, 0 ]
        lda     icnt
        dcr     a
        sta     icnt
        jnz     mi

        ; summ := sum of C, 24 bits in B:D:E

        lxi     h, cmat
        lxi     d, 0
        mvi     b, 0
  sl:   mov     a, e
        add     m
        mov     e, a
        inx     h
        mov     a, d
        adc     m
        mov     d, a
        jnc     snc
        inr     b
  snc:  inx     h
        mov     a, l
        cpi     ( cmat + N * N * 2 ) and 0ffh
        jnz     sl
        mov     a, h
        cpi     ( cmat + N * N * 2 ) shr 8
        jnz     sl

        mov     a, b
        sta     summ + 2
        mov     a, d
        sta     summ + 1
        mov     a, e
        sta     summ

        ; print it

        lxi     d, strsum
        mvi     c, PRSTR
        call    BDOS

        lxi     h, digend       ; digits are stored backwards from here
  pd:   push    h
        xra     a               ; remainder
        lxi     h, summ + 2
        mov     c, m
        call    div10
        mov     m, c
        dcx     h
        mov     c, m
        call    div10
        mov     m, c
        dcx     h
        mov     c, m
        call    div10
        mov     m, c
        pop     h
        dcx     h
        adi     '0'
        mov     m, a
        lda     summ
        mov     b, a
        lda     summ + 1
        ora     b
        mov     b, a
        lda     summ + 2
        ora     b
        jnz     pd

        xchg
        mvi     c, PRSTR
        call    BDOS
        ret

        ; ( A * 256 + C ) / 10, A < 10: quotient in C, remainder in A

  div10:
        push    h
        mvi     l, 8
  d10:  mov     h, a
        mov     a, c
        add     a
        mov     c, a
        mov     a, h
        adc     a
        cpi     10
        jc      d10n
        sui     10
        inr     c
  d10n: dcr     l
        jnz     d10
        pop     h
        ret

strsum: db      'summ is : $'
digbuf: ds      8
digend: db      13, 10, '$'

pa:     dw      0
pbrow:  dw      0
pcrow:  dw      0
icnt:   db      0
kcnt:   db      0
jcnt:   db      0
summ:   db      0, 0, 0

amat:   ds      N * N
bmat:   ds      N * N
cmat:   ds      N * N * 2

        ; product tables, page-aligned: tlo and the page after it (thi)

        org     ( $ + 255 ) and 0ff00h
tlo:    ds      256
thi:    ds      256

end
