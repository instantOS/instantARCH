#!/bin/bash

rcd() {
    cd /root/instantARCH
}

escript() {
    rcd
    ./$1.sh
    echo "$1" >>/tmp/instantprogress
}

# scripts executed in installed environment
chrootscript() {
    rcd
    ./chrootscript.sh "$1.sh"
    echo "chroot: $1" >>/tmp/instantprogress
}

chrootscript "depend/depend"
chrootscript "depend/system"
chrootscript "chroot/chroot"
chrootscript "chroot/drivers"
chrootscript "lang/timezone"

# grub: install package, install, generate config
chrootscript "bootloader/bootloader"
escript bootloader/install
chrootscript "bootloader/config"

chrootscript "user/user"
chrootscript "network/network"
