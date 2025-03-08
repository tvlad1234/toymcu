###################################
# Print string to UART function
# Parameters: address of zero-terminated string in R2
print_string:

# load character from address
out_char:
PUSH R2
LDI R2, R2

# call UART Tx function, link through RC
PUSH RC
JL RC, uart_tx
POP RC

# return if value in R2 is string terminator (0)
BZ R2, ret_print_string
POP R2

# increment message pointer
INC R2

# jump to reading and writing next character
JL R0, out_char

ret_print_string:
POP R2
JMP RC

# end print_string
###################################

###################################
# UART single byte output function
# Parameters: byte to send in lower half of R2
uart_tx:

# save data segment reg, then set data segment to I/O segment (UART is located at 0x0400)
PUSH DS
LDA DS, SEGMENT UART_DATA

# save data to be sent, then load UART status into R2
PUSH R2
uart_check: LD R2, OFFSET UART_STATUS

# if first byte of R2 is 0 (UART is not ready), check again
AND R2, R2, R1
BZ R2, uart_check

# restore data to be sent, then transmit
POP R2
ST R2, OFFSET UART_DATA
# sdfdsf
# restore DS return to main program (through RC)
POP DS

JMP RC
# end uart_tx
###################################
