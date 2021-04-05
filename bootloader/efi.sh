#!/bin/bash

# installs grub on uefi systems
# runs from inside the installation
# unlike the legacy bios grub script

if iroot nobootloader; then
    echo "skipping bootloader install"
    exit
fi

mkdir /efi
echo 'trying to mount '"$(iroot partefi)"
mount "$(iroot partefi)" /efi || exit 1

sudo pacman -S efibootmgr grub --noconfirm || exit 1

if ! grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB; then
    umount /efi || exit 1
    mkfs.fat -F32 "$(iroot partefi)" || exit 1
    mount "$(iroot partefi)" /efi || exit 1
    grub-install --efi-directory=/efi || exit 1
fi
