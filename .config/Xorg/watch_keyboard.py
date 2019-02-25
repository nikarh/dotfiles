#!/usr/bin/env python

import functools
import os.path
import pyudev
import subprocess

def main():
    BASE_PATH = os.path.abspath(os.path.dirname(__file__))
    path = functools.partial(os.path.join, BASE_PATH)
    call = lambda x, *args: subprocess.call([path(x)] + list(args))

    context = pyudev.Context()
    monitor = pyudev.Monitor.from_netlink(context)
    monitor.filter_by(subsystem='usb')
    monitor.start()

    for device in iter(monitor.poll, None):
        call('keyboard.sh')

if __name__ == '__main__':
    main()
