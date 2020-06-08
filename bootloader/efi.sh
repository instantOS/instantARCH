#!/bin/bash

# installs grub on uefi systems
# runs from inside the installation
# unlike the legacy bios grub script

if iroot nobootloader; then
    echo "skipping bootloader install"
    exit
fi

mkdir /efi
mount "$(iroot partefi)" /efi

sudo pacman -S efibootmgr grub --noconfirm

grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB
