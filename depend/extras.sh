#!/bin/bash

# installs extra third party applications

source /root/instantARCH/moduleutils.sh
pacman -Sy --noconfirm

pacloop lshw
HWINFO=:$(lshw)
if grep -q 'dvd' <<<"$HWINFO" || grep -q 'cdrom' <<<"$HWINFO"; then
    echo "fixing dvd playback"
    pacloop libdvdread libdvdcss libdvdnav
fi

# virtualbox guest additions
if iroot guestadditions; then
    echo "installing virtualbox guest addidions"
    pacman -S --noconfirm --needed virtualbox-guest-dkms
    touch /opt/instantos/guestadditions
fi

# optional user defined packages
if iroot packages &>/dev/null; then
    echo "installing extra packages"
    iroot packages | pacman -S --noconfirm --needed -
fi

while ! pacman -S --noconfirm firefox neovim-qt; do
    sleep 10
    command -v reflector &&
        reflector --latest 40 --protocol http --protocol https --sort rate --save /etc/pacman.d/mirrorlist &&
        pacman -Sy --noconfirm

done
