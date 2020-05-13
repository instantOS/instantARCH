#!/bin/bash

###################################################
## This is the official installer for instantOS  ##
## instantOS is migrating from calamares to this ##
###################################################

# main script calling others

# DO NOT USE ON ACTUAL HARDWARE YET

if [ -e /usr/share/liveutils ]; then
    imenu -m "preparing installation" &
fi

# print logo
echo ""
echo ""
curl -s 'https://raw.githubusercontent.com/instantOS/instantLOGO/master/ascii.txt' | sed 's/^/    /g'
echo ""
echo ""

# sort mirrors
pacman -Sy --noconfirm
pacman -S reflector --noconfirm

echo "selecting fastest mirror"
reflector --latest 40 --protocol http --protocol https --sort rate --save /etc/pacman.d/mirrorlist

# install dependencies
pacman -Sy --noconfirm
pacman -S git --noconfirm --needed

cd /root
[ -e instantARCH ] && rm -rf instantARCH
git clone --depth=1 https://github.com/instantos/instantARCH.git
cd instantARCH

./depend/depend.sh
cd /root/instantARCH
./ask.sh

chmod +x *.sh
chmod +x **/*.sh
echo "local install"
./localinstall.sh
echo "in-system install"
./systeminstall.sh

echo "done installing arch linux"
