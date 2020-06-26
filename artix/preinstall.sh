#!/bin/bash

# remove trustall from artix after installation

if command -v systemctl; then
    echo "skipping artix hooks"
    exit
fi

echo "running artix hook"
trustrepo() {
    sed -i '/^\['"$1"'\]aSigLevel = Optional TrustAll # instantOS trust hook' /etc/pacman.conf
}

trustrepo "system"
trustrepo "world"
trustrepo "galaxy"
trustrepo "extra"
trustrepo "community"
