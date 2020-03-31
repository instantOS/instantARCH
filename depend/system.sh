#!/bin/bash

echo "installing additional system software"

pacman -Sy --noconfirm
pacman -S xorg --noconfirm --needed

pacman -S --noconfirm --needed \
    sudo \
    lightdm \
    bash \
    vim \
    openbox \
    xterm \
    lightdm-gtk-greeter
