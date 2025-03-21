
# Jump to main program area
LDA CS, SEGMENT pre_main
JL R0, OFFSET pre_main

###################################
# Interrupt handler (must always be at addr 0x0002)
interrupt_handler:

PUSH RC
PUSH CS
PUSH DS
PUSH R2
PUSH R3
PUSH R4

LDA DS, SEGMENT INT_CTRL
LD R2, OFFSET INT_CTRL

# UART
LDA R3, 1
AND R4, R3, R2
LDA CS, SEGMENT jmp_uart
BP R4, OFFSET jmp_uart

# Timer tick
LS R3, R3, R1
AND R4, R3, R2
LDA CS, SEGMENT jmp_timer_tick
BP R4, OFFSET jmp_timer_tick

# Timer counter compare
LS R3, R3, R1
AND R4, R3, R2
LDA CS, SEGMENT jmp_timer_cnt
BP R4, OFFSET jmp_timer_cnt

# Return from interrupt (JMP R0 will eventually be an IRET macro)
int_ret:
  POP R4
  POP R3
  POP R2
  POP DS
  POP CS
  POP RC

  JMP R0

jmp_uart:
  CALL uart_int
  LDA CS, SEGMENT int_ret
  JL R0, OFFSET int_ret

jmp_timer_tick:
  CALL timer_tick_int
  LDA CS, SEGMENT int_ret
  JL R0, OFFSET int_ret

jmp_timer_cnt:
  CALL timer_cnt_int
  LDA CS, SEGMENT int_ret
  JL R0, OFFSET int_ret

# end interrupt_handler
###################################

# Stack pointer value
sp: DW 1023

pre_main:
LDA R1, 1

# set the stack pointer
LDA DS, SEGMENT sp
LD SP, OFFSET sp

LDA CS, SEGMENT main
JL R0, OFFSET main
