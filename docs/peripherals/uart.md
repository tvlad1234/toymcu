## The UART

8-N-1 UART
- Default base address is 0400h
- Baud rate is set using the `BAUD_DIV` parameter of the [`toy` module](/hw/soc//toy.v)
- Can launch interrupt when data is available for reading or when a receive error is detected.

### Registers
- Data register (at 0400h)
    - Writes trigger serial transmit
    - Reads clear the status register
    - High byte is ignored (or zero when reading)

- Status register (at 0401h)
    - Contains Tx and Rx status flags
        - bit 0: Tx ready (idle)
        - bit 1: Rx error
        - bit 2: Rx data available
    - data cannot be written into status register, write access clears the Rx status flags.
