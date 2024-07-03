        label           ; Write
        pop     hl      ; return address
        pop     bc      ; character to write
        push    hl      ; save it again
        ld      e, c    ; character to write
        ld      c, 2    ; console output
        call    0005
        pop     hl      ; return address
        jp      (hl)

