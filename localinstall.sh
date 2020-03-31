#!/bin/bash

rcd() {
    cd /root/instantARCH
}

escript() {
    rcd
    ./$1.sh
    echo "$1" >>/tmp/instantprogress
}

escript init/init
escript disk/disk
escript pacstrap/pacstrap
sleep 1
