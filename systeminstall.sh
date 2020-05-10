#!/bin/bash

# reset working dir
rcd() {
    cd /root/instantARCH
}

serror() {
    echo "script failed"
    exit 1
}

escript() {
    rcd
    ./$1.sh || serror
    echo "$1" >>/tmp/instantprogress
}

# scripts executed in installed environment
chrootscript() {
    rcd
    arch-chroot /mnt "/root/instantARCH/${1}.sh"
    echo "chroot: $1" >>/tmp/instantprogress
}

chrootscript "depend/depend" &&
    chrootscript "depend/depend" &&
    chrootscript "depend/system" &&
    chrootscript "chroot/chroot" &&
    chrootscript "chroot/drivers" &&
    chrootscript "lang/timezone"

# grub: install package, install, generate config
if efibootmgr; then
    chrootscript "bootloader/efi"
else
    escript bootloader/install
fi

chrootscript "user/user" &&
    chrootscript "network/network" &&
    chrootscript "bootloader/config" &&
    chrootscript "instantos/install"
