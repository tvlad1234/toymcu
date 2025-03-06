# Hello world program

main:

# set the stack pointer
LDA R2, sp
LDI SP, R2

# load message segment into R3 and shift 8 positions
LDA R3, msg

# load character into R2, from address in R3
out_char:
LDI R2, R3

# call UART Tx function, link through RC
JL RC, uart_tx

# exit if value in R2 is string terminator (0)
BZ R2, exit

# increment message pointer (R3)
INC R3

# jump to reading and writing next character
JL R0, out_char

exit: HALT

###################################
# UART output function

uart_tx:

# save data segment reg, then set data segment to I/O segment (UART is located at 0x0400)
PUSH DS
LDA DS, SEGMENT 0x0400

# save data to be sent, then load UART status into R2
PUSH R2
uart_check: LD R2, 0

# if R2==0 (UART is not ready), check again
BZ R2, uart_check

# restore data to be sent, then transmit
POP R2
ST R2, 0

# restore DS return to main program (through RC)
POP DS
JMP RC

###################################

###################################
# data area

# Stack pointer value
sp: DW 1023

# Hello message
msg: DW 'H' 'e' 'l' 'l' 'o' 32 'W' 'o' 'r' 'l' 'd' 10 13 0
