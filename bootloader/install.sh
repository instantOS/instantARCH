#!/bin/bash
echo "installing grub for legacy bios"
DISK="$(cat /root/instantARCH/config/disk)"
DISK1=$(fdisk -l | grep "^${DISK}" | grep -o '^[^ ]*' |
    head -1 | grep -o '[^ ]*')

echo "installing grub to $DISK1"
grub-install --target=i386-pc "${DISK1}" --root /mnt
