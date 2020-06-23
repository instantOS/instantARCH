#!/bin/bash

###################################################
## This is the official installer for instantOS  ##
## instantOS is migrating from calamares to this ##
###################################################

# main script calling others

if ! whoami | grep -iq '^root'; then
    echo "not running as root, switching"
    curl -Lg git.io/instantarch | sudo bash
    exit
fi

if [ -e /usr/share/liveutils ]; then
    echo "preparing isntallation
OK" | instantmenu -c -bw 4 -l 2 &
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
    echo "$@"
}

# sort mirrors
pacman -Sy --noconfirm
pacman -S git --noconfirm --needed

cd /root
[ -e instantARCH ] && rm -rf instantARCH
git clone --depth=1 https://github.com/instantos/instantARCH.git
cd instantARCH
chmod +x *.sh
chmod +x */*.sh

./depend/depend.sh
cd /root/instantARCH

./ask.sh || {
    imenu -m "ask failed"
    echo "ask failed" && exit
}

chmod +x *.sh
chmod +x **/*.sh

echo "local install"
./localinstall.sh 2>&1 | tee /opt/localinstall &&
    echo "system install" &&
    ./systeminstall.sh 2>&1 | tee /opt/systeminstall

pkill imenu
pkill instantmenu
sudo pkill imenu
sudo pkill instantmenu
sleep 2

# ask to reboot, upload error data if install failed
if ! [ -e /opt/installfailed ] || ! [ -e /opt/installsuccess ]; then
    if command -v zenity; then
        zenity --question --text="installation finished. reboot?" && touch /tmp/instantosreboot
    fi
else
    echo "installaion failed"
    echo "uploading error data"

    cat /opt/localinstall >/opt/install.log

    if [ -e /opt/systeminstall ]; then
        cat /opt/systeminstall >>/opt/install.log
    fi

    cd /opt
    cp /root/instantARCH/data/netrc ~/.netrc
    curl -n -F 'f:1=@install.log' ix.io
    dialog --msgbox "installation failed
please go to https://instantos.github.io/instantos.github.io/support
for assistance or error reporting" 1000 1000

fi

if [ -e /tmp/removeimenu ]; then
    rm /usr/bin/imenu
fi

echo "installation finished"

[ -e /tmp/instantosreboot ] && reboot
