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
{
    echo "::1 localhost"
    echo "127.0.1.1 $NEWHOSTNAME.localdomain $NEWHOSTNAME"
    echo '
# modified by instantARCH'

} >>/etc/hosts
curl -s 'https://git.samba.org/samba.git/?p=samba.git;a=blob_plain;f=examples/smb.conf.default;hb=HEAD' >/tmp/sambaconfigexample
if grep -q 'example' /tmp/sambaconfigexample; then
    echo "installing samba example config"
    mkdir /etc/samba
    cat /tmp/sambaconfigexample > smb.conf
fi
pacman -S --noconfirm --needed networkmanager

if command -v systemctl; then
    hostnamectl set-hostname "$NEWHOSTNAME"
    systemctl enable NetworkManager
    systemctl enable sshd
else
    echo "no systemd detected, please manually enable sshd and networkmanager"
fi
