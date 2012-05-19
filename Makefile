CC=gcc
INTERP=/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2

ifeq ($(DEBUG), 1)
CFLAGS=-g -O0
else
CFLAGS=-DNDEBUG -O3
endif

WARN_FLAGS=-Wall -Werror -std=c89 -pedantic

INCLUDES=-I./include

LIBS=-Llib

TEST_FILES=test/check_holdem.c \
	   test/check_card.c \
	   test/check_combo.c \
	   test/check_deck.c \
	   test/check_hand.c

INC_FILES=include/holdem/card.h \
	  include/holdem/combo.h \
	  include/holdem/deck.h \
	  include/holdem/hand.h

SRC_FILES=src/card.c \
	  src/combo.c \
	  src/deck.c \
	  src/hand.c

OBJ_FILES=src/card.o \
	  src/combo.o \
	  src/deck.o \
	  src/hand.o

%.o: %.c $(INC_FILES)
	$(CC) -c -o $@ $(CFLAGS) -fPIC $(WARN_FLAGS) $(INCLUDES) $<

libholdem: $(OBJ_FILES)
	mkdir -p lib
	$(CC) -shared -o lib/libholdem.so $^

# the check library requires C99
check: $(TEST_FILES) libholdem
	$(CC) -o test_all $(CFLAGS) --std=c99 $(INCLUDES) $(LIBS) $(TEST_FILES) -lcheck -lholdem
	$(INTERP) --library-path lib/ ./test_all

all: libholdem check

clean:
	rm -rf test_all a.out src/*.o lib/ *.dSYM
