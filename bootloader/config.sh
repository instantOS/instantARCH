#!/bin/bash

if iroot nobootloader; then
    echo "skipping grub configuration"
    exit
fi

# update grub to detect operating systems and apply the instantOS theme
[ -e /boot/grub ] || mkdir /boot/grub
grub-mkconfig -o /boot/grub/grub.cfg
