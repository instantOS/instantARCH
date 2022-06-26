#!/bin/bash

# install base system to target root partition

if ! mount | grep '/mnt'; then
    echo "mount failed"
    exit 1
fi

pacman -Sy --noconfirm
# needed to get pacstrap working on isos with expired keys
pacloop archlinux-keyring

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
        imenu -e "package installation failed \nplease reconnect to internet"
    done
else
    # artix or manjaro
    if command -v systemctl; then
        while ! basestrap /mnt base ${KERNEL} ${KERNEL}-headers linux-firmware; do
            imenu -e "manjaro package installation failed \nplease reconnect to internet"
        done
    else
        while ! basestrap /mnt runit elogind-runit base base-devel ${KERNEL} ${KERNEL}-headers linux-firmware; do
            sleep 2
            imenu -e "artix package installation failed \nplease reconnect to internet"
        done
    fi
fi

if command -v genfstab; then
    genfstab -U /mnt >>/mnt/etc/fstab
else
    fstabgen -U /mnt >>/mnt/etc/fstab
fi

cd /root || exit 1

cp -r ./instantARCH /mnt/root/instantARCH
if [ -e /etc/instantos/liveversion ]; then
    cat /etc/instantos/liveversion >/mnt/root/instantARCH/config/liveversion
else
    echo 'old iso used, unversioned'
fi

{
    cat /etc/pacman.d/mirrorlist
    echo ''
    echo '# modified by instantARCH'
} >/mnt/etc/pacman.d/mirrorlist
