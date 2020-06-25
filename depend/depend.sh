#!/bin/bash

# this installs dependencies needed for the installer
# like fzf for menus

if [ -e /opt/instantos/buildmedium ]; then
    echo "skipping dependencies"
    exit
fi

echo "downloading installer dependencies"

setinfo() {
    if [ -e /usr/share/liveutils ]; then
        pkill instantmenu
    fi
    echo "$@" >/opt/instantprogress
    echo "$@"
}

setinfo "downloading installer dependencies"

# mark install as non-topinstall
mkdir -p /opt/instantos
touch /opt/instantos/realinstall

if command -v systemctl; then
    # enable multilib
    # do it before updating mirrors
    if uname -m | grep -q '^i' ||
        grep -qi '^\[multilib' /etc/pacman.conf ||
        grep -qi 'manjaro' /etc/os-release; then
        echo "not enabling multilib"
    else
        echo "enabling multilib"
        echo "[multilib]" >>/etc/pacman.conf
        echo "Include = /etc/pacman.d/mirrorlist" >>/etc/pacman.conf
    fi
fi

pacman -Sy --noconfirm

# install reflector for automirror
if ! grep -i 'manjaro' /etc/os-release && command -v systemctl; then
    while ! pacman -S --noconfirm --needed reflector; do
        echo "reflector install failed"
        sleep 10
    done
fi

while ! pacman -S --noconfirm --needed \
    fzf \
    expect \
    git \
    os-prober \
    dialog \
    imvirt \
    lshw \
    bash \
    pacman-contrib \
    curl; do
    echo "downloading packages failed, please reconnect to internet"
    sleep 10

    if iroot automirror; then
        # download new mirrors if on arch
        if command -v reflector; then
            reflector --latest 40 --protocol http --protocol https --sort rate --save /etc/pacman.d/mirrorlist
        else
            pacman-mirrors --geoip
        fi
    fi
    pacman -Sy --noconfirm

done

if [ -e /usr/share/liveutils ]; then
    pkill instantmenu
fi

# installer variables utility
cat /root/instantARCH/iroot.sh >/usr/bin/iroot
chmod 755 /usr/bin/iroot
