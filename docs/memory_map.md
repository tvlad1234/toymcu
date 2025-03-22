## The memory map

### General specifications
- 16bit address space
- 16bit data words
    - word addressable only!

### Memory map:
- RAM at 0000h
    - 1024 locations
- Peripherals (starting at 0400h)
    - [UART](/docs/peripherals/uart.md) at 0400h
    - [Interrupt](/docs/peripherals/interrupt_ctrl.md) controller at 0410h
    - [Timer](/docs/peripherals/timer.md) at 0420h
    - GPIO at 0430h
- ROM at 2000h
    - contains the UART bootloader
    - 1024 locations
