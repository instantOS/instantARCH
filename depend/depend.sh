#!/bin/bash

# this installs dependencies needed for the installer
# like fzf for menus

source /root/instantARCH/moduleutils.sh

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

updaterepos

# install reflector for automirror
if ! grep -i 'manjaro' /etc/os-release && command -v systemctl; then
    pacloop reflector
fi

checkpackage() {
    if command -v "$1" || pacman -Qi "$1" &>/dev/null; then
        echo "$1 is installed"
    else
        pacloop "$1"
    fi
}

installdepends() {

    if ! [ -e /usr/share/liveutils ]; then
        pacloop fzf \
            expect \
            git \
            os-prober \
            dialog \
            imvirt \
            lshw \
            bash \
            pacman-contrib \
            curl

    else
        echo "installing without upgrading"

        checkpackage fzf || return 1
        checkpackage expect || return 1
        checkpackage git || return 1
        checkpackage os-prober || return 1
        checkpackage dialog || return 1
        checkpackage imvirt || return 1
        checkpackage lshw || return 1
        checkpackage bash || return 1
        checkpackage pacman-contrib || return 1
        checkpackage curl || return 1
    fi
}

while ! installdepends; do
    if command -v notify-send &>/dev/null && pgrep Xorg; then
        notify-send "downloading packages failed, please reconnect to internet"
    fi

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
    updaterepos

done

# upgrade instantmenu
if command -v instantmenu; then
    pacloop instantmenu
fi

if [ -e /usr/share/liveutils ]; then
    pkill instantmenu
fi

# installer variables utility
cat /root/instantARCH/iroot.sh >/usr/bin/iroot
chmod 755 /usr/bin/iroot
