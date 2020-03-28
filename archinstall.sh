#!/bin/bash
# DO NOT USE, NOT READY YET

# check for internet
if ! ping -c 1 google.com; then
    echo "no internet"
    exit
fi

# install dependencies
if ! command -v fzf; then
    echo "installing fzf"
    pacman -Syu --noconfirm
    pacman -S fzf --noconfirm
    pacman -S sdisk --noconfirm
fi
