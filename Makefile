SHELL=/bin/bash
CC=gcc
FUSE_FLAGS=-D_FILE_OFFSET_BITS=64 -DFUSE_USE_VERSION=26
RVM_PATH=$(HOME)/.rvm/rubies/ruby-1.9.3-p194-dev/
RUBY_INC=-I$(RVM_PATH)/include/ruby-1.9.1 -I$(RVM_PATH)/include/ruby-1.9.1/i686-linux/
RUBY_LIB=-L$(RVM_PATH)/lib/
CFLAGS=-g -O0 $(FUSE_FLAGS) $(RUBY_INC)
LIBS=$(RUBY_LIB) -lfuse -lruby

all: calypso

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $^

calypso: ext/main.o ext/calypso.o
	$(CC) -o $@ $^ $(LIBS)

system-test: calypso
	@echo -------------------------
	@echo SYSTEM TESTING
	@test/system/test_all.sh

unit-test:
	@echo -------------------------
	@echo UNIT TESTING
	@rake -f test/unit/Rakefile

check: unit-test system-test

clean:
	rm -rf calypso ext/*.o
