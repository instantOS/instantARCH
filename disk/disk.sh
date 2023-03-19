#!/bin/bash

IROOT="/root/instantARCH/config"

if ! iroot manualpartitioning; then
    # automatic disk partitioning

    DISK="$(iroot disk)"

    if efibootmgr &>/dev/null; then
        echo "efi system"
        echo "label: dos
start=        4096, size=      614400, type=ef
start=618496, type=83, bootable" | sfdisk "${DISK}"

        EFIPART="$(fdisk -l | grep "^${DISK}" | grep -o '^[^ ]*' | head -1)"
        ROOTPART="$(fdisk -l | grep "^${DISK}" | grep -o '^[^ ]*' | tail -1)"

        echo "$EFIPART" | iroot i partefi
        echo "$ROOTPART" | iroot i partroot

    else
        echo "legacy bios"

        echo "label: dos
type=83, bootable" | sfdisk "${DISK}"
        DISK1="$(fdisk -l | grep "^${DISK}" | grep -o '^[^ ]*' | head -1)"

        echo "$DISK1" | iroot i partroot

    fi

    if iroot encrypt; then
        echo "encrypting disk"
        CPASSWORD="$(iroot cryptpassword)"
        echo -n "$CPASSWORD" | cryptsetup luksFormat "$ROOTPART" -
        echo -n "$CPASSWORD" | cryptsetup open "$ROOTPART" cryptlvm -
        pvcreate /dev/mapper/cryptlvm
        vgcreate vg1 /dev/mapper/cryptlvm
        lvcreate -l '100%FREE' vg1 -n root
        iroot lvmpart "$ROOTPART"
        iroot partroot /dev/vg1/root
    fi

    echo "paritioning"
    if efibootmgr &>/dev/null; then
        mkfs.fat -F32 "$EFIPART"
        mkfs.ext4 -F "$ROOTPART"
    else
        mkfs.ext4 -F "$ROOTPART"
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
