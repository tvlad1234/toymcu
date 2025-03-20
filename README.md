# toymcu

This repository contains the Verilog implementation of a microcontroller, based around a CPU core which uses an extension of the [Princeton TOY instruction set architecture](https://introcs.cs.princeton.edu/java/62toy/), as well as an assembler and example program.

## How it came to be
During my 2nd year of university, I studied the basics of digital hardware design, using VHDL. Out of personal curiosity and passion for the subject, I had the idea of implementing a small CPU design. While looking for possible instruction set architectures to use, I came across the TOY ISA, developed by Princeton University, to use in their Computer Science courses. I settled on it, considering its simplicity and the fact that nobody had (publically, at least) implemented it in hardware previously.

During the 3rd year, I decided I wanted to improve my digital hardware design skills and learn Verilog. The [CPU core](hw/cpu) was my first Verilog design, having translated the older project from VHDL, while also making some [significant and useful modifications](docs/toy_improvements.md).

After I was pleased with the state of the CPU core, I started to work on the [assembler](assembler/), in order to be able to write programs without having to type machine code by hand directly into memory. I also implemented the transmit part of a UART, at this point being able to output characters to a serial console.

With the CPU core and assembler mostly functional, I decided to implement more [peripherals](hw/peripherals/). I ended up implementing a full bidirectional UART, a timer, GPIO port and interrupt controller, basically turning the project into what can universally be considered a microcontroller.

## Repository contents
### Build system
This project uses makefiles and various open-source tools for its build system. The usage of this build system is described in [this file](docs/build_system.md).

### Hardware design
The [hw](hw) folder contains the Verilog implementation of the toymcu, simulation testbench and a top-level design meant for the Colorlight 5A-75B V8.2 board.

### Assembler
The [assembler](assembler/) folder contains the assembler for the toymcu. [This file](docs/assembler.md) explains the features and usage of the assembler.

### Example program
The [program](program) folder contains an example program for the toymcu, which showcases UART and GPIO output, as well as UART and timer interrupts. The program source is split across multiple assembly files

## Documentation
- [The build system](docs/build_system.md)
- [Improvements made upon the original Princeton TOY ISA](docs/toy_improvements.md)
- [The TOY ISA](docs/isa.md)
- [The `toyasm` assembler](docs/assembler.md)
- Peripherals
    - [Interrupt controller](docs/peripherals/interrupt_ctrl.md)
    - [UART](docs/peripherals/uart.md)
    - [Timer](docs/peripherals/timer.md)

## To do
- Documentation
    - document GPIO peripheral
- Implement GPIO interrupts
