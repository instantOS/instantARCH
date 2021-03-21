#!/bin/bash

# create swap

if [ -e /opt/topinstall ] || grep -iq manjaro /etc/os-release; then
    echo "topinstall detected, not setting up swap"
    exit
fi

gensystemdswap() {
    if command -v systemctl; then
        # enable swap
        systemctl enable systemd-swap
        {
            echo "swapfc_enabled=1"
            echo "swapfc_max_count=8"
        } >>/etc/systemd/swap.conf
    fi
    echo "installed systemd-swap"
}

genswapfile() {
    dd if=/dev/zero of=/swapfile bs=1M count=512 status=progress
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile

    echo '/swapfile none swap defaults 0 0' >>/etc/fstab
}

if ! iroot swapmethod; then
    # needed to get internet to work
    gensystemdswap
    exit
fi

case $(iroot swapmethod) in
systemd-swap)
    gensystemdswap
    exit
    ;;
swapfile)
    genswapfile
    ;;
none)
    exit
    ;;
*)
    gensystemdswap
    ;;
esac
