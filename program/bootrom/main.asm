pre_main:
LDA R1, 1

# set the stack pointer
LDA DS, SEGMENT sp
LD SP, OFFSET sp

LDA CS, SEGMENT main

main:
LDA R2, 0x05
CALL uart_tx

STI R0, R0

# R9 is the RAM pointer
LDA R9, 0

# command loop:
cmd_loop:

CALL uart_rx

# if received reset command
LDA R3, 'r'
SUB R3, R2, R3
BZ R3, OFFSET main

# else if received write command
LDA R3, 'w'
SUB R3, R2, R3
BZ R3, OFFSET write_cmd

# else if received exit command
LDA R3, 'e'
SUB R3, R2, R3
BZ R3, OFFSET exit_cmd

# else
JL R0, OFFSET cmd_loop

write_cmd:
    LDA R2, 'm'
    CALL uart_tx
    CALL uart_rx
# MSB in R3
    ADD R3, R2, R0

    LDA R2, 'l'
    CALL uart_tx
    CALL uart_rx
# LSB in R4
    ADD R4, R2, R0

    ADD R2, R3, R0
    CALL uart_tx
    ADD R2, R4, R0
    CALL uart_tx

    LDA R2, 8
    LS R3, R3, R2
    ADD R3, R3, R4

    STI R3, R9

    INC R9

    JL R0, OFFSET cmd_loop

exit_cmd:
    LDA R2, 'e'
    CALL uart_tx
    LDA CS, 0
    JL R0, 0

# Stack pointer value
sp: DW 1023

# end main
###################################

###################################
uart_tx:

LDA DS, SEGMENT UART_DATA

# save data to be sent, then load UART status into R2
PUSH R2
rdy_check: LD R2, OFFSET UART_STATUS

# if first byte of R2 is 0 (UART is not ready), check again
AND R2, R2, R1
BZ R2, OFFSET rdy_check

# restore data to be sent, then transmit
POP R2
ST R2, OFFSET UART_DATA

RET
# end uart_tx
###################################

###################################
uart_rx:

# wait for data
LDA DS, SEGMENT UART_STATUS
av_check:
# check bit 2 of status register
  LD R2, OFFSET UART_STATUS
  RS R2, R2, R1
  RS R2, R2, R1
  AND R2, R2, R1
  BZ R2, OFFSET av_check

LD R2, OFFSET UART_DATA

RET
# end uart_rx
###################################
