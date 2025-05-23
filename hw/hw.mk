PROJ = toy

TOPMODULE = colorlight_toy_top
VERILOG_SRC = hw/cpu/cpu.v  hw/cpu/alu.v  hw/cpu/reg_file.v  hw/memory/ram.v hw/memory/rom.v  hw/peripherals/interrupt_ctrl.v hw/peripherals/tx.v  hw/peripherals/rx.v  hw/peripherals/uart.v hw/peripherals/timer.v hw/peripherals/gpio.v hw/soc/reset_ctrl.v hw/soc/toy.v hw/colorlight_top/colorlight_toy_top.v
VERILOG_MEM = $(BOOT_ROM)

SIM_TOP = tb_toy
SIM_SRC =  hw/tb/tb_toy.v


include  hw/support/colorveri.mk
