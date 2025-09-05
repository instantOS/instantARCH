#!/bin/bash

# install base system to target root partition

export INSTANTARCH="${INSTANTARCH:-/root/instantARCH}"
source "$INSTANTARCH"/moduleutils.sh

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
    pacstraploop base
    pacstraploop ${KERNEL}
    pacstraploop ${KERNEL}-headers
    pacstraploop linux-firmware
    pacstraploop reflector
else
    # manjaro probably
    if command -v systemctl; then
        pacstraploop base
        pacstraploop ${KERNEL}
        pacstraploop ${KERNEL}-headers
        pacstraploop linux-firmware
    else
        # non-systemd distro, probably artix
        pacstraploop runit elogind-runit base base-devel ${KERNEL} ${KERNEL}-headers linux-firmware
    fi
fi

# Some arch based distros have the command renamed to fstabgen
if command -v genfstab; then
    genfstab -U /mnt >>/mnt/etc/fstab
else
    fstabgen -U /mnt >>/mnt/etc/fstab
fi

cd /root || exit 1

cp -r ./instantARCH /mnt/root/instantARCH

# record installer iso version on installed system
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
