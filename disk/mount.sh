#!/bin/bash

# mounts all partitions to to the installation medium

# mountpart partname mountpoint
mountpart() {
    if iroot part$1; then
        TMPPART="$(iroot part$1)"
        echo "mounting $TMPPART to $2"
        mount "$TMPPART" "$2"
    else
        echo "using default partition for $2"
    fi
}

# todo: optional efi
mountpart efi /efi

mountpart root /mnt
# home is optional
mountpart home /mnt/home
sleep 2

if ! mount | grep -q '/mnt'; then
    echo "mount failed"
    exit 1
fi
