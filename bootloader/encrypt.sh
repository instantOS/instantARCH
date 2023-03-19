#!/bin/bash

# make grub make the kernel aware of ecrypted volume

if ! iroot encrypt; then
    echo "skipping bootloader encryption"
    exit
fi

LVM_UUID="$(blkid -o value -s UUID "$(iroot lvmpart)")"

sed -i '/^GRUB_CMDLINE_LINUX=/s~.*~GRUB_CMDLINE_LINUX="cryptdevice=UUID='"$LVM_UUID"':cryptlvm root=/dev/vg1/root"~g' /etc/default/grub
echo 'GRUB_ENABLE_CRYPTODISK=y' >>/etc/default/grub
