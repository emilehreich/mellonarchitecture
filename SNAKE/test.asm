;    set game state memory location
.equ    HEAD_X,         0x1000  ; Snake head's position on x
.equ    HEAD_Y,         0x1004  ; Snake head's position on y
.equ    TAIL_X,         0x1008  ; Snake tail's position on x
.equ    TAIL_Y,         0x100C  ; Snake tail's position on Y
.equ    SCORE,          0x1010  ; Score address
.equ    GSA,            0x1014  ; Game state array address

.equ    CP_VALID,       0x1200  ; Whether the checkpoint is valid.
.equ    CP_HEAD_X,      0x1204  ; Snake head's X coordinate. (Checkpoint)
.equ    CP_HEAD_Y,      0x1208  ; Snake head's Y coordinate. (Checkpoint)
.equ    CP_TAIL_X,      0x120C  ; Snake tail's X coordinate. (Checkpoint)
.equ    CP_TAIL_Y,      0x1210  ; Snake tail's Y coordinate. (Checkpoint)
.equ    CP_SCORE,       0x1214  ; Score. (Checkpoint)
.equ    CP_GSA,         0x1218  ; GSA. (Checkpoint)

.equ    LEDS,           0x2000  ; LED address
.equ    SEVEN_SEGS,     0x1198  ; 7-segment display addresses
.equ    RANDOM_NUM,     0x2010  ; Random number generator address
.equ    BUTTONS,        0x2030  ; Buttons addresses

; button state
.equ    BUTTON_NONE,    0
.equ    BUTTON_LEFT,    1
.equ    BUTTON_UP,      2
.equ    BUTTON_DOWN,    3
.equ    BUTTON_RIGHT,   4
.equ    BUTTON_CHECKPOINT,    5

; array state
.equ    DIR_LEFT,       1       ; leftward direction
.equ    DIR_UP,         2       ; upward direction
.equ    DIR_DOWN,       3       ; downward direction
.equ    DIR_RIGHT,      4       ; rightward direction
.equ    FOOD,           5       ; food

; constants
.equ    NB_ROWS,        8       ; number of rows
.equ    NB_COLS,        12      ; number of columns
.equ    NB_CELLS,       96      ; number of cells in GSA
.equ    RET_ATE_FOOD,   1       ; return value for hit_test when food was eaten
.equ    RET_COLLISION,  2       ; return value for hit_test when a collision was detected
.equ    ARG_HUNGRY,     0       ; a0 argument for move_snake when food wasn't eaten
.equ    ARG_FED,        1       ; a0 argument for move_snake when food was eaten

; initialize stack pointer
addi    sp, zero, LEDS

; main
; arguments
;     none
;
; return values
;     This procedure should never return.
main:
  ; TODO: Finish this procedure.

  ; @toDO : put this subsection in the game initialization method :
  ; initalize Snake head X, Y to 0, 0 and direction to rightward
  stw zero, HEAD_X(zero)
  stw zero, HEAD_Y(zero)
  addi t1, zero, 4
  stw t1, GSA(zero)
  ; initialize Snake tail X, Y to 0, 0
  stw zero, TAIL_X(zero)
  stw zero, TAIL_Y(zero)

  ;gameLoop:
    ;call clear_leds
    ;call get_input

    ; @toDo : add collision testing

    ; @toDo : generate new food if precedent one has been eaten

    call move_snake
    ;call draw_array

    ; @toDO : add the wait procedure

    ; @toDO : add conditional end of the game
    ;call gameLoop

  ret

; BEGIN: clear_leds
clear_leds:
  stw zero, LEDS(zero)
  stw zero, LEDS+4(zero)
  stw zero, LEDS+8(zero)
  ret
; END: clear_leds


; BEGIN: set_pixel
set_pixel:

  ; compute which of the three LEDS word to access
  andi t1, a0, 12

  ; load the word into register
  ldw t2, LEDS(t1)

  ; compute the mask
  addi t3, zero, 1 ; compute the mask given y
  sll t3, t3, a1

  andi t4, a0, 3    ; prepare the X shift
  slli t4, t4, 3

  sll t3, t3, t4 ; complete mask
  ; apply mask
  or t2, t2, t3
  ; push word into memory
  stw t2, LEDS(t1)
  ret
; END: set_pixel


; BEGIN: display_score
display_score:

; END: display_score


; BEGIN: init_game
init_game:

; END: init_game


; BEGIN: create_food
create_food:
;loop till a valid value to create food is generated
  ;read random value from RANDOM_NUM
  load_word:

  ldw t1, RANDOM_NUM(zero)
  ;mask of 8 LSB bits to extract the last byte
  addi t2, zero, 1
  slli t2, t2, 8
  and t3, t2, t1
  addi t4, zero, 96 ; offset

  bltu t3, t4, set_value
  jmpi load_word

  set_value:
  addi t5, zero, 5
  stw t5, GSA(t3)
  ret
; END: create_food

; BEGIN: hit_test
hit_test:

; END: hit_test


; BEGIN: get_input
; return value v0, which button is pressed
get_input:

  ; get button state array and reset
  ldw t1, BUTTONS+4(zero)
  andi t1, t1, 31
  stw zero, BUTTONS+4(zero)

  ; position of head in GSA
  ldw t2, HEAD_X(zero) ;snakeHeadX
  slli t2, t2, 5
  ldw t3, HEAD_Y(zero) ;snakeHeadY
  slli t3, t3, 2
  add t4, t3, t2
  addi t4, t4, GSA ;address of X, Y in GSA
  ldw t5, 0(t4)    ; gsa value at the head

  ; loop through each button
  addi v0, zero, 0    ;initial return value set to 0
  addi t6, zero, 4    ;current iteration number
  loop:
    ; look if iteration button is active or not
    srl t2, t1, t6
    andi t2, t2, 1
    addi t3, zero, 1
    beq t2, t3, activateButton
  reloop:
    ; update cursor and loop control
    addi t3, zero, 1
    sub t6, t6, t3
    bge t6, zero, loop
    ret

  ; activated button part
  activateButton:
    addi t7, zero, BUTTON_CHECKPOINT
    addi t3, t6, 1                    ;maps the buttonNumber with the direction
    beq t3, t7, checkpointTrigger
    br buttonTrigger
  checkpointTrigger:
    addi v0, zero, BUTTON_CHECKPOINT
    ret
  buttonTrigger:
    add t7, t3, t5
    addi t2, zero, 5       ;compute currentDirection and newDirection sum
    bne t7, t2, setButton  ; if the sum is different from 5 they are opposite
    br reloop
  setButton:
    ;set button
    stw t3, 0(t4)
    addi v0, t3, 0
    ret
; END: get_input


; BEGIN: draw_array
draw_array:

  iterate:  ;argument a3, index in GSM
  ;compute x and y arguments
  andi a1, a3, 7
  sub t2, a3, a1
  srai a0, t2, 3
  bge a1, zero, set_pixel
  addi a3, a3, 1
  addi t1, zero, 96
  bltu a3, t1, iterate
  ret

; END: draw_array


; BEGIN: move_snake
move_snake:

  ldw t1, HEAD_X(zero)  ; snakeHeadX
  ldw t2, HEAD_Y(zero)  ; snakeHeadY

  addi t7, ra, 0        ; put rA in a space we won't touch
  call GSAconversion
  ldw t4, 0(t3)         ; direction value at the head
  call updateXY
  stw t1, HEAD_X(zero)  ; update the head X
  stw t2, HEAD_Y(zero)  ; update the head Y
  call GSAconversion
  stw t4, 0(t3)         ; store old head direction in the new head GSA word
  addi ra, t7, 0        ; restore rA

  beq a0, zero, moveTail  ; if a0 == 0, then the tail should be updated
  ret

  moveTail:
    ldw t1, TAIL_X(zero) ;snakeTailX
    ldw t2, TAIL_Y(zero) ;snakeTailY

    addi t7, ra, 0     ; put rA in a space we won't touch
    call GSAconversion
    stw zero, 0(t3)       ; remove the tail
    call updateXY
    stw t1, TAIL_X(zero)  ; update the tail X
    stw t2, TAIL_Y(zero)  ; update the tail Y
    addi ra, t7, 0        ; restore rA
    ret

  GSAconversion:
    slli t1, t1, 5
    slli t2, t2, 2
    add t3, t2, t1
    addi t3, t3, GSA  ; address of X, Y in GSA format
    ret

  updateXY:
    addi t5, zero, 1
    beq t4, t5, moveLeft
    addi t5, zero, 2
    beq t4, t5, moveTop
    addi t5, zero, 3
    beq t4, t5, moveDown
    addi t5, zero, 4
    beq t4, t5, moveRight
    moveLeft:
      addi t6, zero, 1
      sub t1, t1, t6
      ret
    moveTop:
      addi t6, zero, 1
      sub t2, t2, t6
      ret
    moveDown:
      addi t2, t2, 1
      ret
    moveRight:
      addi t1, t1, 1
      ret

; END: move_snake


; BEGIN: save_checkpoint
save_checkpoint:

; END: save_checkpoint


; BEGIN: restore_checkpoint
restore_checkpoint:

; END: restore_checkpoint


; BEGIN: blink_score
blink_score:

; END: blink_score
