$(LOADER): loader/main.c
	$(CC) $^ -o $@

clean_loader:
	rm $(LOADER)
	