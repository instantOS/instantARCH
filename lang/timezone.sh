#!/bin/bash

# symlink timezone from user selected region

cd /usr/share/zoneinfo

if iroot noregion; then
    echo "region is getting skipped"
    exit
fi

if ! iroot timezone; then
    echo "setting region failed"
    exit
fi

REGION="$(iroot timezone)"

ln -sf /usr/share/zoneinfo/$REGION /etc/localtime
timedatectl set-timezone "$REGION"
timedatectl set-ntp true

hwclock --systohc

echo "set timezone to $REGION"
