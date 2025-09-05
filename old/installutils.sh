#!/bin/bash

# functions used for the actual installation

# reset working dir
rcd() {
    cd /root/instantARCH
}

# this gets executed if a module fails
# it marks the installation as failed
serror() {
    # touching noerror skips error checking for one check
    if [ -e /opt/noerror ]; then
        echo "skipping error"
        rm /opt/noerror
    else
        # indicator file
        touch /opt/installfailed
        echo "script failed"
        exit 1
    fi
}

# this sets the status message
# displayed at the bottom of the screen when using the GUI installer
setinfo() {
    if [ -e /usr/share/liveutils ]; then
        pkill instantmenu
    fi
    echo "$@" >/opt/instantprogress
    echo "$@"
}

testecho() {
    if [ -n "$INSTANTARCHTESTING" ]; then
        echo "test-message:" "$@"
        notify-send "$@"
    fi
}

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

# run a script inside the installation medium
escript() {
    STARTDURATION="$SECONDS"
    setinfo "${2:-info}"
    rcd
    testecho "running native script $1"
    ./"$1".sh || serror
    echo "$1" >>/tmp/instantprogress
    debugmenu "$1"
}

# scripts executed in installed environment
chrootscript() {
    STARTDURATION="$SECONDS"
    setinfo "${2:-info}"
    # check if chroot environment is working
    if ! mount | grep -q '/mnt'; then
        echo "mount failed"
        exit 1
    fi

    rcd

    testecho "running chroot script $1"

    if command -v arch-chroot; then
        arch-chroot /mnt "/root/instantARCH/${1}.sh" || serror
    elif command -v manjaro-chroot; then
        manjaro-chroot /mnt "/root/instantARCH/${1}.sh" || serror
    else
        artix-chroot /mnt "/root/instantARCH/${1}.sh" || serror
    fi

    echo "chroot: $1" >>/tmp/instantprogress

    debugmenu "$1"
}

# allows pausing the installer after each step
debugmenu() {
    {
        [ -n "$INSTALLDEBUG" ] || [ -e /tmp/installdebug ]
    } || return 0
    DURATION="$((SECONDS - STARTDURATION))"
    DEBUGCHOICE="$(
        {
            echo "> ran task $1"
            echo "> took $DURATION seconds"
            echo ":ypause"
            echo ":rcancel"
            echo ":gcontinue"
        } | imenu -l "debug menu"
    )"
    case "$DEBUGCHOICE" in
    *pause)
        echo 'pausing installation'
        touch /tmp/installpause
        echo 'installation paused, waiting for removal of /tmp/installpause'
        while [ -e /tmp/installpause ]; do
            sleep 10
        done
        ;;
    *cancel)
        echo 'quitting installation'
        echo 'TODO: implement'
        ;;
    *continue)
        echo "continuing installation"
        ;;
    esac
    STARTDURATION=0

}
