## The timer

16 bit timer
- Default base address is 0420h
- Can launch two interrupts:
    - Timer tick (at _Ftick = Fclk / prescaler [Hz]_)
    - Timer counter compare (at _Fcmp = Ftick / compare [Hz]_)

### Registers
- Counter (at 0420h)
    - incremented at _Ftick [Hz]_
- Prescaler (at 0421h)
- Enable register (at 0422h)
    - bit 1: Timer enable
- Counter compare (at 0423h)
    - if 0, counter compare is disabled
