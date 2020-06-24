#!/bin/bash

# symlink timezone from user selected region

cd /usr/share/zoneinfo

REGION=$(iroot region)

if iroot city; then
    CITY=$(iroot city)
fi

if [ -n "$CITY" ]; then
    ln -sf /usr/share/zoneinfo/$REGION/$CITY /etc/localtime
    timedatectl set-timezone "$REGION/$CITY"
    echo "setting timezone to $REGION/$CITY"

else
    ln -sf /usr/share/zoneinfo/$REGION /etc/localtime
    timedatectl set-timezone "$REGION"
    echo "setting timezone to $REGION"
fi

hwclock --systohc
