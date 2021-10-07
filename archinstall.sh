#!/bin/bash

##############################################
## The official installer for instantOS     ##
##############################################

# Main startup script

source /root/instantARCH/moduleutils.sh

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
    curl -s 'https://raw.githubusercontent.com/instantOS/instantLOGO/main/ascii.txt' | sed 's/^/    /g'
    echo ""
    echo ""
fi

# prevent multiple instances from being launched
if [ -e /tmp/instantarchpid ]; then
    echo "pidfile found"
    if kill -0 "$(cat /tmp/instantarchpid)"; then
        notify-send "installer already running, please do not start multiple instances"
        exit 1
    fi
else
    echo "$$" >/tmp/instantarchpid
fi

if ! command -v imenu; then
    touch /tmp/removeimenu
fi

command -v tzupdate && ! pgrep tzupdate && sudo tzupdate &

# updated mirrorlist
echo "updating mirrorlist"
curl -s https://raw.githubusercontent.com/instantOS/instantOS/main/repo.sh | bash

# download imenu
curl -s https://raw.githubusercontent.com/instantOS/imenu/main/imenu.sh >/usr/bin/imenu
chmod 755 /usr/bin/imenu

while ! command -v imenu; do
    echo "installing imenu"
    curl -s https://raw.githubusercontent.com/instantOS/imenu/main/imenu.sh >/usr/bin/imenu
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

if ! command -v git; then
    while [ -z "$CONTINUEINSTALLATION" ]; do
        if ! updaterepos || ! pacman -S git --noconfirm --needed; then
            yes | pacman -Scc
            updaterepos
        else
            export CONTINUEINSTALLATION="true"
        fi
    done
fi

# ensure git is working
if ! git --version; then
    if git --version 2>&1 | grep -i glibc; then
        echo "upgrading glibc"
        pacman -Sy glibc --noconfirm || exit 1
    fi
    if ! git --version; then
        echo "git is not working on your system."
        echo "installing instantOS requires git to be installed and working"
        exit 1
    fi
fi

cd /root || exit 1

if [ -e instantARCH ]; then
    echo "removing previous instantARCH data"
    rm -rf instantARCH
fi

if [ "$1" = "test" ]; then
    echo "switching to testing branch"
    export TESTBRANCH="${2:-testing}"

    if [ -n "$3" ]; then
        export CUSTOMINSTANTREPO="$3"
    fi

    echo "using installer branch $TESTBRANCH"
    git clone --single-branch --branch "$TESTBRANCH" --depth=1 https://github.com/instantos/instantARCH.git
    export INSTANTARCHTESTING="true"
else
    git clone --depth=1 https://github.com/instantos/instantARCH.git
fi

cd instantARCH || exit 1

mkdir config &>/dev/null
git rev-parse HEAD >config/instantarchversion

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

isdebug() {
    if {
        [ -n "$INSTALLDEBUG" ] || [ -e /tmp/installdebug ]
    }; then
        echo 'debugging mode is enabled'
        return 0
    else
        return 1
    fi
}

if isdebug; then
    echo 'debugging mode enabled'
    if [ -e /tmp/debugname ]; then
        echo "debugging name: $(cat /tmp/installdebug)"

    fi
fi

./depend/depend.sh
./artix/preinstall.sh

if [ -n "$INSTANTARCHTESTING" ]; then
    echo "install config"
    iroot installtest 1
fi

[ -e /usr/share/liveutils ] && pkill instantmenu

cd /root/instantARCH || exit

./ask.sh || {
    if ! [ -e /opt/instantos/installcanceled ] && ! iroot cancelinstall; then
        imenu -m "ask failed"
        echo "ask failed" && exit
    else
        rm /opt/instantos/installcanceled
        instantwallpaper set /usr/share/instantwallpaper/defaultphoto.png
        # clear up installation data

        rm -rf /root/instantARCH
        pkill instantosinstall
        sleep 1
        pkill -f instantosinstall

        pkill instantosinstaller
        sleep 1
        pkill -f instantosinstaller
        exit
    fi
}

if ! iroot confirm; then
    echo "no confirmation found, installation cancelled"
    exit
fi

unset IMENUACCEPTEMPTY

chmod +x ./*.sh
chmod +x ./**/*.sh

# pacstrap base system
echo "local install"
./localinstall.sh 2>&1 | tee /opt/localinstall &&
    echo "system install" &&
    ./systeminstall.sh 2>&1 | tee /opt/systeminstall # install rest of the system

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

}

if isdebug && [ -e /tmp/debugname ]; then
    echo "debug name: $(cat /tmp/debugname)"
fi

# ask to reboot, upload error data if install failed
if [ -z "$INSTANTARCHTESTING" ] && ! isdebug; then
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
        dialog --msgbox "installation failed
please go to https://instantos.github.io/instantos.github.io/support
for assistance or error reporting" 1000 1000
        echo "uploading error data"
        echo "installaion failed"
        uploadlogs
    fi
else
    uploadlogs
fi

if [ -e /tmp/removeimenu ]; then
    rm /usr/bin/imenu
fi

echo "installation finished"

echo ""
echo ""
curl -s 'https://raw.githubusercontent.com/instantOS/instantLOGO/main/ascii.txt' | sed 's/^/    /g'
echo ""
echo ""

echo "the system can now be safely rebooted"
