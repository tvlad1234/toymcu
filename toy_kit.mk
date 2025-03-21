TOYASM = toyasm.exe

PROGRAM_MEM = program/rom.mem
$(PROGRAM_MEM) : $(TOYASM) $(TOY_PROGRAM_SRC)
	./$(TOYASM) -r $(TOY_PROGRAM_SRC) $@

CC = gcc

include hw/hw.mk
include assembler/assembler.mk

toy_program: $(PROGRAM_MEM)

clean: clean_hw clean_toyasm
	rm -f program/*.mem

.PHONY : clean
