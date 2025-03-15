## Improvements made upon the original Princeton TOY ISA

### Address bus extension and segmented addressing

The Princeton TOY specifies an 8 bit wide address bus. This project extends the address bus to 16 bits. Indirectly addressed memory access/jump instructions are unnafected by this modification, as the registers are 16 bits wide. On the other hand, the address field of the immediately addressed access instructions is only 8 bits wide. In order to overcome this limitation, immediate addressing is done in a segmented fashion. The last two registers (`RE` and `RF`) have been reserved for use as segment registers: `DS` (data segment, used for store and load instructions) and `CS` (code segment, used for jump instructions). The memory address is obtained by shifting the segment register contents by 8 positions to the left and adding the immediate value.

### Interrupts

Interrupts are implemented using a single interrupt line. When an interrupt is requested, the CPU saves the program counter to an internal register and jumps to address 0002h (the location of the global interrupt handler). Returning to the main program is achieved using the `JMP` instruction, with `R0` as its parameter.

