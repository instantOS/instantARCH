#!/bin/bash

# main script calling others

# DO NOT USE, NOT READY YET

# check for internet
if ! ping -c 1 google.com &>/dev/null; then
    echo "no internet"
    exit
fi

# print logo
curl -s 'https://raw.githubusercontent.com/instantOS/instantLOGO/master/ascii.txt'

echo "selecting fastest mirror"
# sort mirrors
pacman -Sy --noconfirm
pacman -S reflector --noconfirm
reflector --sort rate --save /etc/pacman.d/mirrorlist

# install dependencies
pacman -Sy --noconfirm
pacman -S git --noconfirm

cd /root
git clone --depth=1 https://github.com/instantos/instantARCH.git
cd instantARCH

chmod +x *.sh
chmod +x **/*.sh

rcd() {
    cd /root/instantARCH
}

escript() {
    rcd
    ./$1.sh
}

escript depend/depend
escript lang/keyboard.sh
escript init/init.sh
escript disk/disk.sh
escript pacstrap/pacstrap.sh

# scripts executed in installed environment
chrootscript() {
    rcd
    ./chrootscript.sh $1.sh
}

chrootscript depend/depend
chrootscript depend/system
chrootscript chroot/chroot
chrootscript chroot/drivers
chrootscript lang/timezone

# grub: install package, install, generate config
chrootscript bootloader/bootloader
escript bootloader/install
chrootscript bootloader/config

chrootscript user/user