PROJ = toy
TOPMODULE = colorlight_toy_top

VERILOG_SRC = cpu/cpu.v cpu/alu.v cpu/reg_file.v memory/ram.v peripherals/tx.v soc/toy.v colorlight_top/colorlight_toy_top.v

SIM_TOP = tb_toy
SIM_SRC = tb/tb_toy.v


include support/colorveri.mk
