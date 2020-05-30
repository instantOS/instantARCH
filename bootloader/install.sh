#!/bin/bash

# installs grub on legacy boot systems
# runs from outside the installation

echo "installing grub for legacy bios"
DISK="$(cat /root/instantARCH/config/disk)"

grub-install --target=i386-pc "${DISK}" --root /mnt
