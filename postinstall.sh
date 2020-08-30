#!/bin/bash

# This is run as root by instantautostart
# on the actual installation after the first reboot

cd /root/instantARCH

bash ./lang/xorg.sh
sleep 0.5
bash ./lang/locale.sh
bash ./vm/guestadditions.sh

# restore selected mirrorlist
if [ -e /root/instantARCH/config/mirrorlistbackup ] && grep -i "server" /root/instantARCH/config/mirrorlistbackup 
then
    cat /root/instantARCH/config/mirrorlistbackup > /etc/pacman.d/mirrorlist
fi

