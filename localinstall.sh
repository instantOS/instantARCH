#!/bin/bash

rcd() {
    cd /root/instantARCH
}

# $ gets displayed at the bottom of the screen
# during installation

setinfo() {
    if [ -e /usr/share/liveutils ]; then
        pkill instantmenu
    fi
    echo "$@" >/opt/instantprogress
    echo "$@"
}

# run script in installation medium
escript() {
    setinfo "$2"
    rcd
    ./$1.sh
    echo "$1" >>/tmp/instantprogress
}

escript init/init "configuring time"
escript disk/disk "partitioning disk"
escript pacstrap/pacstrap "installing base packages"
sleep 1
