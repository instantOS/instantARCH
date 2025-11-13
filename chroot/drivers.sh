#!/bin/bash
# auto detect graphics card and install drivers accordingly
# if the system uses nvidia, read out the user choice

echo "installing video drivers"

source /root/instantARCH/moduleutils.sh

# works differently on manjaro
if ! grep -iq '^name.*arch' /etc/os-release; then
    exit
fi

if iroot isvm; then
    echo "installing virtual machine drivers"
    if iroot kvm; then
        echo "installing QEMU drivers"
        pacloop xorg-drivers
    else
        if iroot vmware || lspci | grep -i vmware; then
            pacloop open-vm-tools
            sudo systemctl enable vmtoolsd.service
        fi
        pacloop mesa xf86-video-vmware
    fi
else
    ## NVIDIA
    if lspci | grep -i vga | grep -i nvidia; then
        pacman -S --noconfirm dkms
        # user chooses open source, proprietary or no driver
        if iroot graphics; then
            DRIVERFILE="$IROOT/graphics"
            if grep -iq "nodriver" "$DRIVERFILE"; then
                exit
            elif grep -iq "dkms" "$DRIVERFILE"; then
                pacloop nvidia-dkms nvidia-utils

                if ! uname -m | grep -q '^i'; then
                    pacloop lib32-nvidia-utils
                fi
            elif grep -iq "nvidia" "$DRIVERFILE"; then
                pacloop nvidia nvidia-utils nvidia-lts
                if ! uname -m | grep -q '^i'; then
                    pacloop lib32-nvidia-utils
                fi
            elif grep -iq "open" "$DRIVERFILE"; then
                pacloop mesa xf86-video-nouveau
            fi

            if iroot graphics | grep -iEq '(|dkms)'; then
                echo "installing nvidia-settings"
                pacloop nvidia-settings
            fi
        else
            echo "defaulting to open source driver"
            pacloop mesa xf86-video-nouveau
        fi
        pacloop vulkan-icd-loader
        pacloop lib32-vulkan-icd-loader
    ## Intel
    elif lspci | grep -i vga | grep -i intel; then
        echo "intel integrated detected"
        pacloop mesa xf86-video-intel
    else
        echo "other graphics detected"
        pacloop mesa xorg-drivers
    fi
fi

# 32 bit mesa
if ! uname -m | grep -q '^i'; then
    pacloop lib32-mesa
fi

if lspci | grep -i marvell; then
    echo "installing firmware needed for marvell wifi"
    pacloop linux-firmware-marvell
fi
