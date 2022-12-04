;
; Playing a buzz sound
; Tone can be adjusted from keyboard
;

KEY_M = $25 ; Mute sound
KEY_U = $0b ; Increase tone
KEY_D = $3a ; Decrease tone

TONE_INIT_VALUE = $80
LAST_MUTE_STATUS = $cd

TXT_POS = 40 * 10

; Memory
TONE = $cc
TXTLO = $cd
SAVMSC = $58
CH = $2fc
CONSOL = $d01f

    org $600

    ; Display text
    adw SAVMSC #TXT_POS TXTLO
    ldy #txt_end - txt_start
display_text
    lda txt_start, y
    sta (TXTLO), y-
    bne display_text

    ; Initial tone
    mva #TONE_INIT_VALUE TONE
    ; Unmute sound
    mva #0 LAST_MUTE_STATUS
check_mute_key
    ; Check if user wants to mute sound
    get_key
    cmp #KEY_M
    bne check_mute_status
    ; Mute/unmute sound
    mva #$ff CH
    lda LAST_MUTE_STATUS
    eor #1
    sta LAST_MUTE_STATUS
check_mute_status
    lda LAST_MUTE_STATUS
    bne check_mute_key

    ; Check if user wants to change tone
    get_key
    cmp #KEY_U
    beq increment_tone
    cmp #KEY_D
    bne switch_consol_values
    ; Decrement tone
    dec TONE
    jmp reset_ch
increment_tone
    inc TONE
reset_ch
    mva #$ff CH

switch_consol_values
    ; Switch values in CONSOL to play buzz 
    play_tone #8
    play_tone #0
    jmp check_mute_key

txt_start
    .sb "    Press 'M' to mute/unmute sound      "
    .sb "    Press 'U' or 'D' to up/down tone"
txt_end

.macro play_tone val
    ldy TONE
    dey:rne
    mva :val CONSOL
.endm

.macro get_key
    lda CH
    ; Accept even upper case
    and #%10111111
.endm
