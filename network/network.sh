#!/bin/bash

# change hostname and
# follow arch install guide for hosts

NEWHOSTNAME=$(iroot hostname)

# default hostname
if [ -z "$NEWHOSTNAME" ]; then
    NEWHOSTNAME="instantos"
fi

echo "$NEWHOSTNAME" >/etc/hostname

echo "127.0.0.1 localhost" >/etc/hosts
echo "::1 localhost" >>/etc/hosts
echo "127.0.1.1 $NEWHOSTNAME.localdomain $NEWHOSTNAME" >>/etc/hosts
pacman -S --noconfirm --needed networkmanager

if command -v systemctl; then
    hostnamectl set-hostname "$NEWHOSTNAME"
    systemctl enable NetworkManager
    systemctl enable sshd
else
    echo "no systemd detected, please manually enable sshd and networkmanager"
fi
