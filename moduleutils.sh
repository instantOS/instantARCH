#!/bin/bash

# utilities that are supposed to be imported into a mudule before running it

export IROOT="${IROOT:-/root/instantARCH/config}"
export INSTANTARCH="${INSTANTARCH:-/root/instantARCH}"

source /root/instantARCH/utils.sh

# install pacman packages and try a few things to fix pacman without user input
# if installation fails
pacloop() {
    while ! pacman -S --noconfirm --needed $@; do
        echo 'Package installation failed
Please ensure you are connected to the internet' | imenu -M
        if {
            ! [ -e /root/instantARCH/refreshedkeyring ] || [ -z "$REFRESHEDKEYRING" ]
        } && ! [ "$1" = "archlinux-keyring" ]; then
            pacman -Sy archlinux-keyring --noconfirm
            export REFRESHEDKEYRING="true"
            mkdir /root/instantARCH
            touch /root/instantARCH/refreshedkeyring
            continue
        fi

        if command -v reflector; then
            reflector --latest 40 --protocol http --protocol https --sort rate --save /etc/pacman.d/mirrorlist
        else
            pacman-mirrors --geoip
        fi
        updaterepos
        echo "retrying package installation in 4 seconds"
        sleep 4
    done
}

# pacstrap wrapper to accomodate different arch based systems and install isos
pacstraploop() {

    PACSTRAP_ARGLIST=()

    # use host package cache if installation disk is an instantOS iso
    # TODO function to better check if we are on an instantOS iso
    if [ -e /usr/share/liveutils ]; then
        PACSTRAP_ARGLIST+=("-c")
    fi

    while ! {
        if command -v pacstrap &>/dev/null; then
            pacstrap "${PACSTRAP_ARGLIST[@]}" /mnt $@
        else
            basestrap "${PACSTRAP_ARGLIST[@]}" /mnt $@
        fi
    }; do
        imenu -m "package installation failed. ensure you are connected to the internet"
        sleep 2
    done
    # clean up cache so ramfs doesn't fill up
    yes | pacman -Scc
}
