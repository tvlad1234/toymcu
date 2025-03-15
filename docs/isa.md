## The TOY instruction set architecture

The CPU contains a total of 16 accessible registers, each being 16 bits wide.
- `R0` is hardwired to the value 0
- `R1` is recommended to be set to the value 1 at the beginning of the program (see [the assembler docs](assembler.md)).
- `R2` through `RB` can be used as general purpose registers.
- `RC` is used by the assembler as the function return pointer.
- `RD` is used by the assembler as the stack pointer (called `SP` in the assembler).
- `CS` and `DS` are the segment registers used by the immediately addressed memory access instructions (see [this document detailing the segmented memory addressing scheme](toy_improvements.md)).

## Instructions

### Arithmetic and logical instructions
|  Instruction  |  Operation   |
|---------------|--------------|
|ADD Rd, Rs, Rt |Rs <- Rs + Rt |
|SUB Rd, Rs, Rt |Rs <- Rs - Rt |
|AND Rd, Rs, Rt |Rs <- Rs & Rt |
|XOR Rd, Rs, Rt |Rs <- Rs ^ Rt |
|LS  Rd, Rs, Rt |Rs <- Rs << Rt|
|RS  Rd, Rs, Rt |Rs <- Rs >> Rt|

### Memory access instructions
|  Instruction |   Operation    |
|--------------|----------------|
|LDA Rd, imm|Rd <- imm |
|LD  Rd, offset|Rd <- mem[address(DS, offset)] |
|ST  Rd, offset|mem[address(DS, offset)] <- Rd |
|LDI Rd, Raddr|Rd <- mem[Raddr]|
|STI Rd, Raddr|mem[Raddr] <- Rd|

### Control instructions
|  Instruction |   Operation    |
|--------------|----------------|
|HALT|halts the CPU   |
|BZ Rd, offset |if(Rd == 0) PC <- address(CS, offset)|
|BP Rd, offset |if(Rd > 0) PC <- address(CS, offset) |
|JMP Rd |PC <- Rd|
|JL Rd, offset|Rd <- PC; PC <- address(CS, offset)|
