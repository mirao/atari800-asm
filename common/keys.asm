CH = $2fc

.macro get_key_lowercase
    lda CH
    ; Accept even upper case
    and #%1011 1111
.endm

.macro get_key
    lda CH
.endm

.macro reset_key
    mva #$ff CH
.endm
