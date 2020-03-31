#!/bin/bash
cd /usr/share/zoneinfo

REGION=$(cat /root/instantARCH/config/region)

if [ -e /root/instantARCH/config/city ]; then
    CITY=$(cat /root/instantARCH/config/city)
fi

if [ -n "$CITY" ]; then
    ln -sf /usr/share/zoneinfo/$REGION/$CITY /etc/localtime
    echo "setting timezone to $REGION/$CITY"
else
    ln -sf /usr/share/zoneinfo/$REGION /etc/localtime
    echo "setting timezone to $REGION"
fi

hwclock --systohc
