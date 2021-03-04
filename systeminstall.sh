#!/bin/bash

source /root/instantARCH/installutils.sh

chrootscript "depend/depend" "preparing installer packages"
chrootscript "depend/depend" "preparing installer packages"
chrootscript "artix/preinstall" "applying artix fixes"
chrootscript "depend/system" "installing dependencies"
chrootscript "chroot/chroot" "configuring system"
chrootscript "chroot/drivers" "installing drivers"
chrootscript "lang/timezone" "setting time"
chrootscript "chroot/publish" "setting config permissions"

# grub: install package, install, generate config
if efibootmgr; then
    chrootscript "bootloader/efi" "installing bootloader"
else
    chrootscript "bootloader/install" "installing bootloader"
fi

chrootscript "network/network" "setting up networkmanager" &&
    chrootscript "user/user" "setting up user" &&
    chrootscript "bootloader/config" "configuring bootloader"

touch /opt/noerror
chrootscript "lang/locale" "setting locale"
[ -e /opt/noerror ] && rm /opt/noerror

# make instantOS packages optional
if ! iroot onlyarch &&
    ! [ -e /opt/onlyarch ]; then

    # important stuff
    chrootscript "instantos/install" "configuring instantOS, this will take a while"
    chrootscript "user/shell" "setting up instantshell zsh configuration"

    if grep -iq 'manjaro' /etc/os-release; then
        echo "manjaro extra steps"
        chrootscript "chroot/chroot" "extra steps for manjaro"
    fi
fi

chrootscript "lang/locale" "setting locale"
chrootscript "artix/postinstall" "checking for reverting artix fixes"
chrootscript "chroot/cacheclean" "checking for reverting artix fixes"

# mark installation as susccessful
touch /opt/installsuccess
