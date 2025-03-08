
$(TOYASM) : assembler/main.c assembler/names.c assembler/parse_funcs.c assembler/inst_funcs.c
	$(CC) $^ -o $@

clean_toyasm:
	rm $(TOYASM)

PHONY : clean_toyasm
