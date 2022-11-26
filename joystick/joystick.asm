PMBASE_PAGE = $34
; Top visible position in GR0
PM_AREA_TOP = (PMBASE_PAGE + 2) << 8
; X position of player
INITX = $78
XLOC = $cc
; Y position of player
INITY = $32
YLOC = $cd

SDMCTL = $22f
; Player's color
COLOR_TRIG_OFF = $ba ; Olive green
COLOR_TRIG_ON = $de ; Yellow
PCOLR0 = $2C0

VRAMGR0 = $bc40
HPOSP0 = $d000
; Status of last trigger, 0 - on, 1 - off
TRIG0_LAST = $ce
TRIG0 = $d010
GRACTL = $d01d
PORTA = $d300
PMBASE = $d407

    org $600

    ; Set PM location
    mva #PMBASE_PAGE PMBASE    

    ; Clear PM area
    lda #0
    tay
clearpm
    sta PM_AREA_TOP, y+
    cpy #128
    bne clearpm

    ; Store X position
    mva #INITX XLOC
    sta HPOSP0
    ; Store Y position
    mva #INITY YLOC

    ; Set player shape
    tay
    ldx #0
prepare_player
    lda player_shape, x+
    sta PM_AREA_TOP, y+
    cpx #8
    bne prepare_player

    ; Enable player with double line resolution
    mva #42 SDMCTL
    ; Turn on player
    mva #2 GRACTL
    ; Set initial trigger status to "on" so that correct player's color is set in the "change_player_and_text" routine
    mva #0 TRIG0_LAST
read_joystick ; Read trigger and stick
    lda TRIG0
    cmp TRIG0_LAST
    seq ; No change in button state, no need to rerender player shape/color
    jsr change_player_and_text
    ; Check stick with initial delay
    jsr delay
    lda PORTA
    and #1
    beq up
    lda PORTA
    and #2
    beq down
side
    lda PORTA
    and #4
    beq left
    lda PORTA
    and #8
    beq right
    bne read_joystick

up
    ; Don't move player over top of the screen 
    lda YLOC
    cmp #$10
    beq side
    ; Start moving from top line of the player
    tay
    ldx #8
up1
    ; Move player one position up
    lda:dey:sta PM_AREA_TOP, y
    :2 iny
    dex
    bne up1
    dey
    ; Clear the original bottom line of the player 
    lda #0
    sta PM_AREA_TOP, y
    dec YLOC
    jmp side

down
    ; Don't move player below bottom of the screen 
    lda YLOC
    cmp #$68
    beq side
    ; Start moving from bottom line of the player
    add #7
    tay
down1
    ; Move player one position down
    lda:iny:sta PM_AREA_TOP, y
    :2 dey
    cpy YLOC
    bpl down1
    iny
    ; Clear the original top line of the player 
    lda #0
    sta PM_AREA_TOP, y
    inc YLOC
    jmp side

left
    ; Don't move player outside left side of the screen 
    lda XLOC
    cmp #$30
    beq read_joystick
    ; Move player one position to the left
    dec XLOC
    jmp move_player_horizontally

right
    ; Don't move player outside right side of the screen 
    lda XLOC
    cmp #$c8
    beq read_joystick
    ; Move player one position to the right
    inc XLOC

move_player_horizontally
    ; Display player on new position
    mva XLOC HPOSP0
    jmp read_joystick

delay
    ; Wait for a moment so that player's move is not so fast
    ldx #5
    ldy #0
wait
    dey
    rne
    dex
    bne wait
    rts

change_player_and_text
    sta TRIG0_LAST

    ; Invert player's shape
    ldy YLOC
    ldx #8
invert_player
    lda PM_AREA_TOP, y
    eor #$ff
    sta PM_AREA_TOP, y+
    dex
    bne invert_player

    ; Change color
    ldx #COLOR_TRIG_ON
    lda TRIG0_LAST
    beq store_color
    ldx #COLOR_TRIG_OFF
store_color
    stx PCOLR0

    ; Invert "trigger" text
    ldy #0
invert_trigger_txt
    lda trigger_txt_start, y
    eor #$80
    sta trigger_txt_start, y+
    cpy #trigger_txt_end - trigger_txt_start
    bne invert_trigger_txt
    rts

player_shape
    .by 255, 153, 153, 255, 255, 153, 153, 255

    org VRAMGR0 + 2
    .sb "** Move joystick or press "
trigger_txt_start
    .sb +$80 "trigger"
trigger_txt_end
    .sb " **"
