#!/bin/bash

IROOT="/root/instantARCH/config"

if ! iroot manualpartitioning; then
    # automatic disk partitioning

    DISK="$(iroot disk)"

    if efibootmgr; then
        echo "efi system"
        echo "label: dos
start=        4096, size=      614400, type=ef
start=618496, type=83, bootable" | sfdisk "${DISK}"

        DISK1="$(fdisk -l | grep "^${DISK}" | grep -o '^[^ ]*' | head -1)"
        DISK2="$(fdisk -l | grep "^${DISK}" | grep -o '^[^ ]*' | tail -1)"

        mkfs.fat -F32 "$DISK1"
        mkfs.ext4 -F "$DISK2"

        echo "$DISK1" | iroot i partefi
        echo "$DISK2" | iroot i partroot

    else
        echo "legacy bios"
        echo "label: dos
type=83, bootable" | sfdisk "${DISK}"
        DISK1="$(fdisk -l | grep "^${DISK}" | grep -o '^[^ ]*' | head -1)"

        mkfs.ext4 -F "$DISK1"
        echo "$DISK1" | iroot i partroot

    fi
else

    echo "doing manual partitioning"
    if iroot parthome && iroot erasehome; then
        echo "creating ext4 file system for home in $(iroot parthome)"
        mkfs.ext4 -F "$(cat $IROOT/parthome)"
    fi

    if iroot partswap; then
        echo "creating swap"
        mkswap "$(iroot partswap)"
    fi

    mkfs.ext4 -F "$(iroot partroot)"

fi
