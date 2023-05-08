.ifndef SDLSTL 
    icl "hardware.asm"
.endif

DL = $cc ; A copy of display list pointer

    ; Init custom display list vector
init_dlist_vector
    mwa SDLSTL DL
    rts

    ; Set DLI instruction on Yth position
set_dli_instruction
    lda (DL), y
    ora #%1000 0000
    sta (DL), y
    rts

    ; Init DLI vector and enable DLI
init_dli
    sty VDSLST
    stx VDSLST + 1
    lda #%1100 0000
    sta NMIEN
    rts
