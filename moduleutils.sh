#!/bin/bash

# utilities that are supposed to be imported into a mudule before running it

export IROOT="${IROOT:-/root/instantARCH/config}"
export INSTANTARCH="${INSTANTARCH:-/root/instantARCH}"

updaterepos() {
    pacman -Sy --noconfirm || return 1

    # Mirrors can replace db files with html pages and pacman will not detect this
    # This is a workaround to detect dead mirrors with 404.html pages and get a
    # new mirrorlist instead
    if pacman -Si bash 2>&1 | grep -iq 'unrecognized archive'; then
        echo 'getting new mirrorlist'
        curl -s 'https://archlinux.org/mirrorlist/?country=all&protocol=http&protocol=https&ip_version=4&use_mirror_status=on' | sed 's/^#//g' >/etc/pacman.d/mirrorlist
        rm /var/lib/pacman/sync/*
        pacman -Sy --noconfirm || return 1
        if pacman -Si bash 2>&1 | grep -iq 'unrecognized archive'; then
            echo 'still problems, shuffling mirrorlist'
            curl -s 'https://archlinux.org/mirrorlist/?country=all&protocol=http&protocol=https&ip_version=4&use_mirror_status=on' | sed 's/^#//g' | shuf >/etc/pacman.d/mirrorlist
            rm /var/lib/pacman/sync/*
        fi
        pacman -Sy --noconfirm || return 1
    fi
}

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
