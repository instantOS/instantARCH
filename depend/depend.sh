#!/bin/bash
pacman -Sy --noconfirm

echo "downloading installer dependencies"

while ! pacman -S --noconfirm --needed \
    fzf \
    expect \
    git \
    dialog \
    bash \
    curl; do
    echo "downloading packages failed, please reconnect to internet"
    sleep 10
done
