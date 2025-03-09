###################################
# UART interrupt
uart_int:

# load uart data in R2
LDA DS, SEGMENT UART_DATA
LD R2, OFFSET UART_DATA

# call uart_tx
LDA CS, SEGMENT uart_tx
PUSH RC
JL RC, OFFSET uart_tx
POP RC

# return to interrupt handler
JMP RC

# end uart_int
###################################