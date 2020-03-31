#!/bin/bash

# automatic disk partitioning

source <(curl -Ls git.io/paperbash)
pb dialog

fdisk -l

while [ -z "$DISK" ]; do
    DISK=$(fdisk -l | grep -i '^Disk /.*:' | fzf --prompt "select disk")
    if ! confirm "Install on $DISK ? this will delete all data on $DISK"; then
        unset DISK
    fi
done

grep -o '/dev/[^:]*' <<<"$DISK" >/root/instantdisk
DISK=$(cat /root/instantdisk)

sed -i "s~instantdisk~$DISK~g" /root/instantARCH/disk/format.sh
/root/instantARCH/disk/format.sh

mkfs.ext4 ${DISK}1
mkswap ${DISK}2
swapon ${DISK}2

echo "done partitioning disks"
