#!/bin/sh

mbsync -LV -c /mbsync.conf gmail
goimapnotify -debug -conf /imapnotify.conf