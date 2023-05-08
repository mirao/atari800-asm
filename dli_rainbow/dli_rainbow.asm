;
; A rainbow effect with 128 colors in GR0 screen
;

    icl "../common/hardware.asm"

    org $600

    ; Init display list vector
    jsr init_dlist_vector
    ; Set DLI applied for the 1st ANTIC 2 row (32th scan line)
    ldy #2
    jsr set_dli_instruction

    ; Init vector by DLI routine and enable DLI
    ldy #<dli_routine
    ldx #>dli_routine
    jsr init_dli

wait_forever
    jmp wait_forever

dli_routine
    ldx #8 * 24 ; Draw 192 scan lines = 24 rows of ANTIC 2
    lda RTCLOK2 ; Use RTCLOK2 as a color for the 1st scan line of the 1st ANTIC 2 row
    asl ; Use even luminance so that it's different from the luminance of the previous frame
    tay
draw_next_scan_line
    sty WSYNC
    sty COLPF2
    iny
    iny ; Draw each scan line with different color 
    dex
    bne draw_next_scan_line
    rti

    icl "../common/dlist.asm"
