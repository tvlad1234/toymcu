###################################
# Print string to UART function
# Parameters: address of zero-terminated string in R2
print_string:
PUSH CS
PUSH R2
PUSH R3

ADD R3, R0, R2

# load character from address
out_char:
  LDI R2, R3

# return if value in R2 is string terminator (0)
  LDA CS, SEGMENT ret_print_string
  BZ R2, OFFSET ret_print_string

# call UART Tx function, link through RC
  PUSH RC
  LDA CS, SEGMENT uart_tx
  JL RC, OFFSET uart_tx
  POP RC

# increment message pointer
INC R3

# jump to reading and writing next character
LDA CS, SEGMENT out_char
JL R0, OFFSET out_char

ret_print_string:
  POP R3
  POP R2
  POP CS
  JMP RC

# end print_string
###################################

###################################
# UART single byte output function
# Parameters: byte to send in lower half of R2
uart_tx:

# save data segment reg, then set data segment to I/O segment (UART is located at 0x0400)
PUSH CS
PUSH DS
LDA DS, SEGMENT UART_DATA
LDA CS, SEGMENT uart_check

# save data to be sent, then load UART status into R2
PUSH R2
uart_check: LD R2, OFFSET UART_STATUS

# if first byte of R2 is 0 (UART is not ready), check again
AND R2, R2, R1
BZ R2, OFFSET uart_check

# restore data to be sent, then transmit
POP R2
ST R2, OFFSET UART_DATA

# restore DS and return to main program (through RC)
POP DS
POP CS
JMP RC

# end uart_tx
###################################
