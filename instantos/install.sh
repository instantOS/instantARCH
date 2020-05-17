#!/bin/bash

cd
git clone --depth 1 https://github.com/instantOS/instantOS
cd instantOS
bash repo.sh
pacman -Sy --noconfirm

while ! pacman -S instantos --noconfirm; do
    if [ -e /usr/share/liveutils ]; then
        imenu -m "package installation failed.
Please ensure you are connected to the internet"
    fi

    command -v reflector && reflector --latest 40 --protocol http --protocol https --sort rate --save /etc/pacman.d/mirrorlist
done

while ! pacman -S instantdepend --noconfirm; do
    if [ -e /usr/share/liveutils ]; then
        imenu -m "package installation failed.
Please ensure you are connected to the internet"
    fi

    command -v reflector && reflector --latest 40 --protocol http --protocol https --sort rate --save /etc/pacman.d/mirrorlist
done
cd ~/instantOS
bash rootinstall.sh

# change greeter appearance
[ -e /etc/lightdm ] || mkdir -p /etc/lightdm
cat /usr/share/instantdotfiles/lightdm-gtk-greeter.conf >/etc/lightdm/lightdm-gtk-greeter.conf
