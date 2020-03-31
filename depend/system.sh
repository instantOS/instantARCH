#!/bin/bash

echo "installing additional system software"

pacman -Sy --noconfirm

while ! pacman -S xorg --noconfirm --needed; do
    dialog --msgbox "package installation failed \nplease reconnect to internet" 700 700
done

while ! pacman -S --noconfirm --needed \
    sudo \
    lightdm \
    bash \
    vim \
    openbox \
    xterm \
    lightdm-gtk-greeter \
    grub; do
    dialog --msgbox "package installation failed \nplease reconnect to internet" 700 700
done
