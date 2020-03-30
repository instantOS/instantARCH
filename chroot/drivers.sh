#!/bin/bash
echo "installing video drivers"

if lspci | grep -i vga | grep -i nvidia; then
    echo "nvidia card detected"
    pacman -S nvidia --noconfirm
    pacman -S nvidia-utils --noconfirm

elif lspci | grep -i vga | grep -i intel; then
    echo "intel integrated detected"
    pacman -S xf86-video-intel --noconfirm
    pacman -S mesa --noconfirm
fi
