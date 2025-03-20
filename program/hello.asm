# Hello world and interrupt handler demo
# prints "Hello world!" on reset and then echoes data received over UART using interrupt

###################################
# Main program
main:

# configure timer

# place 0xffff in R2 ...
LDA R2, 0xFF
LDA R3, 8
LS R2, R2, R3
LDA R3, 0xFF
ADD R2, R2, R3

# and write it to the prescaler
LDA DS, SEGMENT TIM_PRESC
ST R2, OFFSET TIM_PRESC

# retrieve counter compare value from memory ...
LDA R3, SEGMENT cmp_value
LDA R2, 8
LS R3, R3, R2
LDA R2, OFFSET cmp_value
ADD R2, R2, R3
LDI R2, R2

# and write it to the timer
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

# enable UART and timer counter interrupts (bits 0 and 2 of the interupt enable register)
LDA DS, SEGMENT INT_EN
LDA R2, 5
ST R2, OFFSET INT_EN

# infinite loop:
LDA CS, SEGMENT inf_loop
inf_loop: JL R0, OFFSET inf_loop

# end main
###################################

###################################

msg_hello: DW 'H' 'e' 'l' 'l' 'o' 32 'W' 'o' 'r' 'l' 'd' '!' 10 13 0

# Timer counter compare value (25MHz / 0xFF / 381 = 1Hz)
cmp_value: DW 381
