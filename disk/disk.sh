#!/bin/bash

# automatic disk partitioning

DISK=$(cat /root/instantARCH/config/disk | grep -o '/dev/[^:]*')
sed -i "s~instantdisk~$DISK~g" /root/instantARCH/disk/format.sh
/root/instantARCH/disk/format.sh

mkfs.ext4 ${DISK}1
mkswap ${DISK}2
swapon ${DISK}2

echo "done partitioning disks"
