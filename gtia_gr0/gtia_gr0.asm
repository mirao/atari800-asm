;
; Playing with colors in GRAPHICS 0 + GTIA mode GRAPHICS 11 (16 colors)
; It allows coloring of each GR0 character by different color
; Based on https://www.atariarchives.org/agagd/chapter1.php#:~:text=LST%20(Listed%20BASIC)-,GTIA%20Trick,-The%20GTIA%20modes
;

CHBAS_CUSTOM_PAGE = $3400

RTCLOK2 = $14
SAVMSC = $58
LAST_CHAR_SET_ID = 15; Index of last character in character set
LAST_CHAR_SCREEN_ID = $cc ; Index of character saved on the last position on screen. It determines a char color, e.g. 15 (orange) or 7 (blue)
GPRIOR = $26f
CHBAS = $2f4
COLOR4 = $2c8
CH = $2fc

    org $600

    set_chbas
    mva #[%1100 0000] GPRIOR ; Enable GTIA GRAPHICS 11 to get 16 colors
    mva #6 COLOR4 ; Set a luminence
    
    ; Initialize last character (color), it will be decreased with every rotation to get a rotation effect
    ldy #LAST_CHAR_SET_ID + 1
    sty LAST_CHAR_SCREEN_ID

    ; Wait for 1/60 sec to refresh screen
wait_screen_refresh
    lda RTCLOK2
wait_screen_refresh_inner
    cmp RTCLOK2
    beq wait_screen_refresh_inner
    
    ; Wait for key press
    lda #$ff
    cmp CH
    beq continue_animation ; No key pressed
    ; A key pressed
    sta CH
    ; Stop animation and wait for one more key to continue
wait_for_another_key
    cmp CH
    beq wait_for_another_key
    sta CH

continue_animation
    ; Display first 16 characters in GR0 with position shifted to the right from last state
    ldy #LAST_CHAR_SET_ID
    ldx LAST_CHAR_SCREEN_ID
get_next_char
    dex
    bpl is_the_char_last
    ldx #LAST_CHAR_SET_ID
is_the_char_last
    cpy #LAST_CHAR_SET_ID
    bne save_char
    ; Store last character index for next rotation
    stx LAST_CHAR_SCREEN_ID
save_char
    txa
    sta (SAVMSC), y-
    bpl get_next_char
    jmp wait_screen_refresh

; Set 16 characters in a new character set, every char by different color
.macro set_chbas
    ldy #(LAST_CHAR_SET_ID + 1) * 8 - 1 ; 16 characters, each for one color
    lda #$ff ; Start from last character (#15) that will have orange color in both nibbles
set_chbas_char
    ldx #8 ; Each character has 8 lines
set_chbas_line
    sta CHBAS_CUSTOM_PAGE, y- ; Set the same color for every line of a character
    dex
    bne set_chbas_line
    sub #$11 ; Set a next color for a next character
    bcs set_chbas_char

    ; Initialize new character set
    mva #>CHBAS_CUSTOM_PAGE CHBAS
.endm
