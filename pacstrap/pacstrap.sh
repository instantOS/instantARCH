#!/bin/bash

# install base system to target root partition

if ! mount | grep '/mnt'; then
    echo "mount failed"
    exit 1
fi

pacman -Sy --noconfirm

# kernel selection
if iroot kernel; then
    KERNEL="$(iroot kernel)"
else
    # fallback to linux-lts
    KERNEL="linux-lts"
fi

# we're on arch
if command -v pacstrap; then
    while ! pacstrap /mnt base ${KERNEL} ${KERNEL}-headers linux-firmware reflector; do
        dialog --msgbox "package installation failed \nplease reconnect to internet" 700 700
    done
else
    # artix or manjaro
    if command -v systemctl; then
        while ! basestrap /mnt base ${KERNEL} ${KERNEL}-headers linux-firmware; do
            dialog --msgbox "manjaro package installation failed \nplease reconnect to internet" 700 700
        done
    else
        while ! basestrap /mnt runit elogind-runit base base-devel ${KERNEL} ${KERNEL}-headers linux-firmware; do
            sleep 2
            dialog --msgbox "artix package installation failed \nplease reconnect to internet" 700 700
        done
    fi
fi

if command -v genfstab; then
    genfstab -U /mnt >>/mnt/etc/fstab
else
    fstabgen -U /mnt >>/mnt/etc/fstab
fi

cd /root
cp -r ./instantARCH /mnt/root/instantARCH
cat /etc/pacman.d/mirrorlist >/mnt/etc/pacman.d/mirrorlist
