#!/bin/bash

if ! iroot guestadditions; then
    exit
fi

mkdir -p /media/virtualbox
mount /usr/lib/virtualbox/additions/*.iso /media/virtualbox
echo "installing virtualbox guest additions. This will take some time. 
It is normal for the first reboot after the installation of guest additions to take longer. " | imenu -M &

sleep 2
cd /media/virtualbox

./VBoxLinuxAdditions.run

pkill imenu
sleep 2
reboot
