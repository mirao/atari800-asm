;
; Show a half of GR0 screen in various colors
;
    icl "../common/hardware.asm"
    icl "../common/keys.asm"
    icl "../common/screen.asm"

DARK_RED = $22

GR0_HALF_SCREEN_CHARS_CNT = 40 * 24 / 2 ; Number of characters in a half of the GR0 screen
TEXT_LEN = txt_end - txt_start; Length of the text
TEXT_UP_POS = (GR0_HALF_SCREEN_CHARS_CNT - TEXT_LEN) / 2; Char position of the text in upper screen
TEXT_DOWN_POS = TEXT_UP_POS + GR0_HALF_SCREEN_CHARS_CNT ; Char position of the text in bottom screen
TEXT_COLOR_INDEX = 24 ; Index of the hex color value (after '$')

DYNAMIC_COLOR = $ce ; Background color in a half screen with color animation
BACKGROUND_COLOR = $d7 ; Background color in any part of screen - either a color for static part (blue) or a color for animated part
LAST_TIME_COLOR_CHANGE = $cf ; When color was changed last time (in 1/60 sec)
IS_BOTTOM_SCREEN_COLOR_ANIMATED = $d0 ; 0 - upper half of screen is colored, 1 - bottom half of screen is colored
TEXT_CLEAR_LO = $d3 ; Vector to a text message to clear
TEXT_DISPLAY_LO = $d5 ; Vector to a text message to display

    org $600

    ; The bottom half of the screen is animated by default
    mva #1 IS_BOTTOM_SCREEN_COLOR_ANIMATED

    ; Init display list vector
    jsr init_dlist_vector
    ; Set DLI at the begin of the screen
    ldy #2
    jsr set_dli_instruction
    ; Set DLI in the middle of the screen
    ldy #16
    jsr set_dli_instruction
    ; Init vector by DLI routine and enable DLI
    ldy #<dli_routine
    ldx #>dli_routine
    jsr init_dli

    ; Init clock and color
    lda RTCLOK2
    sta LAST_TIME_COLOR_CHANGE
    lda #DARK_RED
    sta DYNAMIC_COLOR

    ; Display initial text with color value
    jmp display_text_up
wait_forever
    jsr set_color_for_dli
    jsr display_color_value
    get_key
    cmp #$ff
    beq wait_forever
    reset_key
    lda IS_BOTTOM_SCREEN_COLOR_ANIMATED
    eor #1
    sta IS_BOTTOM_SCREEN_COLOR_ANIMATED
    bne display_text_up
    mwa #TEXT_UP_POS TEXT_CLEAR_LO
    mwa #TEXT_DOWN_POS TEXT_DISPLAY_LO
    jmp clear_and_display_text
display_text_up
    mwa #TEXT_DOWN_POS TEXT_CLEAR_LO
    mwa #TEXT_UP_POS TEXT_DISPLAY_LO
clear_and_display_text
    clear_text TEXT_CLEAR_LO, TEXT_LEN
    display_text TEXT_DISPLAY_LO, txt_start, TEXT_LEN
    ldx #2 ; Display color value after pressing of a key, otherwise an empty value would be displayed until next change of color in DLI
    jmp wait_forever

dli_routine
    pha
    lda BACKGROUND_COLOR
    sta WSYNC ; Change color since the beginning of the next line
    sta COLPF2 ; Set background color
    pla
    rti

set_color_for_dli
    lda VCOUNT ; Half of scan lines
    cmp #$0f ; for DLI on top screen
    beq get_color
    cmp #$3e ; for DLI in the middle of the screen. It's less than the half scan line with DLI (scan line number is 127, half is $3f) otherwise DLI would occur earlier than preparation of the color and screen would be flickering
    beq get_color
    rts
get_color
    lsr
    lsr
    lsr
    lsr
    and #$01
    eor IS_BOTTOM_SCREEN_COLOR_ANIMATED
    beq render_screen_dynamic_color
    ; Restore standard blue color to the "static" half of the screen
    lda COLOR2
    sta BACKGROUND_COLOR
    rts
render_screen_dynamic_color
    ldx #0 ; Keep last color unless some time passed
    lda RTCLOK2
    sub LAST_TIME_COLOR_CHANGE
    cmp #16 ; Wait at least 16/60 sec for change of color
    bcc store_color
    ; A delay passed
    ; Set new time for next check
    lda RTCLOK2
    sta LAST_TIME_COLOR_CHANGE
    ; Increase color
    ldx #2
store_color
    txa
    add DYNAMIC_COLOR
    sta DYNAMIC_COLOR
    sta BACKGROUND_COLOR
    rts

display_color_value
    cpx #2 ; Display color value with initial text or when color was increased during last DLI
    beq display_hue_luminance
    rts
display_hue_luminance
    ldy #TEXT_COLOR_INDEX
    ; Display current hue
    lda DYNAMIC_COLOR
    lsr
    lsr
    lsr
    lsr
    jsr hex2ascii
    sta (VRAM), y
    ; Display current luminance
    lda DYNAMIC_COLOR
    and #$0f
    jsr hex2ascii
    iny
    sta (VRAM), y
    ldx #0 ; A color value was refreshed. Don't refresh it anymore until change of color in DLI
    rts

; Convert a hex digit to internal ASCII
hex2ascii
    cmp #10
    bcc make_digit
    adc #['A' - '9' - 2] ; Prepare conversion to letter
make_digit
    adc #"0"
    rts

    icl "../common/dlist.asm"

txt_start
    .sb "                Color: $                "
    .sb "                                        "
    .sb "                                        "
    .sb "    Press any key to flip the screen    "
txt_end
