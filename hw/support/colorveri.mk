hw: ${TOPMODULE}.bit

${TOPMODULE}.json : ${VERILOG_SRC} ${VERILOG_MEM}
	yosys -f "verilog -sv" -p "synth_ecp5 -top ${TOPMODULE} -json $@" ${VERILOG_SRC}

${TOPMODULE}_out.config : ${TOPMODULE}.json hw/constraints/${TOPMODULE}.lpf
	nextpnr-ecp5 --json ${TOPMODULE}.json --textcfg $@ --25k --package CABGA256 --lpf hw/constraints/${TOPMODULE}.lpf

${TOPMODULE}.bit : ${TOPMODULE}_out.config
	ecppack --compress --svf ${TOPMODULE}.svf $< $@  

${TOPMODULE}.svf : ${TOPMODULE}.bit

hw_prog: ${TOPMODULE}.bit
	ecpdap prog $<

clean_hw:
	rm -f *.svf *.bit *.config *.json *.cf *.vcd *.vvp

${SIM_TOP}.vvp : ${VERILOG_SRC} ${SIM_SRC} ${VERILOG_MEM}
	iverilog -g2012 -s ${SIM_TOP} -o ${SIM_TOP}.vvp ${VERILOG_SRC} ${SIM_SRC}

hw_sim : ${SIM_TOP}.vvp 
	vvp ${SIM_TOP}.vvp

.PHONY: hw_sim hw_prog clean_hw
