#!/bin/bash

# print logo
echo ""
echo ""
curl -s 'https://raw.githubusercontent.com/instantOS/instantLOGO/master/ascii.txt' | sed 's/^/    /g'
echo ""
echo ""

if ! whoami | grep -iq '^root'; then
    echo "please run this as root"
    exit
fi

# only runs on arch based distros
if ! grep -Eiq '(arch|manjaro)'; then
    echo "system does not appear to be arch based.
instantARCH only works on arch based systems like Arch and Manjaro
are you sure you want to run this?" | imenu -C || {
        imenu -m "installation canceled"
        exit
    }
fi

touch /tmp/climenu
touch /opt/topinstall

curl -s https://raw.githubusercontent.com/instantOS/imenu/master/imenu.sh >/usr/bin/imenu
chmod 755 /usr/bin/imenu

pacman -Sy --noconfirm

pacman -S reflector --noconfirm --needed
echo "selecting fastest mirror"
reflector --latest 40 --protocol http --protocol https --sort rate --save /etc/pacman.d/mirrorlist

pacman -Sy --noconfirm
pacman -S git --noconfirm --needed

cd /root
[ -e instantARCH ] && rm -rf instantARCH
git clone --depth=1 https://github.com/instantos/instantARCH.git
cd instantARCH

chmod 755 ./*/*.sh

./depend/depend.sh

# do all actions requiring user input first
./topask.sh

./init/init.sh

pacman -S --noconfirm --needed base \
    linux linux-headers \
    linux-lts linux-lts-headers \
    linux-firmware

./depend/system.sh
./chroot/chroot.sh
./chroot/drivers.sh
./network/network.sh
./bootloader/config.sh

if ! ls /home/ | grep -q ..; then
    ./user/modify.sh
else
    ./user/user.sh
fi

./lang/timezone.sh
./lang/locale.sh
./lang/xorg.sh
./instantos/install.sh

echo "finished installing instantOS"
imenu -c "a reboot is required. reboot now?" && touch /tmp/instantosreboot
rm /tmp/climenu
