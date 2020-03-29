#!/bin/bash

# automatic disk partitioning

fdisk -l

DISK=$(fdisk -l | grep -oi '^Disk /.*:' | fzf --prompt "select disk")

grep -o '/dev/[^:]*' <<< "$DISK" > /root/instantdisk
