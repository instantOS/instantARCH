#!/bin/bash

# general utils used by multiple parts of instantARCH
updaterepos() {
    pacman -Sy --noconfirm || return 1
    if [ -z "$UPDATEDKEYRING" ]; then
        pacman -S archlinux-keyring --noconfirm || exit 1
        pacman-key --populate || exit 1
        export UPDATEDKEYRING="true"
    fi
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

guimode() {
    if [ -e /opt/noguimode ]; then
        return 1
    fi

    if [ -n "$GUIMODE" ]; then
        return 0
    else
        return 1
    fi
}

export IMPORTEDUTILS="true"
