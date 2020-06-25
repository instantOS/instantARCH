#!/bin/bash

# symlink timezone from user selected region

cd /usr/share/zoneinfo

REGION=$(iroot region)

if iroot city; then
    CITY=$(iroot city)
fi

if [ -n "$CITY" ]; then
    ln -sf /usr/share/zoneinfo/$REGION/$CITY /etc/localtime
    if command -v timedatectl; then
        timedatectl set-timezone "$REGION/$CITY"
    fi
    echo "setting timezone to $REGION/$CITY"
else
    ln -sf /usr/share/zoneinfo/$REGION /etc/localtime
    if command -v timedatectl; then
        timedatectl set-timezone "$REGION"
    fi
    echo "setting timezone to $REGION"
fi

hwclock --systohc
