#!/bin/bash

DISK=$(cat /root/instantARCH/config/disk)

mount ${DISK}1 /mnt

pacman -Sy --noconfirm

while ! pacstrap /mnt base linux linux-firmware; do
    dialog --msgbox "package installation failed \nplease reconnect to internet" 700 700
done

genfstab -U /mnt >>/mnt/etc/fstab

cd /root
cp -r ./instantARCH /mnt/root/instantARCH
