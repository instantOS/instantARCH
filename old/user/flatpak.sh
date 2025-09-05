#!/bin/bash

# add flathub remote

USERNAME="$(iroot user)"
if command -v flatpak; then
    echo "enabling flathub remote"
    sudo -u "$USERNAME" flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi
