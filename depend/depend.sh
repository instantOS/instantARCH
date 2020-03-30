#!/bin/bash
pacman -Sy
echo "downloading installer dependencies"
pacman -S --noconfirm --needed \
    fzf \
    expect \
    git \
    dialog \
    bash \
    curl
