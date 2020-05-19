#!/bin/bash

DISK=$(cat /root/instantARCH/config/disk)

if efibootmgr; then
    DISK1=$(fdisk -l | grep "^${DISK}" | grep -o '^[^ ]*' | head -1)
    DISK2=$(fdisk -l | grep "^${DISK}" | grep -o '^[^ ]*' | tail -1)

    mount ${DISK2} /mnt
    mount ${DISK1} /efi
else
    DISK1=$(fdisk -l | grep "^${DISK}" | grep -o '^[^ ]*' | head -1)
    mount ${DISK1} /mnt
fi

if ! mount | grep '/mnt.*ext4'; then
    echo "mount failed"
    exit 1
fi

pacman -Sy --noconfirm

if command -v pacstrap; then
    while ! pacstrap /mnt base linux linux-headers linux-lts linux-lts-headers linux-firmware reflector; do
        dialog --msgbox "package installation failed \nplease reconnect to internet" 700 700
    done
else
    while ! basestrap /mnt base linux linux-headers linux-lts linux-lts-headers linux-firmware; do
        dialog --msgbox "manjaro package installation failed \nplease reconnect to internet" 700 700
    done
fi


if command -v genfstab; then
    genfstab -U /mnt >>/mnt/etc/fstab
else
    fstabgen -U /mnt >>/mnt/etc/fstab
fi
cd /root
cp -r ./instantARCH /mnt/root/instantARCH
