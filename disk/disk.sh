#!/bin/bash

# automatic disk partitioning

fdisk -l

DISK=$(fdisk -l | grep -oi '^Disk /.*:' | fzf --prompt "select disk")

grep -o '/dev/[^:]*' <<<"$DISK" >/root/instantdisk
echo "selected disk $(cat /root/instantdisk)"

sed -i "s/instantdisk/$DISK/g" /root/instantARCH/disk/format.sh
/root/instantARCH/disk/format.sh
