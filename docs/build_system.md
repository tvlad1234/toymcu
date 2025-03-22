## The build system

The build system uses `make` to invoke the various tools required to build this project. The hardware simulation makes use of Icarus Verilog. The top-level design for the Colorlight board is synthesized and implemented by Yosys and nextpnr-ecp5. All of these tools are contained within the [Yosys oss-cad-suite](https://github.com/YosysHQ/oss-cad-suite-build). The assembler for the toymcu is compiled using GCC.

### Using the build system

The [makefile](/Makefile) found in the root of this repository contains several targets:
- toy_program
    - compiles the toyasm assembler and assembles the source files specified in the makefile into a memory file which can then be sent to the toymcu by the loader tool 

- toy_bootrom
    - compiles the toyasm assembler and assembles the boot ROM.

- hw_sim
    - builds the `toy_bootrom` target, then runs the hardware simulation, using the [included testbench](/hw/tb/tb_toy.v) and outputs the simulation result as a VCD file (`tb_tov.vcd`) in the root of the repo. The simulation result can be visualised using GTKWave (included in the oss-cad-suite)

- hw
    - builds the `toy_bootrom` target, then synthesizes and implements the [toymcu top-level design for the Colorlight 5A-75B V8.2 board](/hw/colorlight_top/colorlight_toy_top.v). The I/O constraints are specified in [this file](/hw/constraints/colorlight_toy_top.lpf). The build result of this target is a bitstream file (`colorlight_toy_top.bit`).

- hw_prog
    - builds the `hw` target and uses `ecpdap` to program the bitstream into the FPGA.

- toy_load
    - builds the `toy_program` target, compiles the loader tool and then sends the assembled program over the serial port specified in the makefile.

- clean
    - removes all resulting build files
    