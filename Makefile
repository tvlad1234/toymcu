PROJ = toy
TOPMODULE = colorlight_toy_top

VERILOG_SRC = cpu/cpu.v cpu/alu.v cpu/reg_file.v memory/ram.v peripherals/tx.v peripherals/rx.v peripherals/uart.v soc/toy.v colorlight_top/colorlight_toy_top.v

VERILOG_MEM = programs/hello.mem

SIM_TOP = tb_toy
SIM_SRC = tb/tb_toy.v


include support/colorveri.mk

C_SRC = main.c
CC = gcc

toyasm : assembler/main.c
	$(CC) $^ -o $@

asm : toyasm
	./toyasm programs/hello.asm programs/hello.mem

