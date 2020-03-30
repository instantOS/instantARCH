#!/bin/bash

echo "installing additional system software"

pacman -Sy
pacman -S xorg --noconfirm --needed

pacman -S --noconfirm --needed \
    sudo \
    lightdm \
    bash \
    vim \
    openbox \
    lightdm-gtk-greeter
