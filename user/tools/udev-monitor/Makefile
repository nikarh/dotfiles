CC = gcc
CFLAGS = -s -Wall -O3
BIN ?= $(PWD)

$(BIN)/udev-monitor:
	$(CC) $(CFLAGS) -o $(BIN)/$@ $@.c -ludev

default: $(BIN)/udev-monitor
all: default

clean:
	rm -f $(BIN)/udev-monitor