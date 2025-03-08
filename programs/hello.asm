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
