#!/bin/bash
echo "installing grub for legacy bios"
DISK="$(cat /root/instantARCH/config/disk)"

grub-install --target=i386-pc "${DISK}" --root /mnt
