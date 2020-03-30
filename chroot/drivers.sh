#!/bin/bash
echo "installing video drivers"

if lspci | grep -i vga | grep -i nvidia; then
    echo "nvidia card detected"
    pacman -S --noconfirm nvidia nvidia-utils
elif lspci | grep -i vga | grep -i intel; then
    echo "intel integrated detected"
    pacman -S --noconfirm mesa xf86-video-intel
else
    echo "other graphics detected, possibly virtualbox"
    pacman -S mesa --noconfirm
fi
