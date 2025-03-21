## The interrupt controller

- The default base address of the interrupt controller is 0410h.
- The global interrupt handler must be located at address 2002h ([in ROM](/docs/memory_map.md)).

### Interrupt lines 
- Line 0: UART
- Line 1: Timer tick
- Line 2: Timer counter compare

### Registers
- Interrupt line status (at 0410h)
- Interrupt enable (at 0411h)
