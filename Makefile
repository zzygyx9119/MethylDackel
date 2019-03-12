prefix ?= /usr/local/bin #This can be changed
CC ?= gcc
LIBS ?=  # e.g., -L$PREFIX/lib, or where ever htslib is
CFLAGS ?= -Wall -g -O3 -pthread

.PHONY: all clean install version.h

.SUFFIXES:.c .o

all: MethylDackel

OBJS = common.o bed.o svg.o pileup.o extract.o MBias.o mergeContext.o perRead.o
VERSION = 0.3.0

#If we're building from a git repo, then append the most recent tag
ifneq "$(wildcard .git)" ""
VERSION := $(shell git describe --tags --always --dirty)
endif

version.h:
	echo '#define VERSION "$(VERSION)"' > $@

.c.o:
	$(CC) -c $(CFLAGS) $(LIBS) $< -o $@

MethylDackel: version.h $(OBJS)
	$(CC) $(CFLAGS) $(LIBS) -o MethylDackel $(OBJS) main.c -lm -lz -lpthread -lhts

test: MethylDackel 
	python tests/test.py

clean:
	rm -f *.o MethylDackel

install: MethylDackel
	install MethylDackel $(prefix)
