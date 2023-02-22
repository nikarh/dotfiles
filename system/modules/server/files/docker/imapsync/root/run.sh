#!/bin/sh

sleep 10h

mbsync -LV -c /mbsync.conf gmail
goimapnotify -debug -conf /imapnotify.conf