.ifndef CH 
    icl "hardware.asm"
.endif

KEY_SPACE = $21
KEY_D     = $3a
KEY_F     = $38
KEY_H     = $39
KEY_M     = $25
KEY_U     = $0b

.macro get_key
    lda CH
.endm

.macro reset_key
    mva #$ff CH
.endm
