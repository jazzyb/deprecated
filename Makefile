CC=gcc

ifeq ($(DEBUG), 1)
CFLAGS=-g -O0
else
CFLAGS=-DNDEBUG -O3
endif

WARN_FLAGS=-Wall -Werror -std=c89 -pedantic

INCLUDES=-I./include

LIBS=-Llib

# include MacPorts directories for the check library
ifeq (darwin, $(findstring darwin,$(OSTYPE)))
CHECK_INC=-I/opt/local/include
CHECK_LIB=-L/opt/local/lib
endif
CHECK_FLAGS=$(CHECK_INC) $(CHECK_LIB)

TEST_FILES=test/check_holdem.c \
	   test/check_card.c \
	   test/check_hand.c

INC_FILES=include/holdem/card.h \
	  include/holdem/hand.h

SRC_FILES=src/card.c \
	  src/hand.c

OBJ_FILES=src/card.o \
	  src/hand.o

%.o: %.c $(INC_FILES)
	$(CC) -c -o $@ $(CFLAGS) $(WARN_FLAGS) $(INCLUDES) $<

libholdem: $(OBJ_FILES)
	mkdir -p lib
	ar cr lib/libholdem.a $^
	ranlib lib/libholdem.a

# the check library requires C99
check: $(TEST_FILES) libholdem
	$(CC) -o test_all $(CFLAGS) --std=c99 $(INCLUDES) $(CHECK_FLAGS) $(LIBS) $(TEST_FILES) -lcheck -lholdem
	./test_all

all: libholdem check

clean:
	rm -rf test_all a.out src/*.o lib/ *.dSYM
