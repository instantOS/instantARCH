#!/bin/bash

if [ -e /opt/instantos/buildmedium ]; then
    echo "skipping dependencies"
    exit
fi

pacman -Sy --noconfirm

echo "downloading installer dependencies"

setinfo() {
    if [ -e /usr/share/liveutils ]; then
        pkill instantmenu
    fi
    echo "$@" >/opt/instantprogress
}

setinfo "downloading installer dependencies"

while ! pacman -S --noconfirm --needed \
    fzf \
    expect \
    git \
    dialog \
    bash \
    curl; do
    echo "downloading packages failed, please reconnect to internet"
    sleep 10

    # download new mirrors if on arch
    if command -v reflector; then
        reflector --latest 40 --protocol http --protocol https --sort rate --save /etc/pacman.d/mirrorlist
    else
        pacman-mirrors --geoip
    fi
    pacman -Sy --noconfirm

done

if [ -e /usr/share/liveutils ]; then
    pkill instantmenu
fi
