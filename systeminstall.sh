#!/bin/bash

source /root/instantARCH/installutils.sh

chrootscript "depend/depend" "preparing installer packages"
chrootscript "depend/depend" "preparing installer packages"
chrootscript "depend/system" "installing dependencies"
chrootscript "chroot/chroot" "configuring system"
chrootscript "chroot/drivers" "installing drivers"
chrootscript "lang/timezone" "settings time"

# grub: install package, install, generate config
if efibootmgr; then
    chrootscript "bootloader/efi" "installing bootloader"
else
    escript bootloader/install "installing bootloader"
fi

chrootscript "user/user" "setting up user" &&
    chrootscript "network/network" "setting up networkmanager" &&
    chrootscript "bootloader/config" "configuring bootloader"

touch /opt/noerror
chrootscript "lang/locale" "setting locale"
[ -e /opt/noerror ] && rm /opt/noerror

# make instantOS packages optional
if ! iroot onlyarch &&
    ! [ -e /opt/onlyarch ]; then
    chrootscript "instantos/install" "configuring instantOS, this will take a while"
    if grep -iq 'manjaro' /etc/os-release; then
        echo "manjaro extra steps"
        chrootscript "chroot/chroot" "extra steps for manjaro"
    fi
fi

# mark installation as susccessful
touch /opt/installsuccess
