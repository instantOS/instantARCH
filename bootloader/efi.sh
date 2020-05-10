#!/bin/bash

DISK=$(cat /root/instantARCH/config/disk)
mkdir /efi
mount "${DISK}1" /efi

sudo pacman -S efibootmgr grub --noconfirm

grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB
