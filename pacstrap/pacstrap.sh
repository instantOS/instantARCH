#!/bin/bash

DISK=$(cat /root/instantARCH/config/disk)

if efibootmgr; then
    mount ${DISK}2 /mnt
    mount ${DISK}1 /efi
else
    mount ${DISK}1 /mnt
fi

pacman -Sy --noconfirm

while ! pacstrap /mnt base linux linux-firmware reflector; do
    dialog --msgbox "package installation failed \nplease reconnect to internet" 700 700
done

genfstab -U /mnt >>/mnt/etc/fstab

cd /root
cp -r ./instantARCH /mnt/root/instantARCH
