#!/bin/bash
# auto detect graphics card and install drivers accordingly
# if the system uses nvidia, read out the user choice

echo "installing video drivers"

# works differently on manjaro
if ! grep -iq '^name.*arch' /etc/os-release; then
    exit
fi

if iroot isvm; then
    echo "installing virtual machine drivers"
    if iroot kvm; then
        echo "installing QEMU drivers"
        pacman -S --noconfirm --needed xorg-drivers
    else
        pacman -S mesa --noconfirm
        pacman -S xf86-video-vmware --noconfirm
    fi
else
    ## NVIDIA
    if lspci | grep -i vga | grep -i nvidia; then
        # user chooses open source, proprietary or no driver
        if iroot graphics; then
            DRIVERFILE="/root/instantARCH/config/graphics"
            if grep -iq "nodriver" "$DRIVERFILE"; then
                exit
            elif grep -iq "dkms" "$DRIVERFILE"; then
                pacman -S --noconfirm nvidia-dkms nvidia-utils

                if ! uname -m | grep -q '^i' && command -v systemctl; then
                    pacman -S --noconfirm lib32-nvidia-utils
                fi
            elif grep -iq "nvidia" "$DRIVERFILE"; then
                pacman -S --noconfirm nvidia nvidia-utils nvidia-lts
                if ! uname -m | grep -q '^i' && command -v systemctl; then
                    pacman -S --noconfirm lib32-nvidia-utils
                fi
            elif grep -iq "open" "$DRIVERFILE"; then
                pacman -S --noconfirm mesa xf86-video-nouveau
            fi
        else
            echo "defaulting to open source driver"
            pacman -S --noconfirm mesa xf86-video-nouveau
        fi
        pacman -S --noconfirm --needed vulkan-icd-loader
        if command -v systemctl; then
            pacman -S --noconfirm --needed lib32-vulkan-icd-loader
        fi
    ## Intel
    elif lspci | grep -i vga | grep -i intel; then
        echo "intel integrated detected"
        pacman -S --noconfirm mesa xf86-video-intel
    else
        echo "other graphics detected"
        pacman -S mesa --noconfirm
    fi
fi

# 32 bit mesa
if ! uname -m | grep -q '^i' && command -v systemctl; then
    pacman -S --noconfirm lib32-mesa
fi
