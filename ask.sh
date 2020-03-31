#!/bin/bash

mkdir root/instantARCH/config

source <(curl -Ls git.io/paperbash)
pb dialog

cd /root/instantARCH/data/lang/keyboard
while [ -z "$NEWKEY" ]; do
    NEWKEY="$(ls | fzf --prompt 'Select keyboard layout')"
done

echo "$NEWKEY" >/root/instantARCH/config/keyboard

loadkeys $(tail -1 /root/instantARCH/data/lang/keyboard/"$NEWKEY")

cd ../locale
while [ -z "$NEWLOCALE" ]; do
    NEWLOCALE="$(ls | fzf --prompt 'Select language')"
done
echo "$NEWLOCALE" >/root/instantARCH/config/locale

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

echo "$REGION" >/root/instantARCH/config/region
[ -n "$CITY" ] echo "$CITY" >/root/instantARCH/config/city

while [ -z "$DISK" ]; do
    DISK=$(fdisk -l | grep -i '^Disk /.*:' | fzf --prompt "select disk")
    if ! confirm "Install on $DISK ? this will delete all data on"; then
        unset DISK
    fi
done

echo "$DISK" >/root/instantARCH/config/disk

while [ -z "$NEWHOSTNAME" ]; do
    NEWHOSTNAME=$(textbox "enter hostname")
done

echo "$NEWHOSTNAME" >/root/instantARCH/config/hostname

NEWUSER="$(textbox 'set username')"

while ! [ "$NEWPASS" = "$NEWPASS2" ] || [ -z "$NEWPASS" ]; do
    NEWPASS="$(passwordbox 'set password')"
    NEWPASS2="$(passwordbox 'confirm password')"
done

echo "$NEWUSER" >/root/instantARCH/config/user
echo "$NEWPASS" >/root/instantARCH/config/password
