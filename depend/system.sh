#!/bin/bash

pacman -S xorg --noconfirm

pacman -S --noconfirm \
    sudo \
    lightdm \
    bash \
    vim \
    openbox \
    lightdm-gtk-greeter
