#ALDEC Riviera-Pro
#
#If there's an error on stubs-32.h you're missing the 32bit glibc devel package

SRCDIR=../src
CC = ccomp

default: vpi

jp-io-vpi.so: $(SRCDIR)/jp-io-vpi.c Makefile
	$(CC) $(SRCDIR)/jp-io-vpi.c -o jp-io-vpi.o -pli

vpi: jp-io-vpi.so Makefile
