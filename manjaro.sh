#!/bin/bash

##################################
## an instantOS install script  ##
## using calamares as a wrapper ##
##################################

echo "installing instantOS manjaro edition"

cd /root
[ -e instantARCH ] && rm -rf instantARCH
git clone --depth=1 https://github.com/instantos/instantARCH.git
cd instantARCH

chmod 755 ./*/*.sh

./depend/depend.sh
./init/init.sh

pacman -S --noconfirm --needed base \
    linux linux-headers \
    linux-lts linux-lts-headers \
    linux-firmware

./depend/system.sh
./user/modify.sh
./instantos/install.sh

echo "done installing instantOS"
