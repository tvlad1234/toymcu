# Hello world and interrupt handler demo
# prints "Hello world!" on reset and then echoes data received over UART using interrupt

# Jump to main program area
JL R0, main

###################################
# Interrupt handler (must always be at addr 0x0002)
interrupt_handler:

# save R2, RC and DS
PUSH R2
PUSH RC
PUSH DS

# load uart status in R2
LDA DS, SEGMENT UART_DATA
LD R2, OFFSET UART_STATUS

# if third byte of R2 is 0 (no character received), loop around
RS R2, R2, R1
RS R2, R2, R1
AND R2, R2, R1
BZ R2, inf_loop

# else read character and send it over uart
LD R2, OFFSET UART_DATA
JL RC, uart_tx

# restore R2, RC and DS
POP DS
POP RC
POP R2

# Return from interrupt (JMP R0 will eventually be an IRET macro)
JMP R0
# end interrupt_handler
###################################

###################################
# Main program
main:

# set the stack pointer
LDA R2, sp
LDI SP, R2

# load hello message address into R2 and call print_string
LDA R2, msg_hello
JL RC, print_string

# infinite loop:
inf_loop:
JL R0, inf_loop

# end main
###################################

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

# restore DS return to main program (through RC)
POP DS

JMP RC
# end uart_tx
###################################

###################################
# data area

# Stack pointer value
sp: DW 1023

# Hello message
msg_hello: DW 'H' 'e' 'l' 'l' 'o' 32 'W' 'o' 'r' 'l' 'd' '!' 10 13 0
