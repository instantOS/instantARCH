#!/bin/bash

NEWHOSTNAME=$(cat /root/instantARCH/config/hostname)

# default hostname
if [ -z "$NEWHOSTNAME" ]; then
    NEWHOSTNAME="instantos"
fi

echo "$NEWHOSTNAME" >/etc/hostname

echo "127.0.0.1 localhost" >/etc/hosts
echo "::1 localhost" >>/etc/hosts
echo "127.0.1.1 $NEWHOSTNAME.localdomain $NEWHOSTNAME" >>/etc/hosts
hostnamectl set-hostname "$NEWHOSTNAME"

pacman -S --noconfirm networkmanager
systemctl enable NetworkManager
