#!/bin/bash
# auto detect graphics card and install drivers accordingly
# if the system uses nvidia, read out the user choice

echo "installing video drivers"

# works differently on manjaro
if grep -iq '^name.*arch' /etc/os-release; then
    ## NVIDIA
    if lspci | grep -i vga | grep -i nvidia; then
        # user chooses open source, proprietary or no driver
        if [ -e /root/instantARCH/config/graphics ]; then
            DRIVERFILE="/root/instantARCH/config/graphics"
            if grep -iq "nodriver" "$DRIVERFILE"; then
                exit
            elif grep -iq "dkms" "$DRIVERFILE"; then
                pacman -S --noconfirm nvidia-dkms nvidia-utils

                if ! uname -m | grep -q '^i'; then
                    pacman -S --noconfirm lib32-nvidia-utils
                fi
            elif grep -iq "nvidia" "$DRIVERFILE"; then
                pacman -S --noconfirm nvidia nvidia-utils nvidia-lts
            elif grep -iq "open" "$DRIVERFILE"; then
                pacman -S --noconfirm mesa xf86-video-nouveau
            fi
        else
            echo "defaulting to open source driver"
            pacman -S --noconfirm mesa xf86-video-nouveau
        fi
    ## Intel
    elif lspci | grep -i vga | grep -i intel; then
        echo "intel integrated detected"
        pacman -S --noconfirm mesa xf86-video-intel
    else
        echo "other graphics detected, possibly virtualbox"
        pacman -S mesa --noconfirm
    fi

    # 32 bit mesa
    if ! uname -m | grep -q '^i'; then
        pacman -S --noconfirm lib32-mesa
    fi

fi
