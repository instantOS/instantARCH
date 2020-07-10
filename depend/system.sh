#!/bin/bash

# installs basic dependencies not specific to instantOS

echo "installing additional system software"

pacman -Sy --noconfirm

while ! pacman -S xorg --noconfirm --needed; do
    dialog --msgbox "package installation failed \nplease reconnect to internet" 700 700
    iroot automirror && command -v reflector &&
        reflector --latest 40 --protocol http --protocol https --sort rate --save /etc/pacman.d/mirrorlist

done

# the comments are used for parsing while building a live iso. Do not remove

# install begin
while ! pacman -S --noconfirm --needed \
    sudo \
    lightdm \
    bash \
    zsh \
    xterm \
    systemd-swap \
    neofetch \
    pulseaudio \
    alsa-utils \
    usbutils \
    lightdm-gtk-greeter \
    inetutils \
    xdg-desktop-portal-gtk \
    xorg-xinit \
    firefox \
    nitrogen \
    lshw \
    gxkb \
    udiskie \
    gedit \
    ttf-liberation \
    ttf-joypixels \
    mpv \
    gvfs-mtp \
    unzip \
    xdg-user-dirs-gtk \
    noto-fonts-emoji \
    accountsservice \
    grub; do # install end

    sleep 10
    command -v reflector &&
        reflector --latest 40 --protocol http --protocol https --sort rate --save /etc/pacman.d/mirrorlist &&
        pacman -Sy --noconfirm

done

# iso for postinstall guestadditions
if iroot guestadditions; then
    echo "installing virtualbox guest addidions"
    pacman -S --noconfirm --needed virtualbox-guest-iso
fi

# optional extra packages
if iroot packages &>/dev/null; then
    echo "installing extra packages"
    iroot packages | pacman -S --noconfirm --needed -
fi

if command -v systemctl; then
    pacman -S --noconfirm --needed steam steam-native-runtime
fi

# artix packages
if command -v sv; then
    echo "installing additional runit packages"
    pacman -S --noconfirm --needed lightdm-runit networkmanager-runit
fi
