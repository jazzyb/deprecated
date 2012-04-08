SHELL=/bin/bash
ARDIS=bin/ardis
CC=gcc
CFLAGS=-m32 -O3 -DNDEBUG
INCLUDES=-I./test/holdem/include

test: poker
	diff <(./poker) test/holdem/output.txt
	@echo SUCCESS!!!

poker: test/holdem/src/main.c card.o combo.o deck.o hand.o
	$(CC) $(CFLAGS) $(INCLUDES) -o $@ $^

%.o: test/holdem/src/%.c
	$(CC) $(CFLAGS) $(INCLUDES) -c -o $@.orig $<
	$(ARDIS) $@.orig > $$(echo $@ | sed 's/\.o$$/.s/')
	$(CC) -m32 -c -o $@ $$(echo $@ | sed 's/\.o$$/.s/')

clean:
	rm -rf *.o *.orig *.s poker a.out

.PHONY: test
