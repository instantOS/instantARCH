#!/bin/bash

# main script calling others

# DO NOT USE, NOT READY YET

# print logo
curl -s 'https://raw.githubusercontent.com/instantOS/instantLOGO/master/ascii.txt'
echo ""

echo "selecting fastest mirror"
# sort mirrors
pacman -Sy --noconfirm
pacman -S reflector --noconfirm
reflector --sort rate --save /etc/pacman.d/mirrorlist

# install dependencies
pacman -Sy --noconfirm
pacman -S git --noconfirm --needed

cd /root
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
