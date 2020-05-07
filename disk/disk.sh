#!/bin/bash

# automatic disk partitioning

DISK=$(cat /root/instantARCH/config/disk)

echo "label: dos
${DISK}1 type=83, bootable" | sfdisk "${DISK}"

mkfs.ext4 -F ${DISK}1
