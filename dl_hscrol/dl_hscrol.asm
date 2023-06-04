;
; Horizontal fine scrolling
;

    icl "../common/hardware.asm"
    icl "../common/screen.asm"

TXT_LEN = (txt_end - txt_start)
; Position of text on screen relative to upper left corner of screen.
; The first 3 bytes of text are from wide playfield and they're not used. They are allocated for horizontal fine scrolling.
TXT_POS = GR0_LINE_LENGTH * 11 + (GR0_LINE_LENGTH - TXT_LEN) / 2 + 3
TXT_POS_LO = $cb ; Low byte of TXT_POS
HSCROL_LAST = $cd ; Last value of horizontal fine scrolling

.macro reset_hscrol
    lda #3
    sta HSCROL_LAST
.endm

    org $600

    reset_hscrol 
    sta HSCROL ; Set initial scrolling before initial text is displayed so that a text motion won't be jerky after 1st VBI

    ; Init screen
    mwa #TXT_POS TXT_POS_LO ; Set position of text on screen
    ; Display text
    display_text TXT_POS_LO, txt_start, TXT_LEN
    ; Prepare last char that will be shown when rotating 1st char to the left
    jsr copy_1st_char_to_41st_char

    ; Init dlist and horizontal fine scrolling for a text line (GR0)
    jsr init_dlist_vector
    ldy #16
    lda #2 + HS_MODIFIER
    sta (DL), y

    ; Init VBI
    ldy #<vbi
    ldx #>vbi
    lda #7
    jsr SETVBV
loop
    jmp loop

vbi
    lda RTCLOK2
    lsr
    bcc exitvbi ; Scroll only every 2nd VBI (once per two frames) so that scrolling isn't too fast
    dec HSCROL_LAST ; Scroll a char one color clock (2 pixels) to the left
    bpl set_hscrol
    ldy #0
    ; Fine scrolling by one char done
    ; Rotate all chars on line to the left so  that fine scrolling by one more char can be done
rotate
    iny
    lda (VRAM), y
    dey
    sta (VRAM), y
    iny
    cpy #GR0_LINE_LENGTH
    bcc rotate
    jsr copy_1st_char_to_41st_char
    reset_hscrol
set_hscrol
    lda HSCROL_LAST
    sta HSCROL
exitvbi
    jmp XITVBV

    ; Copy 1st char to 41st char because of rotation
    ; It allows fluent hiding of 1st char when moving outside screen and showing at the end of line
copy_1st_char_to_41st_char
    ldy #0
    lda (VRAM), y
    ldy #GR0_LINE_LENGTH
    sta (VRAM), y
    rts

    icl "../common/dlist.asm"
txt_start
    .sb "It scrolls by HSCROL and VRAM mem copy. " ; Text must fit 40 chars
txt_end
