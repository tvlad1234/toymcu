# Hello world and interrupt handler demo
# prints "Hello world!" on reset and then echoes data received over UART using interrupt

# Jump to main program area
JL R0, main

###################################
# Interrupt handler (must always be at addr 0x0002)
interrupt_handler:

# save R2, RC, CS and DS
PUSH R2
PUSH RC
PUSH CS
PUSH DS

# load uart data in R2
LDA DS, SEGMENT UART_DATA
LD R2, OFFSET UART_DATA

# call uart_tx
LDA CS, SEGMENT uart_tx
JL RC, uart_tx

# restore R2, RC, CS and DS
POP DS
POP CS
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

# load hello message address into R2 ...
LDA R2, msg_hello

# and call print_string
LDA CS, SEGMENT print_string
JL RC, print_string

# infinite loop:
LDA CS, SEGMENT inf_loop
inf_loop: JL R0, inf_loop

# end main
###################################

###################################
# data area

# Stack pointer value
sp: DW 1023

# Hello message
msg_hello: DW 'H' 'e' 'l' 'l' 'o' 32 'W' 'o' 'r' 'l' 'd' '!' 10 13 0

