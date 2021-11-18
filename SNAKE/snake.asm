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
addi sp, zero, LEDS

; initialize CP_Valid to be zero
stw zero, CP_VALID(zero)

; main
; arguments
;     none
;
; return values
;     This procedure should never return.
main:
  ; TODO: Finish this procedure.

  call init_game

  gameLoop:
    call wait
    call get_input
    addi t1, zero, BUTTON_CHECKPOINT
    beq v0, t1, checkpointButton
    br noreset

    checkpointButton:
      call restore_checkpoint

      addi t1, zero, 1
      beq t1, v0, blinkRestore
      br gameLoop

      blinkRestore:
        ;@toDO : add led blinking
        br gameLoop

    noreset:
      call hit_test
      add a0, v0, zero
      addi t1, zero, RET_COLLISION
      beq v0, t1, deadEnd   ; reset game if collision
      call move_snake
      addi t1, zero, RET_ATE_FOOD
      beq v0, t1, createFoodNupdateScore    ; generate new food if precedent one has been eaten
      br continue   ; continue if none of the two previous condition

    createFoodNupdateScore:
      call create_food
      ldw t1, SCORE(zero)
      addi t1, t1, 1
      stw t1, SCORE(zero)

      call save_checkpoint
      addi t1, zero, 1
      beq v0, t1, blinkLedsNewCheckpoint
      br continue

      blinkLedsNewCheckpoint:
        ;@toDO : add led blinking
        br continue

    continue:
      call clear_leds
      call draw_array
      br gameLoop
    deadEnd:
      call wait
      br main

; BEGIN: clear_leds
clear_leds:
  stw zero, LEDS(zero)
  stw zero, LEDS+4(zero)
  stw zero, LEDS+8(zero)
  ret
; END: clear_leds

; BEGIN: clear_leds

wait:
  addi t1, zero, 7071
  addi t2, zero, 0
  addi t3, zero, 442
  addi t4, zero, 0

  iter:
    addi t2, t2, 1
    beq t2, t1, nextIteration
  relp:
    br iter

  nextIteration:
    addi t4, t4, 1
    addi t2, zero, 0
    beq t4, t3, return
    br iter

  return:
    ret
; END: wait


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

;digit_map:
;.word 0xFC ; 0
;.word 0x60 ; 1
;.word 0xDA ; 2
;.word 0xF2 ; 3
;.word 0x66 ; 4
;.word 0xB6 ; 5
;.word 0xBE ; 6
;.word 0xE0 ; 7
;.word 0xFE ; 8
;.word 0xF6 ; 9

; BEGIN: display_score
display_score:
  ;load word SCORE
  ;ldw t1, SCORE(zero)

  ;substract 10 until score <10
  ;digit 1 : number of times we substract 10
  ;digit 2 : the result of the substraction

  ;t3 counts the number of substraction
  ;t2 takes the value of the substraction
  ;ret
; END: display_score


; BEGIN: init_game
init_game:
  ;initialize Snake head X, Y to 0, 0
  stw zero, HEAD_X(zero)
  stw zero, HEAD_Y(zero)

  ;initialize Snake head direction to rightWard
  addi t1, zero, DIR_RIGHT
  stw t1, GSA(zero)

  ;initialize Snake tail X, Y to 0, 0
  stw zero, TAIL_X(zero)
  stw zero, TAIL_Y(zero)

  ;initialize score to be 0
  stw zero, SCORE(zero)

  ; reinitialize GSA score to be full of 0 (erase precedent game data)
  addi t1, zero, NB_CELLS
  addi t2, zero, 1
  resetLoop:
    slli t3, t2, 2
    stw zero, GSA(t3)
    addi t2, t2, 1
    addi t4, zero, NB_CELLS
    beq t2, t4, finishInit
    br resetLoop
  finishInit:
    addi sp, sp, -4
    stw ra, 0(sp)         ; put ra in the stack
    call set_pixel
    call create_food
    call clear_leds
    call draw_array
    ldw ra, 0(sp)         ; get ra from the stack
    addi sp, sp, 4
    ret
; END: init_game


; BEGIN: create_food
create_food:
;loop till a valid value to create food is generated
  ;read random value from RANDOM_NUM
  load_word:
    ldw t1, RANDOM_NUM(zero)
    ;mask of 8 LSB bits to extract the last byte
    addi t2, zero, 0x00FF
    and t3, t2, t1
    addi t4, zero, NB_CELLS ; offset

    bltu t3, t4, check_content
    jmpi load_word

  check_content:
    slli t3, t3, 2
    ldw t5, GSA(t3)
    beq t5, zero, set_value
    jmpi load_word

  set_value:
    addi t6, zero, FOOD
    stw t6, GSA(t3)
    ret
; END: create_food

; BEGIN: hit_test
hit_test:
  ldw t1, HEAD_X(zero) ; snakeHeadX
  ldw t2, HEAD_Y(zero) ; snakeHeadY
  slli t3, t1, 5
  slli t4, t2, 2
  add t3, t3, t4
  addi t3, t3, GSA ; address of X, Y in GSA format
  ldw t3, 0(t3)    ; direction value at the head in GSA

  addi t4, zero, DIR_LEFT
  beq t3, t4, leftCheck
  addi t4, zero, DIR_UP
  beq t3, t4, upCheck
  addi t4, zero, DIR_DOWN
  beq t3, t4, downCheck
  addi t4, zero, DIR_RIGHT
  beq t3, t4, rightCheck
  leftCheck:
    addi t4, zero, 1
    sub t1, t1, t4
    addi t4, zero, 0
    blt t1, t4, deadCollision   ; check for out of range X
    br checkNextCell
  upCheck:
    addi t4, zero, 1
    sub t2, t2, t4
    addi t4, zero, 0
    blt t2, t4, deadCollision   ; check for out of range Y
    br checkNextCell
  downCheck:
    addi t2, t2, 1
    addi t4, zero, NB_ROWS
    bge t2, t4, deadCollision   ; check for out of range Y
    br checkNextCell
  rightCheck:
    addi t1, t1, 1
    addi t4, zero, NB_COLS
    bge t1, t4, deadCollision   ; check for out of range X
    br checkNextCell

  checkNextCell:
    slli t3, t1, 5
    slli t4, t2, 2
    add t3, t3, t4
    addi t3, t3, GSA ; address of X, Y in GSA format
    ldw t3, 0(t3)    ; direction value at the head in GSA

    addi t4, zero, 1
    bge t3, t4, collision  ; collision encountered
    addi v0, zero, ARG_HUNGRY
    ret

  collision:
    ; determine the kind of collision

    addi t4, zero, FOOD
    beq t3, t4, foodCollision
    br deadCollision
  deadCollision:
    addi v0, zero, RET_COLLISION
    ret
  foodCollision:
    addi v0, zero, RET_ATE_FOOD
    ret
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
  ldw t3, HEAD_Y(zero) ;snakeHeadY
  slli t2, t2, 5
  slli t3, t3, 2
  add t4, t3, t2
  addi t4, t4, GSA ; address of X, Y in GSA format
  ldw t5, 0(t4)    ; direction value at the head in GSA

  ; loop through each button
  addi v0, zero, 0    ; initial return value set to 0
  addi t6, zero, 4    ; current iteration number
  loop:
    ; look if iteration button is active or not
    srl t2, t1, t6
    andi t2, t2, 1
    addi t3, zero, 1
    beq t2, t3, activateButton
  reloop:
    ; update cursor and reloop if necessarily
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
    bne t7, t2, setButton  ; if the sum is equal 5 they are opposite
    br reloop
  setButton:
    ;set button
    stw t3, 0(t4)
    addi v0, t3, 0
    ret
; END: get_input


; BEGIN: draw_array
draw_array:

  addi t7, zero, 0

  iterate:
    ;compute x and y arguments
    andi a1, t7, 7
    sub t2, t7, a1
    srai a0, t2, 3
    add t6, zero, t7
    slli t6, t6, 2
    ldw t3, GSA(t6)
    addi t4, zero, 1
    bge t3, t4, call_set_pixel

  iteration_termination:
    addi t7, t7, 1
    addi t1, zero, 96
    bltu t7, t1, iterate
    ret

  call_set_pixel:
    addi sp, sp, -4
    stw ra, 0(sp)         ; put rA in the stack
    addi sp, sp, -4
    stw t7, 0(sp)           ; put t7 in the stack

    call set_pixel

    ldw t7, 0(sp)        ; get t7 from the stack
    addi sp, sp, 4
    ldw ra, 0(sp)        ; get rA from the stack
    addi sp, sp, 4
    br iteration_termination

; END: draw_array


; BEGIN: move_snake
move_snake:

  ldw t1, HEAD_X(zero)  ; snakeHeadX
  ldw t2, HEAD_Y(zero)  ; snakeHeadY

  addi sp, sp, -4
  stw ra, 0(sp)        ; put rA in the stack

  call GSAconversion
  ldw t5, 0(t3)         ; direction value at the head
  call updateXY
  stw t1, HEAD_X(zero)  ; update the head X
  stw t2, HEAD_Y(zero)  ; update the head Y
  call GSAconversion
  stw t5, 0(t3)         ; store old head direction in the new head GSA word

  ldw ra, 0(sp)        ; get rA from the stack
  addi sp, sp, 4

  beq a0, zero, moveTail  ; if a0 == 0, then the tail should be updated
  ret

  moveTail:
    ldw t1, TAIL_X(zero) ;snakeTailX
    ldw t2, TAIL_Y(zero) ;snakeTailY

    addi sp, sp, -4
    stw ra, 0(sp)        ; put rA in the stack

    call GSAconversion

    ldw t5, 0(t3)         ; get old GSA word at the tail
    stw zero, 0(t3)       ; remove the tail

    call updateXY

    stw t1, TAIL_X(zero)  ; update the tail X
    stw t2, TAIL_Y(zero)  ; update the tail Y

    ldw ra, 0(sp)        ; get rA from the stack
    addi sp, sp, 4
    ret

  GSAconversion:
    slli t3, t1, 5
    slli t4, t2, 2
    add t3, t3, t4
    addi t3, t3, GSA  ; address of X, Y in GSA format
    ret

  updateXY:
    addi t6, zero, DIR_LEFT
    beq t5, t6, moveLeft
    addi t6, zero, DIR_UP
    beq t5, t6, moveTop
    addi t6, zero, DIR_DOWN
    beq t5, t6, moveDown
    addi t6, zero, DIR_RIGHT
    beq t5, t6, moveRight
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
  ldw t1, SCORE(zero)

  ; we assume the score not to be bigger thant 100
  addi t2, zero, 10
  beq t1, t2, valid
  addi t2, zero, 20
  beq t1, t2, valid
  addi t2, zero, 30
  beq t1, t2, valid
  addi t2, zero, 40
  beq t1, t2, valid
  addi t2, zero, 50
  beq t1, t2, valid
  addi t2, zero, 60
  beq t1, t2, valid
  addi t2, zero, 70
  beq t1, t2, valid
  addi t2, zero, 80
  beq t1, t2, valid
  addi t2, zero, 90
  beq t1, t2, valid
  addi v0, zero, 0
  ret

  valid:
    ; return value set to 1
    addi v0, zero, 1

    ; save score
    stw t1, CP_SCORE(zero)

    ; set CP_VALID to one
    addi t1, zero, 1
    stw t1, CP_VALID(zero)

    ; save head and tail
    ldw t1, HEAD_X(zero)
    stw t1, CP_HEAD_X(zero)
    ldw t1, HEAD_Y(zero)
    stw t1, CP_HEAD_Y(zero)
    ldw t1, TAIL_X(zero)
    stw t1, CP_TAIL_X(zero)
    ldw t1, TAIL_Y(zero)
    stw t1, CP_TAIL_Y(zero)

    ; copy GSA array
    addi t1, zero, NB_CELLS
    addi t2, zero, 0
    gsaCopyLoop:
      slli t3, t2, 2
      ldw t4, GSA(t3)
      stw t4, CP_GSA(t3)
      addi t2, t2, 1
      beq t2, t1, returnValidCheckPoint
      br gsaCopyLoop

    returnValidCheckPoint:
      ret

; END: save_checkpoint


; BEGIN: restore_checkpoint
restore_checkpoint:
  ldw t1, CP_VALID(zero)
  addi t2, zero, 1
  beq t1, t2, resetCheckPoint
  addi v0, zero, 0
  ret

  resetCheckPoint:
    ; return value set to 1
    addi v0, zero, 1

    ; reset score
    ldw t1, CP_SCORE(zero)
    stw t1, SCORE(zero)

    ; reset head and tail
    ldw t1, CP_HEAD_X(zero)
    stw t1, HEAD_X(zero)
    ldw t1, CP_HEAD_Y(zero)
    stw t1, HEAD_Y(zero)
    ldw t1, CP_TAIL_X(zero)
    stw t1, TAIL_X(zero)
    ldw t1, CP_TAIL_Y(zero)
    stw t1, TAIL_Y(zero)

    ; reset GSA array
    addi t1, zero, NB_CELLS
    addi t2, zero, 0
    gsaCPCopyLoop:
      slli t3, t2, 2
      ldw t4, CP_GSA(t3)
      stw t4, GSA(t3)
      addi t2, t2, 1
      beq t2, t1, returnResetDone
      br gsaCPCopyLoop

    returnResetDone:
      addi sp, sp, -4
      stw ra, 0(sp)        ; put rA in the stack
      call clear_leds
      call draw_array
      ldw ra, 0(sp)        ; get rA from the stack
      addi sp, sp, 4
      ret

; END: restore_checkpoint


; BEGIN: blink_score
blink_score:

; END: blink_score
