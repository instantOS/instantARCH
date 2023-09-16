#!/bin/bash

# create swap

if [ -e /opt/topinstall ] || grep -iq manjaro /etc/os-release; then
    echo "topinstall detected, not setting up swap"
    exit
fi

getswapfilesize() {
    SIZE="$(free -g | awk '/^Mem:/ {print int(($2 + 1) / 2)}')"
    if [ "$SIZE" -lt 1 ]
    then
        echo "1"
    else
        echo "$SIZE"
    fi
}

genswapfile() {
    dd if=/dev/zero of=/swapfile bs=1M count="$(getswapfilesize)k" status=progress
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
swapfile)
    genswapfile
    ;;
none)
    exit
    ;;
*)
    genswapfile
    ;;
esac
