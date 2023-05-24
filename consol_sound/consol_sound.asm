;
; Playing a buzz sound
; Tone can be adjusted from keyboard
;

    icl "../common/hardware.asm"
    icl "../common/keys.asm"
    icl "../common/screen.asm"

TONE_INIT_VALUE = $80
LAST_MUTE_STATUS = $cd

TXT_POS = 40 * 11
TXT_POS_LO = $ce
; Memory
TONE = $cc

    org $600

    ; Display text
    mwa #TXT_POS TXT_POS_LO
    display_text TXT_POS_LO, txt_start, (txt_end - txt_start)

    ; Initial tone
    mva #TONE_INIT_VALUE TONE
    ; Unmute sound
    mva #0 LAST_MUTE_STATUS
check_mute_key
    ; Check if user wants to mute sound
    get_key
    cmp #KEY_M ; Mute sound
    bne check_mute_status
    ; Mute/unmute sound
    reset_key
    lda LAST_MUTE_STATUS
    eor #1
    sta LAST_MUTE_STATUS
check_mute_status
    lda LAST_MUTE_STATUS
    bne check_mute_key

    ; Check if user wants to change tone
    get_key
    cmp #KEY_U ; Increase tone
    beq increment_tone
    cmp #KEY_D ; Decrease tone
    bne switch_consol_values
    ; Decrement tone
    dec TONE
    jmp reset_ch
increment_tone
    inc TONE
reset_ch
    reset_key

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
