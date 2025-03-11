LDA R1, 1

# Jump to main program area
JL R0, pre_main

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

# check if int == 1:
LDA R3, 1
XOR R4, R3, R2
LDA CS, SEGMENT jmp_uart
BZ R4, OFFSET jmp_uart

# check if int == 2:
INC R3
XOR R4, R3, R2
LDA CS, SEGMENT jmp_timer_tick
BZ R4, OFFSET jmp_timer_tick

# check if int == 3:
INC R3
XOR R4, R3, R2
LDA CS, SEGMENT jmp_timer_cnt
BZ R4, OFFSET jmp_timer_cnt

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
# set the stack pointer
LDA R2, sp
LDI SP, R2

LDA CS, SEGMENT main
JL R0, OFFSET main
