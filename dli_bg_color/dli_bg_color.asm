;
; Show a half of GR0 screen in various colors
;

    icl "../common/keys.asm"

DARK_RED = $22
HEX_COLOR_LEN = 2
TXT_COLOR_LEN = txt_color_end - txt_color_start
TXT_COLOR_POS = 40 * 5 + (40 - TXT_COLOR_LEN - HEX_COLOR_LEN) / 2
TXT_KEY_LEN = txt_end - txt_key
TXT_KEY_POS = 40 * 6 + (40 - TXT_KEY_LEN) / 2

RTCLOK2 = $14
SAVMSC = $58

DL = $cc ; A copy of display list pointer
LAST_COLOR = $ce ; Previous color
LAST_TIME_COLOR_CHANGE = $cf ; When color was changed last time (in 1/60 sec)
IS_BOTTOM_SCREEN_COLORFUL = $d0 ; 0 - color of upper half of screen is changing, 1 - color of bottom half of screen is changing
VRAM = $d1
CURRENT_TXT = $d3

VDSLST = $200
SDLSTL = $230
COLOR2 = $2c6
COLPF2 = $d018
WSYNC = $d40a
VCOUNT = $d40b
NMIEN = $d40e

    org $600

    ; Display a text message "Press key"
    adw SAVMSC #TXT_KEY_POS VRAM
    mwa #txt_key CURRENT_TXT
    ldy #TXT_KEY_LEN - 1
    jsr display_text

    ; Display a text message "Color"
    adw SAVMSC #TXT_COLOR_POS VRAM
    mwa #txt_color_start CURRENT_TXT
    ldy #TXT_COLOR_LEN - 1
    jsr display_text

    ; The bottom half of the screen is colored by default
    mva #1 IS_BOTTOM_SCREEN_COLORFUL

    ; Init display list vector
    mwa SDLSTL DL
    ; Set DLI at the begin of the screen
    ldy #2
    jsr set_dli_instruction
    ; Set DLI in the middle of the screen
    ldy #16
    jsr set_dli_instruction
    
    ; Init vector by DLI routine
    mwa #dli_routine VDSLST

    ; Init clock and color
    lda RTCLOK2
    sta LAST_TIME_COLOR_CHANGE
    lda #DARK_RED
    sta LAST_COLOR

    ; Enable DLI
    lda #%1100 0000
    sta NMIEN

wait_forever
    ldy #TXT_COLOR_LEN
    ; Display current hue
    lda LAST_COLOR
    lsr
    lsr
    lsr
    lsr
    jsr hex2ascii
    sta (VRAM), y
    ; Display current luminance
    lda LAST_COLOR
    and #$0f
    jsr hex2ascii
    iny
    sta (VRAM), y
     
    get_key
    cmp #$ff
    beq wait_forever
    reset_key
    lda IS_BOTTOM_SCREEN_COLORFUL
    eor #1
    sta IS_BOTTOM_SCREEN_COLORFUL
    jmp wait_forever

dli_routine
    pha
    lda VCOUNT; $0f - upper half, $3f - bottom half
    lsr
    lsr
    lsr
    lsr
    and #$01
    eor IS_BOTTOM_SCREEN_COLORFUL
    beq render_screen_dynamic_color
    ; Restore standard blue color
    lda COLOR2
    jmp set_color
render_screen_dynamic_color
    ldx #0 ; Keep last color unless some time passed
    lda LAST_TIME_COLOR_CHANGE
    add #16 ; Wait 16/60 sec for change of color
    cmp RTCLOK2
    bne increase_color
    ; A delay passed
    ; Set new time for next check
    sta LAST_TIME_COLOR_CHANGE
    ; Increase color
    ldx #2
increase_color
    txa
    add LAST_COLOR
    sta LAST_COLOR
set_color
    sta WSYNC ; Change color since the beginning of the next line
    sta COLPF2 ; Set background color
    pla
    rti

set_dli_instruction
    lda (dl), y
    ora #%1000 0000
    sta (dl), y
    rts

display_text
    lda (CURRENT_TXT), y
    sta (VRAM), y
    dey
    bpl display_text
    rts

hex2ascii
    cmp #10
    bcc make_digit
    adc #['A' - '9' - 2] ; Prepare conversion to letter
make_digit
    adc #"0"
    rts

txt_color_start
    .sb "Color: $"
txt_color_end
    org * + HEX_COLOR_LEN ; Reserve hex color value
txt_key
    .sb "Press any key to flip the screen"
txt_end
