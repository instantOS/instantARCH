#!/bin/bash

DISK=$(cat /root/instantdisk)

mount ${DISK}1 /mnt
pacman -Sy
pacstrap /mnt base linux linux-firmware

genfstab -U /mnt >> /mnt/etc/fstab
