## The toyasm assembler

### Assembling programs with `toyasm`
The assembler is is invoked as follows:
```
toyasm [assembly source files] [output file]
```

The order of the source files determines the order in which the resulting machine code/data is arranged in memory.

### Writing assembly programs

The assembly language is case-sensitive. Mnemonics, register names and assembler keywords are all-caps.

- Instruction mnemonics
    - The instruction mnemonics are detailed [here](/docs/isa.md).

- Comments
    - Comment lines are marked by `#`.
    ```
    # this line is a comment
    ```

- Labels
    - Labels are marked by `:` after the label name.
    ```
    # considering the first address is 0, first_label points to address 1
    INC R2
    first_label: DEC R3 

    ... [content spanning 5 addresses]

    # second_label points to address 7
    second_label:
        LDA R2 OFFSET first_label
        ...
    ```

- The `SEGMENT` and `OFFSET` keywords
    - These keywords can be used with mnemonics which take immediate values, usually memory addresses. They instruct the assembler to consider the segment/offset value of the provided address as the immediate value. The segmented immediate addressing scheme is detailed [here](/docs/toy_improvements.md).

- Assembler-implemented features
    - The assembler implements some features which are essential for efficiently writing programs:
    
        - Increment and decrement mnemonics
            - The `INC` and `DEC` mnemonics make use of the `R1` register to increment and decrement other register. This requires that the value 1 is manually loaded into the `R1` register at the beggining of the program. As such, it's recommended to avoid using `R1` as a general-purpose register.

        - Stack
            - The stack is implemented by reserving the `RD` register to be used as a stack pointer. Stack data is manipulated using the `PUSH` and `POP` mnemonics. 

        - Function call and return
            - The assembler implements `CALL` and `RET` mnemonics for calling and returning from functions. This is achieved by reserving the `RC` register for the function return address.

        - Data definitions
            - The `DW` (define word) directive is used to place pre-defined data into memory
            ```
            # define msg_hello at the current address
            msg_hello: DW 'H' 'e' 'l' 'l' 'o' 32 'W' 'o' 'r' 'l' 'd' '!' 10 13 0
            ```
