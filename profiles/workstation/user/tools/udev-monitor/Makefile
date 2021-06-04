CC = gcc
CFLAGS = -s -Wall -O3
BIN ?= $(PWD)

$(BIN)/udev-monitor: *.c
	$(CC) $(CFLAGS) -o $@ $< -ludev

default: $(BIN)/udev-monitor
all: default

clean:
	rm -f $(BIN)/udev-monitor