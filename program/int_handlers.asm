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


###################################
# Timer tick interrupt
timer_tick_int:

# load 'T' into R2
LDA R2, 84

# call uart_tx
LDA CS, SEGMENT uart_tx
PUSH RC
JL RC, OFFSET uart_tx
POP RC

# return to interrupt handler
JMP RC

# end timer_tick_int
###################################


###################################
# Timer counter interrupt
timer_cnt_int:

# toggle GPIO bit 0
LDA DS, SEGMENT GPIO_DATA
LDA R2, 0x01
ST R2, OFFSET GPIO_TOGGLE

# load message address in R2
LDA R2, OFFSET msg_timer

# call print_string
LDA CS, SEGMENT print_string
PUSH RC
JL RC, OFFSET print_string
POP RC

# return to interrupt handler
JMP RC

# end timer_cnt_int
###################################

msg_timer: DW 10 13 'T' 'i' 'm' 'e' 'r' 32 'i' 'n' 't' 'e' 'r' 'r' 'u' 'p' 't' 10 13 0
