#!/bin/bash

pacman -Syu --noconfirm
pacman -S fzf --noconfirm
pacman -S sdisk --noconfirm
pacman -S expect --noconfirm
pacman -S git --noconfirm

cd /root
git clone --depth=1 https://github.com/instantos/instantARCH.git
cd instantARCH
