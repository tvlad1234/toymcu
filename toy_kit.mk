TOYASM = toyasm.exe
LOADER = loader.exe

TOY_BOOTROM_SRC = program/bootrom/main.asm
BOOT_ROM = program/rom.mem
$(BOOT_ROM) : $(TOYASM) $(TOY_BOOTROM_SRC)
	./$(TOYASM) -r $(TOY_BOOTROM_SRC) $@

PROGRAM_MEM = program/program.mem
$(PROGRAM_MEM) : $(TOYASM) $(TOY_PROGRAM_SRC)
	./$(TOYASM) $(TOY_PROGRAM_SRC) $@

CC = gcc

include hw/hw.mk
include assembler/assembler.mk
include loader/loader.mk

toy_bootrom: $(BOOT_ROM)
toy_program: $(PROGRAM_MEM)

toy_load: $(LOADER) $(PROGRAM_MEM)
	./$(LOADER) $(PROGRAM_MEM) $(LOADER_PORT)

clean: clean_hw clean_toyasm clean_loader
	rm -rf program/*.mem

.PHONY : clean toy_load
