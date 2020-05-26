#!/bin/bash

###################################################
## This is the official installer for instantOS  ##
## instantOS is migrating from calamares to this ##
###################################################

# main script calling others

# DO NOT USE ON ACTUAL HARDWARE YET

if ! whoami | grep -iq '^root'; then
    echo "not running as root, switching"
    curl -Lg git.io/instantarch | sudo bash
    exit
fi

if [ -e /usr/share/liveutils ]; then
    imenu -m "preparing installation" &
else
    # print logo
    echo ""
    echo ""
    curl -s 'https://raw.githubusercontent.com/instantOS/instantLOGO/master/ascii.txt' | sed 's/^/    /g'
    echo ""
    echo ""
fi

if ! command -v imenu; then
    touch /tmp/removeimenu
fi

# download imenu
curl -s https://raw.githubusercontent.com/instantOS/imenu/master/imenu.sh >/usr/bin/imenu
chmod 755 /usr/bin/imenu

while ! command -v imenu; do
    echo "installing imenu"
    curl -s https://raw.githubusercontent.com/instantOS/imenu/master/imenu.sh >/usr/bin/imenu
    chmod 755 /usr/bin/imenu
done

setinfo() {
    if [ -e /usr/share/liveutils ]; then
        pkill instantmenu
    fi
    echo "$@" >/opt/instantprogress
}

# sort mirrors
pacman -Sy --noconfirm
if command -v pacstrap; then
    pacman -S reflector --noconfirm
    echo "selecting fastest mirror"
    reflector --latest 40 --protocol http --protocol https --sort rate --save /etc/pacman.d/mirrorlist
fi

# install dependencies
pacman -Sy --noconfirm
pacman -S git --noconfirm --needed

cd /root
[ -e instantARCH ] && rm -rf instantARCH
git clone --depth=1 https://github.com/instantos/instantARCH.git
cd instantARCH

./depend/depend.sh
cd /root/instantARCH
./ask.sh || exit

chmod +x *.sh
chmod +x **/*.sh
echo "local install"
./localinstall.sh
echo "in-system install"
./systeminstall.sh

if [ -e /tmp/removeimenu ]; then
    rm /usr/bin/imenu
fi

echo "installation finished"
