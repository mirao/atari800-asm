;
; Show a half of GR0 screen in various colors
;

    icl "../common/keys.asm"

DARK_RED = $22

GR0_HALF_SCREEN_CHARS_CNT = 40 * 12 ; Number of characters in a half of the GR0 screen
TEXT_UP_POS = (GR0_HALF_SCREEN_CHARS_CNT - (txt_end - txt_start)) / 2; Char position of the text in upper screen
TEXT_DOWN_POS = TEXT_UP_POS + GR0_HALF_SCREEN_CHARS_CNT ; Char position of the text in bottom screen
TEXT_COLOR_INDEX = 24 ; Index of the hex color value (after '$')
TEXT_LAST_CHAR_INDEX = txt_end - txt_start - 1; Index of the last character in the text

RTCLOK2 = $14
SAVMSC = $58

DL = $cc ; A copy of display list pointer
LAST_COLOR = $ce ; Previous color
LAST_TIME_COLOR_CHANGE = $cf ; When color was changed last time (in 1/60 sec)
IS_BOTTOM_SCREEN_COLORFUL = $d0 ; 0 - upper half of screen is colored, 1 - bottom half of screen is colored
VRAM = $d1 ; Pointer to a text in video memory
TEXT_POS_LO = $d2 ; Pointer to a text message 

VDSLST = $200
SDLSTL = $230
COLOR2 = $2c6
COLPF2 = $d018
WSYNC = $d40a
VCOUNT = $d40b
NMIEN = $d40e

    org $600

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

    ; Show text
    jmp display_text_up
wait_forever
    ldy #TEXT_COLOR_INDEX
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
    bne display_text_up

    ; Clear a text message at the top of the screen
    mwa #TEXT_UP_POS TEXT_POS_LO
    jsr clear_text
    ; Display a text message at the bottom of the screen
    adw SAVMSC #TEXT_DOWN_POS VRAM
    ldy #TEXT_LAST_CHAR_INDEX
    jsr display_text
    jmp wait_forever

display_text_up
    ; Clear a text message at the bottom of the screen
    mwa #TEXT_DOWN_POS TEXT_POS_LO
    jsr clear_text
    ; Display a text message in upper screen
    adw SAVMSC #TEXT_UP_POS VRAM
    ldy #TEXT_LAST_CHAR_INDEX
    jsr display_text
    jmp wait_forever

dli_routine
    pha ; Only accumulator is used by both main code and the DLI routine
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
    lda txt_start, y
    sta (VRAM), y
    dey
    cpy #$ff
    bne display_text
    rts

clear_text
    adw SAVMSC TEXT_POS_LO VRAM
    ldy #TEXT_LAST_CHAR_INDEX
    lda #" "
clear_char
    sta (VRAM), y-
    cpy #255
    bne clear_char
    rts

hex2ascii
    cmp #10
    bcc make_digit
    adc #['A' - '9' - 2] ; Prepare conversion to letter
make_digit
    adc #"0"
    rts

txt_start
    .sb "                Color: $                "
    .sb "                                        "
    .sb "                                        "
    .sb "    Press any key to flip the screen    "
txt_end
