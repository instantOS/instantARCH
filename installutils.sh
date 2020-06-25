#!/bin/bash

# functions used for the actual installation

# reset working dir
rcd() {
    cd /root/instantARCH
}

# this gets executed if a module fails
# it marks the installation as failed
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

# this sets the status message
# displayed at the bottom of the screen when using the GUI installer
setinfo() {
    if [ -e /usr/share/liveutils ]; then
        pkill instantmenu
    fi
    echo "$@" >/opt/instantprogress
    echo "$@"
}

# run a script inside the installation medium
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
    elif command -v manjaro-chroot; then
        manjaro-chroot /mnt "/root/instantARCH/${1}.sh" || serror
    else
        artools-chroot /mnt "/root/instantARCH/${1}.sh" || serror
    fi

    echo "chroot: $1" >>/tmp/instantprogress

}
