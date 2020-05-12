#!/bin/bash

# automatic disk partitioning

DISK=$(cat /root/instantARCH/config/disk)

if efibootmgr; then
    echo "efi system"
    echo "label: dos
start=        4096, size=      614400, type=ef
start=618496, type=83, bootable" | sfdisk "${DISK}"

    DISK1=$(fdisk -l | grep ^${DISK} | grep -o '^[^ ]*' | head -1)
    DISK2=$(fdisk -l | grep ^${DISK} | grep -o '^[^ ]*' | tail -1)

    mkfs.fat -F32 "$DISK1"
    mkfs.ext4 -F "$DISK2"

else
    echo "legacy bios"
    echo "label: dos
type=83, bootable" | sfdisk "${DISK}"
    DISK1="$(fdisk -l | grep ^${DISK} | head -1)"

    mkfs.ext4 -F "$DISK1"

fi
