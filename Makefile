SHELL=/bin/bash
CC=gcc
CFLAGS=-m32 -O3 -DNDEBUG
INCLUDES=-I./test/holdem/include

test: poker
	diff <(./poker) test/holdem/output.txt
	@echo SUCCESS!!!

poker: test/holdem/src/main.c card.o combo.o deck.o hand.o
	$(CC) $(CFLAGS) $(INCLUDES) -o $@ $^

%.o: test/holdem/src/%.c
	$(CC) $(CFLAGS) $(INCLUDES) -c -o $@ $<

clean:
	rm -rf *.o poker a.out

.PHONY: test
