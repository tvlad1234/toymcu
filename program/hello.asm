# Hello world and interrupt handler demo
# prints "Hello world!" on reset and then echoes data received over UART using interrupt

###################################
# Main program
main:

# enable UART interrupt (bit 0 of the interupt enable register)
LDA DS, SEGMENT INT_CTRL
INC R3
ST R3, OFFSET INT_CTRL

# load hello message address into R2 ...
LDA R3, SEGMENT msg_hello
LDA R2, 8
LS R3, R3, R2
LDA R2, OFFSET msg_hello
ADD R2, R2, R3

# and call print_string
LDA CS, SEGMENT print_string
JL RC, OFFSET print_string

# infinite loop:
LDA CS, SEGMENT inf_loop
inf_loop: JL R0, OFFSET inf_loop

# end main
###################################

###################################

msg_hello: DW 'H' 'e' 'l' 'l' 'o' 32 'W' 'o' 'r' 'l' 'd' '!' 10 13 0
