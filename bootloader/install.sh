#!/bin/bash

# installs grub on legacy boot systems
# runs from outside the installation

if iroot nobootloader; then
    echo "skipping grub install"
    exit
fi

echo "installing grub for legacy bios"
DISK="$(iroot grubdisk)"

grub-install --target=i386-pc "${DISK}" --root /mnt
