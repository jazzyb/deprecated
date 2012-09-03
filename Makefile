CC=gcc
FUSE_FLAGS=-D_FILE_OFFSET_BITS=64 -DFUSE_USE_VERSION=26
RUBY_INC=-I/usr/include/ruby-1.9.1/ -I/usr/include/ruby-1.9.1/i686-linux/
CFLAGS=-g -O0 $(FUSE_FLAGS) $(RUBY_INC)
LIBS=-lfuse -lruby-1.9.1

all: calypso

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $^

calypso: ext/main.o ext/calypso.o
	$(CC) -o $@ $^ $(LIBS)

check:
	rake -f test/Rakefile

clean:
	rm -rf calypso ext/*.o
