#!/bin/bash
cd /usr/share/zoneinfo

while [ -z "$REGION" ]; do
    REGION=$(ls | fzf --prompt "select region")
done

if [ -d "$REGION" ]; then
    cd "$REGION"
    while [ -z "$CITY" ]; do
        CITY=$(ls | fzf --prompt "select the City nearest to you")
    done
fi

if [ -n "$CITY" ]; then
    ln -sf /usr/share/zoneinfo/$REGION/$CITY /etc/localtime
    echo "setting timezone to $REGION/$CITY"
else
    ln -sf /usr/share/zoneinfo/$REGION /etc/localtime
    echo "setting timezone to $REGION"
fi

hwclock --systohc
