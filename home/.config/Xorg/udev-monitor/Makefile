CC = gcc
CFLAGS = -s -Wall -O3

udev-monitor:
	$(CC) $(CFLAGS) -o udev-monitor udev-monitor.c -ludev

default: udev-monitor
all: default

clean:
	rm -f udev-monitor