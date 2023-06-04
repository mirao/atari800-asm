.ifndef SAVMSC 
    icl "hardware.asm"
.endif

GR0_LINE_LENGTH = 40 ; Length of a line in graphics mode 0
VRAM = $e2 ; Vector to a part of screen memory where text is displayed

; Display text on screen
;
; Input:
;   screen_pos ... a page address with a position of text on screen relative to upper left corner of screen
;   txt_start  ... an absolute address of text to display
;   txt_length ... a byte length of text to display
;
; Example: display_text TEXT_DISPLAY_LO, txt_hello, (txt_hello_end - txt_hello_start)
;
.macro display_text (screen_pos, txt_start, txt_length)
    adw SAVMSC :screen_pos VRAM
    ldy #0
display_char
    lda :txt_start, y
    sta (VRAM), y+
    cpy #:txt_length
    bcc display_char
.endm

; Clear a text message
;
; Input:
;   screen_pos ... a page address with a position of text on screen relative to upper left corner of screen
;   txt_length ... a byte length of text to clear
;
; Example: clear_text TEXT_CLEAR_LO, (txt_hello_end - txt_hello_start)
;
.macro clear_text (screen_pos, txt_length)
    adw SAVMSC :screen_pos VRAM
    ldy #0
    lda #" "
clear_char
    sta (VRAM), y+
    cpy #:txt_length
    bcc clear_char
.endm

; Invert a text message
;
; Input:
;   scr_pos_start ... a start position of text in screen ram you want to invert
;   scr_pos_end   ... one byte after end position of text in screen ram you want to invert
;
; Example: invert_text (trigger_txt_start - txt_start), (trigger_txt_end - txt_start)
;
.macro invert_text (scr_pos_start, scr_pos_end)
    ldy #:scr_pos_start
invert_char
    lda (SAVMSC), y
    eor #$80
    sta (SAVMSC), y+
    cpy #:scr_pos_end
    bcc invert_char
.endm
