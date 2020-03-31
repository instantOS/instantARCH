#!/bin/bash
grub-install --target=i386-pc "$(cat /root/instantARCH/config/disk)" --root /mnt
