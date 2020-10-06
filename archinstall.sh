#!/bin/bash

###################################################
## This is the official installer for instantOS  ##
###################################################

if ! whoami | grep -iq '^root'; then
    echo "not running as root, switching"
    curl -Lg git.io/instantarch | sudo bash
    exit
fi

if [ -e /usr/share/liveutils ]; then
    pgrep instantmenu || echo "preparing installation
OK" | instantmenu -c -bw 4 -l 2 &
else
    # print logo
    echo ""
    echo ""
    curl -s 'https://raw.githubusercontent.com/instantOS/instantLOGO/master/ascii.txt' | sed 's/^/    /g'
    echo ""
    echo ""
fi

# prevent multiple instances from being launched
if [ -e /tmp/instantarchpid ]; then
    echo "pidfile found"
    if kill -0 "$(cat /tmp/instantarchpid)"; then
        notify-send "installer already running, please do not start multiple instances"
    fi
else
    echo "$$" >/tmp/instantarchpid
fi

if ! command -v imenu; then
    touch /tmp/removeimenu
fi

# updated mirrorlist
echo "updating mirrorlist"
curl -s https://raw.githubusercontent.com/instantOS/instantOS/master/repo.sh | bash

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

if command -v python; then
    echo "import time; time.sleep(10009)" | python &
    sleep 2
    pkill python3
fi

while [ -z "$CONTINUEINSTALLATION" ]; do
    if ! pacman -Sy --noconfirm || ! pacman -S git --noconfirm --needed; then
        yes | pacman -Scc
        pacman -Sy --noconfirm
    else
        export CONTINUEINSTALLATION="true"
    fi
done

cd /root || exit 1
[ -e instantARCH ] && rm -rf instantARCH

if [ "$1" = "test" ]; then
    echo "switching to testing branch"
    git clone --single-branch --branch testing --depth=1 https://github.com/instantos/instantARCH.git
    export INSTANTARCHTESTING="true"
else
    git clone --depth=1 https://github.com/instantos/instantARCH.git
fi

cd instantARCH || exit 1

# use alternative versions of the installer
if [ -n "$1" ]; then
    case "$1" in
    "manual")
        if ! [ -e /root/manualarch ]; then
            echo "no manual instantARCH version found. Please clone it to /root/manualarch"
            sleep 5
            echo "exiting"
            exit
        fi
        rm -rf ./*
        cp -r /root/manualarch/* .
        export INSTANTARCHMANUAL="true"
        ;;
    *)
        echo "running normal installer version"
        ;;
    esac

fi

chmod +x ./*.sh
chmod +x ./*/*.sh

./depend/depend.sh
./artix/preinstall.sh

if [ -n "$INSTANTARCHTESTING" ]; then
    echo "install config"
    iroot installtest 1
fi

[ -e /usr/share/liveutils ] && pkill instantmenu

cd /root/instantARCH || exit

./ask.sh || {
    if ! [ -e /opt/instantos/installcanceled ]; then
        imenu -m "ask failed"
        echo "ask failed" && exit
    else
        rm /opt/instantos/installcanceled
        pkill instantosinstall
        exit
    fi
}

chmod +x ./*.sh
chmod +x ./**/*.sh

echo "local install"
./localinstall.sh 2>&1 | tee /opt/localinstall &&
    echo "system install" &&
    ./systeminstall.sh 2>&1 | tee /opt/systeminstall

pkill imenu
pkill instantmenu
sudo pkill imenu
sudo pkill instantmenu
sleep 2

uploadlogs() {
    echo "uploading installation log"
    cat /opt/localinstall >/opt/install.log

    if [ -e /opt/systeminstall ]; then
        cat /opt/systeminstall >>/opt/install.log
    fi

    cd /opt || exit
    cp /root/instantARCH/data/netrc ~/.netrc
    curl -n -F 'f:1=@install.log' ix.io
    dialog --msgbox "installation failed
please go to https://instantos.github.io/instantos.github.io/support
for assistance or error reporting" 1000 1000

}

# ask to reboot, upload error data if install failed
if ! [ -e /opt/installfailed ] || ! [ -e /opt/installsuccess ]; then
    if command -v installapplet; then
        notify-send "rebooting"
        sleep 2
        if iroot logging; then
            uploadlogs
            sleep 2
        fi
        reboot
    fi
else
    echo "installaion failed"
    echo "uploading error data"
    uploadlogs
fi

if [ -e /tmp/removeimenu ]; then
    rm /usr/bin/imenu
fi

echo "installation finished"
