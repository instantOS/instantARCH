#!/bin/bash

# this runs in chroot

if ! iroot encrypt; then
    echo "skipping encryption initcpio"
    exit
fi

sed -i '/^HOOKS/s/ filesystems/ encrypt lvm2 filesystems/g' /etc/mkinitcpio.conf
