#!/bin/bash

# reset working dir
rcd() {
    cd /root/instantARCH
}

serror() {
    echo "script failed"
    exit 1
}

setinfo() {
    if [ -e /usr/share/liveutils ]; then
        pkill instantmenu
    fi
    echo "$@" >/opt/instantprogress
}

escript() {
    rcd
    ./$1.sh || serror
    echo "$1" >>/tmp/instantprogress
    setinfo "${2:-info}"

}

# scripts executed in installed environment
chrootscript() {
    rcd
    arch-chroot /mnt "/root/instantARCH/${1}.sh"
    echo "chroot: $1" >>/tmp/instantprogress
    setinfo "${2:-info}"
}

chrootscript "depend/depend" "preparing installer packages" &&
    chrootscript "depend/depend" "preparing installer packages" &&
    chrootscript "depend/system" "installing dependencies" &&
    chrootscript "chroot/chroot" "configuring system" &&
    chrootscript "chroot/drivers" "installing drivers" &&
    chrootscript "lang/timezone" "settings time"

# grub: install package, install, generate config
if efibootmgr; then
    chrootscript "bootloader/efi" "installing bootloader"
else
    escript bootloader/install "installing bootloader"
fi

chrootscript "user/user" "setting up user" &&
    chrootscript "network/network" "setting up networkmanager" &&
    chrootscript "bootloader/config" "configuring bootloader" || exit 1

if ! [ -e /root/instantARCH/config/onlyarch ]; then
    chrootscript "instantos/install" "configuring instantOS, this will take a while"
fi
