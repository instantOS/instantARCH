#!/bin/bash

if iroot nobootloader; then
    echo "skipping grub configuration"
    exit
fi

# update grub to detect operating systems and apply the instantOS theme
grub-mkconfig -o /boot/grub/grub.cfg
