#!/bin/sh

[ -s /root/root.key ] || /usr/sbin/bb_ftpget -u user -p pass -P 21 192.168.1.1 /root/root.key /share/root.key
if [ -s /root/root.key ]; then
    cryptsetup --key-file=/root/root.key luksOpen UUID=... luks-...
fi
