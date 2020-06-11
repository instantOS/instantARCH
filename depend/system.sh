#!/bin/bash

# installs basic dependencies not specific to instantOS

echo "installing additional system software"

pacman -Sy --noconfirm

while ! pacman -S xorg --noconfirm --needed; do
    dialog --msgbox "package installation failed \nplease reconnect to internet" 700 700
    iroot automirror && command -v reflector &&
        reflector --latest 40 --protocol http --protocol https --sort rate --save /etc/pacman.d/mirrorlist

done

while ! pacman -S --noconfirm --needed \
    sudo \
    lightdm \
    bash \
    zsh \
    vim \
    xterm \
    systemd-swap \
    neofetch \
    pulseaudio \
    alsa-utils \
    usbutils \
    lightdm-gtk-greeter \
    inetutils \
    xdg-desktop-portal-gtk \
    steam \
    alacritty \
    firefox \
    lshw \
    gedit \
    mpv \
    xdg-user-dirs-gtk \
    accountsservice \
    grub; do

    sleep 10
    command -v reflector &&
        reflector --latest 40 --protocol http --protocol https --sort rate --save /etc/pacman.d/mirrorlist &&
        pacman -Sy --noconfirm

done
