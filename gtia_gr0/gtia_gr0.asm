;
; Playing with colors in GRAPHICS 0 + GTIA mode GRAPHICS 11 (16 colors)
; It allows coloring of each GR0 character by different color
; Based on https://www.atariarchives.org/agagd/chapter1.php#:~:text=LST%20(Listed%20BASIC)-,GTIA%20Trick,-The%20GTIA%20modes
;

CHBAS_CUSTOM_ADR = $3400

RTCLOK2 = $14
SAVMSC = $58
LAST_CHAR_ID = 15; Index of last character on screen and also in character set
GPRIOR = $26f
CHBAS = $2f4
COLOR4 = $2c8
CH = $2fc

    org $600

    ; Set chars, each for 1 color
    set_chbas
    mva #[%1100 0000] GPRIOR ; Enable GTIA GRAPHICS 11 to get 16 colors
    mva #6 COLOR4 ; Set a luminence
    
    ; Display chars (colors) in initial state
    ldy #LAST_CHAR_ID
init_char
    tya
    sta (SAVMSC), y-
    bpl init_char

    ; Wait for 1/60 sec to refresh screen
wait_screen_refresh
    lda RTCLOK2
wait_screen_refresh_inner
    cmp RTCLOK2
    beq wait_screen_refresh_inner
    
    ; Wait for key press
    lda #$ff
    cmp CH
    beq shift_chars ; No key pressed
    ; A key pressed
    sta CH
    ; Stop animation and wait for one more key to continue
wait_for_another_key
    cmp CH
    beq wait_for_another_key
    sta CH

shift_chars
    ; Shift characters (colors) to the right
    ldy #LAST_CHAR_ID
shift_char_right
    lda (SAVMSC), y
    sub #1
    and #%0000 1111 ; To get 15th char after 0th char 
    sta (SAVMSC), y-
    bpl shift_char_right
    jmp wait_screen_refresh

; Set 16 characters in a new character set, every char by different color
.macro set_chbas
    ldy #(LAST_CHAR_ID + 1) * 8 - 1 ; 16 characters, each for one color
    lda #$ff ; Start from last character (#15) that will have orange color in both nibbles
set_chbas_char
    ldx #8 ; Each character has 8 lines
set_chbas_line
    sta CHBAS_CUSTOM_ADR, y- ; Set the same color for every line of a character
    dex
    bne set_chbas_line
    sub #$11 ; Set a next color for a next character
    bcs set_chbas_char

    ; Initialize new character set
    mva #>CHBAS_CUSTOM_ADR CHBAS
.endm
