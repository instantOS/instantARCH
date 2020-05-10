#!/bin/bash
echo "installing grub for legacy bios"
grub-install --target=i386-pc "$(cat /root/instantARCH/config/disk)" --root /mnt
