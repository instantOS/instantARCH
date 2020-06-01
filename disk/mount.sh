#!/bin/bash

# mounts all partitions to to the installation medium

# mountpart partname mountpoint
mountpart() {
    if [ -e /root/instantARCH/config/part$1 ]; then
        TMPPART="$(cat /root/instantARCH/config/part$1)"
        echo "mounting $TMPPART to $2"
        mount "$TMPPART" "$2"
    else
        echo "using default partition for $2"
    fi
}

mountpart efi /efi
mountpart root /mnt
sleep 2

if ! mount | grep -q '/mnt'; then
    echo "mount failed"
    exit 1
fi