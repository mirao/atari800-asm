;
; Play a note in VBI  
; Press any key to toggle between increasing and decreasing pitch
;
    icl "../common/hardware.asm"
    icl "../common/keys.asm"
    icl "../common/screen.asm"

TXT_POS = GR0_LINE_LENGTH * 11 ; Position of text on screen relative to upper left corner of screen
TXT_POS_LO = $d2

PERIOD = $d0
PERIOD_INC = $d1 ; 1 = increase period (decrease pitch), 255 = decrease period (increase pitch)

    org $600

    ; Display help
    mwa #TXT_POS TXT_POS_LO
    display_text TXT_POS_LO, txt_start, (txt_end - txt_start)

    ; Init sound
    lda #0
    sta PERIOD ; Highest pitch (frequency)
    ldx #1
    stx PERIOD_INC ; Increase period (= decrease pitch) by default
    sta AUDF1
    lda #$A6
    sta AUDC1

    ; Init VBI
    ldy #<vbi
    ldx #>vbi
    lda #7
    jsr SETVBV

wait_key_press
    get_key
    cmp #$ff
    beq wait_key_press
    reset_key
    ; Change 1 => 255 (subtract period) or 255 => 1 (add period)
    lda PERIOD_INC
    eor #$ff
    add #$01
    sta PERIOD_INC
    jmp wait_key_press

vbi
    ; Play a note
    lda PERIOD
    sta AUDF1
    ; Increase/decrease period
    add PERIOD_INC
    sta PERIOD
    jmp XITVBV

txt_start
    .sb "     Press any key to toggle between    "
    .sb "        increasing/decreasing tone"
txt_end
