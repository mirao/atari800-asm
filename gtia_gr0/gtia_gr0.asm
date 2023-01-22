;
; Playing with colors in GRAPHICS 0 + GTIA mode GRAPHICS 11 (16 colors)
; It allows coloring of each GR0 character by different color
; Based on https://www.atariarchives.org/agagd/chapter1.php#:~:text=LST%20(Listed%20BASIC)-,GTIA%20Trick,-The%20GTIA%20modes
;

CHBAS_CUSTOM_PAGE = $3400

SAVMSC = $58
GPRIOR = $26f
CHBAS = $2f4
COLOR4 = $2c8

    org $600

    set_chbas
    mva #[%1100 0000] GPRIOR ; Enable GTIA GRAPHICS 11 to get 16 colors
    mva #6 COLOR4 ; Set a luminence
    
    ; Display first 16 characters in GR0
    ldy #15
display_color
    tya
    sta (SAVMSC), y-
    bpl display_color
wait
    jmp wait

; Set 16 characters in a new character set, every char by different color
.macro set_chbas
    ldy #16 * 8 - 1 ; 16 characters, each for one color
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
