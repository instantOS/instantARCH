#!/bin/bash

# main script calling others

# DO NOT USE, NOT READY YET

# check for internet
if ! ping -c 1 google.com &> /dev/null; then
    echo "no internet"
    exit
fi

# print logo
curl -s 'https://raw.githubusercontent.com/instantOS/instantLOGO/master/ascii.txt'

# install dependencies

pacman -Syu --noconfirm
pacman -S fzf --noconfirm
pacman -S sdisk --noconfirm
pacman -S expect --noconfirm
pacman -S git --noconfirm

cd /root
git clone --depth=1 https://github.com/instantos/instantARCH.git
