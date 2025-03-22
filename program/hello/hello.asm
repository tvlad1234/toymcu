# Hello world and interrupt handler demo
# prints "Hello world!" on startup
# echoes data received over UART
# displays a message and toggles a GPIO line every second

###################################
# Main program
main:

# configure timer

# retrieve prescaler value from memory ...
LDA DS, SEGMENT presc_value
LD R2, OFFSET presc_value

# and write it to the timer
LDA DS, SEGMENT TIM_PRESC
ST R2, OFFSET TIM_PRESC

# retrieve counter compare value from memory ...
LDA DS, SEGMENT cmp_value
LD R2, OFFSET cmp_value

# and write it to the timer
LDA DS, SEGMENT TIM_CNT_CMP
ST R2, OFFSET TIM_CNT_CMP

# enable timer
LDA R2, 1
ST R2, OFFSET TIM_EN

# load hello message address into R2 ...
LDA R3, SEGMENT msg_hello
LDA R2, 8
LS R3, R3, R2
LDA R2, OFFSET msg_hello
ADD R2, R2, R3

# and call print_string
CALL print_string

# load interrupt handler address into R2 and write it to the interrupt controller
LDA R3, SEGMENT interrupt_handler
LDA R2, 8
LS R3, R3, R2
LDA R2, OFFSET interrupt_handler
ADD R2, R2, R3

LDA DS, SEGMENT INT_ADDR
ST R2, OFFSET INT_ADDR

# enable UART and timer counter interrupts (bits 0 and 2 of the interupt enable register)
LDA R2, 5
ST R2, OFFSET INT_EN

# infinite loop:
LDA CS, SEGMENT inf_loop
inf_loop: JL R0, OFFSET inf_loop

# end main
###################################

###################################

msg_hello: DW 'H' 'e' 'l' 'l' 'o' 32 'W' 'o' 'r' 'l' 'd' '!' 10 13 0

# Timer prescaler value
presc_value: DW 0xFFFF

# Timer counter compare value (25MHz / 0xFF / 381 = 1Hz)
cmp_value: DW 381
