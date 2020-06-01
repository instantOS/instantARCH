#!/bin/bash

# functions used for the actual installation

rcd() {
    cd /root/instantARCH
}

serror() {
    # touching noerror skips error checking for one check
    if [ -e /opt/noerror ]; then
        echo "skipping error"
        rm /opt/noerror
    else
        # indicator file
        touch /opt/installfailed
        echo "script failed"
        exit 1
    fi
}

setinfo() {
    if [ -e /usr/share/liveutils ]; then
        pkill instantmenu
    fi
    echo "$@" >/opt/instantprogress
    echo "$@"
}

escript() {
    setinfo "${2:-info}"
    rcd
    ./$1.sh || serror
    echo "$1" >>/tmp/instantprogress
}

# scripts executed in installed environment
chrootscript() {
    setinfo "${2:-info}"
    if ! mount | grep -q '/mnt'; then
        echo "mount failed"
        exit 1
    fi

    rcd

    if command -v arch-chroot; then
        arch-chroot /mnt "/root/instantARCH/${1}.sh" || serror
    else
        manjaro-chroot /mnt "/root/instantARCH/${1}.sh" || serror
    fi

    echo "chroot: $1" >>/tmp/instantprogress

}
