CC=gcc
CFLAGS = -g -Og
PKGFLAGS = `pkg-config fuse --cflags --libs`
DEPS = blocklayer.h jsteg.h
OBJ = memefs.o blocklayer.o queue.o queue_desc.o

_GOFILES = main.go reader.go writer.go scan.go huffman.go fdct.go
GOFILES = $(patsubst %,jsteg/%,$(_DEPS))


jsteg.a: $(GOFILES)
	go build -buildmode=c-archive -o jsteg.a $(GOFILES)

jsteg.h: jsteg.a
## Recover from the removal of $@
	@if test -f $@; then :; else \
	  rm -f jsteg.a; \
	  $(MAKE) $(AM_MAKEFLAGS) jsteg.a; \
	fi

%.o: %.c $(DEPS)
	$(CC) -c -o $@ $< $(CFLAGS)

memefs: $(OBJ) jsteg.a
	gcc -o $@ $^ $(CFLAGS) $(PKGFLAGS)

.PHONY: clean

clean:
	rm -f *.o jsteg.a jsteg.h
