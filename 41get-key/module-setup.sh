#!/bin/bash

check () {
    return 255
}

depends () {
    return 0
}

install () {
    inst_hook initqueue 41 "$moddir/get-key.sh"
    inst_hook initqueue/settled 41 "$moddir/check-get-key.sh"
    inst_simple "$moddir/bb_ftpget" /sbin/bb_ftpget
    inst /usr/sbin/cryptsetup
}
