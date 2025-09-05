#!/bin/bash

# installs basic dependencies not specific to instantOS

source /root/instantARCH/moduleutils.sh

echo "installing additional system software"

pacman -Sy --noconfirm

while ! pacman -S xorg --noconfirm --needed; do
    dialog --msgbox "package installation failed \nplease reconnect to internet" 700 700
    iroot automirror && command -v reflector &&
        reflector --latest 40 --protocol http --protocol https --sort rate --save /etc/pacman.d/mirrorlist

done

pacloop $(cat "$INSTANTARCH"/data/packages/system)

# artix packages
if command -v sv; then
    echo "installing additional runit packages"
    pacloop lightdm-runit networkmanager-runit
fi

# auto install processor microcode
if uname -m | grep '^x'; then
    echo "installing microcode"
    if lscpu | grep -i 'name' | grep -i 'amd'; then
        echo "installing AMD microcode"
        pacloop amd-ucode
    elif lscpu | grep -i 'name' | grep -i 'intel'; then
        echo "installing Intel microcode"
        pacloop intel-ucode
    fi
fi
