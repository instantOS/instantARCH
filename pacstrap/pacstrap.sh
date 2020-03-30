#!/bin/bash

DISK=$(cat /root/instantdisk)

mount ${DISK}1 /mnt

pacman -Sy --noconfirm
pacstrap /mnt base linux linux-firmware

genfstab -U /mnt >>/mnt/etc/fstab

cd /root
cp -r ./instantARCH /mnt/root/instantARCH
