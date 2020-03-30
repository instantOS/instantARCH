#!/bin/bash

source <(curl -Ls git.io/paperbash)
pb dialog

NEWHOSTNAME=$(textbox enter hostname)

echo "$NEWHOSTNAME" >/etc/hostname

echo "127.0.0.1 localhost" >/etc/hosts
echo "::1 localhost" >>/etc/hosts
echo "127.0.1.1 $NEWHOSTNAME.localdomain $NEWHOSTNAME" >>/etc/hosts

pacman -S --noconfirm networkmanager
systemctl enable NeworkManager
