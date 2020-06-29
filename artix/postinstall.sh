#!/bin/bash

# this script only runs on artix
# and adjusts some stuff that causes problems during installation

if command -v systemctl; then
    echo "skipping artix hooks"
    exit
fi

echo "reverting pacaman fixes"
sed -i '/Optional TrustAll/d' /etc/pacman.conf
sleep 1

enableservice() {
    if [ -e /run/runit/service ]; then
        echo "enabling runit service $1 in /run/runit/service"
        ln -s /etc/runit/sv/"$1" /run/runit/service
    else
        echo "enabling runit service $1 in /etc/runit/runsvdir/current"
        ln -s /etc/runit/sv/"$1" /etc/runit/runsvdir/current
    fi
}
/run/runit/service
# enable services

echo "enabling services"

enableservice NetworkManager
enableservice lightdm
