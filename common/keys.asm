CH = $2fc

.macro get_key
    lda CH
    ; Accept even upper case
    and #%1011 1111
.endm

.macro reset_key
    mva #$ff CH
.endm
