#!/bin/bash

# automatic disk partitioning

DISK=$(cat /root/instantARCH/config/disk)

if efibootmgr; then
    echo "efi system"
    echo "label: dos
${DISK}1 : start=        4096, size=      614400, type=ef
${DISK}2: start=618496, type=83, bootable" | sfdisk "${DISK}"

    mkfs.fat32 -F ${DISK}1
    mkfs.ext4 -F ${DISK}2

else
    echo "legacy bios"
    echo "label: dos
${DISK}1 : type=83, bootable" | sfdisk "${DISK}"
    mkfs.ext4 -F ${DISK}1

fi
