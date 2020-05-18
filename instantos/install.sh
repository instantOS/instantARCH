#!/bin/bash

cd
git clone --depth 1 https://github.com/instantOS/instantOS
cd instantOS
bash repo.sh
pacman -Sy --noconfirm

while ! pacman -S instantos instantdepend --noconfirm; do
    if [ -e /usr/share/liveutils ] && ! grep -iq manjaro /etc/os-release; then
        imenu -m "package installation failed.
Please ensure you are connected to the internet"
    fi
    # fetch new mirrors if on arch
    if command -v reflector; then
        reflector --latest 40 --protocol http --protocol https --sort rate --save /etc/pacman.d/mirrorlist
    else
        pacman-mirrors --geoip
    fi
    pacman -Sy --noconfirm

done

cd ~/instantOS
bash rootinstall.sh

# change greeter appearance
[ -e /etc/lightdm ] || mkdir -p /etc/lightdm
cat /usr/share/instantdotfiles/lightdm-gtk-greeter.conf >/etc/lightdm/lightdm-gtk-greeter.conf
