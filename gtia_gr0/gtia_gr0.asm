;
; Playing with colors in GRAPHICS 0 + GTIA mode GRAPHICS 11 (16 colors)
; It allows coloring of each GR0 character by different color
; Based on https://www.atariarchives.org/agagd/chapter1.php#:~:text=LST%20(Listed%20BASIC)-,GTIA%20Trick,-The%20GTIA%20modes
;

    icl "../common/keys.asm"

KEY_SPACE = $21 ; Pause animation
KEY_F = $38 ; Shift full char
KEY_H = $39 ; Shift half of char

LAST_CHAR_ID = 16; Index of last character on screen and also in character set

PREV_CHAR = $cc; Location of previously processed char when shifting half of char
LAST_SHIFT_KEY = $cd ; Last key pressed to shift characters. KEY_F means full char shifting, KEY_H means half char shifting
CHBAS_CUSTOM_ADR = $3400

RTCLOK2 = $14
SAVMSC = $58
GPRIOR = $26f
CHBAS = $2f4
COLOR4 = $2c8

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

    ; Default mode is "shift full character"
    mva #KEY_F LAST_SHIFT_KEY

    ; Wait for 1/60 sec to refresh screen
wait_screen_refresh
    lda RTCLOK2
wait_screen_refresh_inner
    cmp RTCLOK2
    beq wait_screen_refresh_inner
    
    ; Wait for a key press
    get_key_lowercase
test_keys
    cmp #KEY_F
    beq shift_full_chars
    cmp #KEY_H
    beq shift_half_chars
    cmp #KEY_SPACE
    beq wait_for_space 
    lda LAST_SHIFT_KEY
    jmp test_keys
    ; Stop animation and wait for SPACE to continue
wait_for_space
    reset_key
wait_for_space_inner
    get_key_lowercase
    cmp #KEY_SPACE
    bne wait_for_space_inner
    lda LAST_SHIFT_KEY
    jmp test_keys

shift_full_chars
    sta LAST_SHIFT_KEY
    reset_key
    ; Shift whole character (with one color) to the right
    ldy #LAST_CHAR_ID
shift_char_right
    lda (SAVMSC), y
    sub #1
    bne dec_char
    lda #16; To get 16th char after 1th char 
dec_char    
    sta (SAVMSC), y-
    bne shift_char_right
    jmp wait_screen_refresh

shift_half_chars
    sta LAST_SHIFT_KEY
    reset_key
    ; Shift a half of character (four bits) to the right so that a character can have two colors at one time (but still adjacent halves of two chars have the same color)
    ldy #16
    lda CHBAS_CUSTOM_ADR + 8
    pha
get_prev_char
    pla
    ; Low nibble of current char will be moved to high nibble of next char
    asl
    asl
    asl
    asl
    sta PREV_CHAR
    lda CHBAS_CUSTOM_ADR, y
    ; Save next char because its low nibble will be needed for next after next char
    pha
    ; High nibble of next char will be moved to low nibble of the same char
    lsr
    lsr
    lsr
    lsr
    ; Combine new high and low nibble in next char 
    ora PREV_CHAR
    ldx #8
change_lines
    sta CHBAS_CUSTOM_ADR, y+
    dex
    bne change_lines
    
    ; Check if 1th char was processed
    cpy #16
    beq wait_screen_refresh
    ; Check if last char was processed
    cpy #(LAST_CHAR_ID + 1) * 8
    bcc get_prev_char
    ; Last byte was processed, its original low nibble will be moved to high nibble byte of 1th char 
    ldy #8
    jmp get_prev_char

; Set 1 + 16 characters in a new character set, each of 16 chars by different color
.macro set_chbas
    ldy #(LAST_CHAR_ID + 1) * 8 - 1 ; 1 + 16 characters (each for one color). 0th char has always black color and will never rotate
    lda #$ff ; Start from last character (#16) that will have initial orange color in both nibbles
set_chbas_char
    ldx #8 ; Each character has 8 lines
set_chbas_line
    sta CHBAS_CUSTOM_ADR, y- ; Set the same color for every line of a character
    dex
    bne set_chbas_line
    sub #$11 ; Set a next color for a next character
    bcs set_chbas_char

    ; Set 0th character
    lda #0
set_0th_char
    sta CHBAS_CUSTOM_ADR, y- ; Set the same color for every line of a character
    bpl set_0th_char

    ; Initialize new character set
    mva #>CHBAS_CUSTOM_ADR CHBAS
.endm
