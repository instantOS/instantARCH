#!/bin/bash

# This is run as root by instantautostart
# on the actual installation after the first reboot

cd /root/instantARCH || exit 1

bash ./lang/xorg.sh
sleep 0.5
bash ./lang/locale.sh
bash ./lang/apply.sh
bash ./desktop/lightdm.sh

# restore selected mirrorlist
if [ -e "$IROOT"/mirrorlistbackup ] && grep -i "server" "$IROOT"/mirrorlistbackup; then
    cat "$IROOT"/mirrorlistbackup >/etc/pacman.d/mirrorlist
fi
