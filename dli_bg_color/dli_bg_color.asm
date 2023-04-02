;
; Show the bottom half of GR0 screen in various colors
;

DARK_RED = $22

RTCLOK2 = $14
DL = $cc ; A copy of display list pointer
LAST_COLOR = $ce ; Previous color
LAST_TIME_COLOR_CHANGE = $cf ; When color was changed last time (in 1/60 sec)
VDSLST = $200
SDLSTL = $230
COLPF2 = $d018
WSYNC = $d40a
NMIEN = $d40e

    org $600

    lda SDLSTL
    sta DL
    lda SDLSTL + 1
    sta DL + 1
    ; Set DLI in the middle of the screen - to the 12th line, i.e. a color for lines >12 will be changed
    ldy #16
    lda (dl), y
    ora #%1000 0000
    sta (dl), y

    ; Init vector by DLI routine
    lda #<dli_routine
    sta VDSLST
    lda #>dli_routine
    sta VDSLST + 1

    ; Init clock and color
    lda RTCLOK2
    sta LAST_TIME_COLOR_CHANGE
    lda #DARK_RED
    sta LAST_COLOR

    ; Enable DLI
    lda #%1100 0000
    sta NMIEN
wait_forever
    jmp wait_forever

dli_routine
    ; There is no need to store/recover registers when DLI begins/ends
    ; because main app only waits in a never ending loop where it doesn't use any registers
    ldx #0 ; Keep last color unless some time passed
    lda LAST_TIME_COLOR_CHANGE
    add #16 ; Wait 16/60 sec for change of color
    cmp RTCLOK2
    bne set_color
    ; A delay passed
    ; Set new time for next check
    sta LAST_TIME_COLOR_CHANGE
    ; Increase color
    ldx #2
set_color
    txa
    add LAST_COLOR
    sta LAST_COLOR
    sta WSYNC ; Change color at the beginning of the next line
    sta COLPF2 ; Set background color
    rti
