#!/bin/bash
# auto detect graphics card and install drivers accordingly

echo "installing video drivers"

if lspci | grep -i vga | grep -i nvidia; then
    if [ -e /root/instantARCH/config/graphics ]; then
        DRIVERFILE="/root/instantARCH/config/graphics"
        if grep -iq "nodriver" "$DRIVERFILE"; then
            exit
        elif grep -iq "nvidia" "$DRIVERFILE"; then
            pacman -S --noconfirm nvidia nvidia-utils
        elif grep -iq "open" "$DRIVERFILE"; then
            pacman -S --noconfirm mesa xf86-video-nouveau
        fi
    else
        echo "defaulting to open source driver"
        pacman -S --noconfirm mesa xf86-video-nouveau
    fi
elif lspci | grep -i vga | grep -i intel; then
    echo "intel integrated detected"
    pacman -S --noconfirm mesa xf86-video-intel
else
    echo "other graphics detected, possibly virtualbox"
    pacman -S mesa --noconfirm
fi
