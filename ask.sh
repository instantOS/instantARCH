#!/bin/bash

# This is the interactive part of the installer
# Everything requiring user input is asked first,
# NO INSTALLATION IS DONE IN THIS SCRIPT
# Results get saved in /root/instantARCH/config
# and read out during installation
# results also get copied to the target root partition

mkdir /root/instantARCH/config
mkdir config

source <(curl -Ls git.io/paperbash)
pb dialog

source /root/instantARCH/askutils.sh

if [ -e /usr/share/liveutils ]; then
    echo "GUI Mode active"
    export GUIMODE="True"
    GUIMODE="True"
fi

# switch imenu to fzf and dialog
if ! guimode; then
    touch /tmp/climenu
fi

imenu -m "Welcome to the instantOS installer"

# go back to the beginning if user isn't happy with settings
# this loop wraps the rest of the installer
while ! iroot confirm; do

    # ask for keyboard layout
    asklayout
    if head -1 /root/instantARCH/data/lang/keyboard/"$NEWKEY" | grep -q '[^ ][^ ]'; then
        loadkeys $(head -1 /root/instantARCH/data/lang/keyboard/"$NEWKEY")
    fi
    guimode && setxkbmap -layout $(tail -1 /root/instantARCH/data/lang/keyboard/"$NEWKEY")

    asklocale
    askmirrors
    askvm
    askregion

    while [ -z "$DISK" ]; do
        wallstatus install
        DISK=$(fdisk -l | grep -i '^Disk /.*:' | sed -e "\$aother (experimental)" | imenu -l "select disk> ")
        if ! grep -q '^other' <<<"$DISK"; then
            if ! echo "Install on $DISK ?
this will delete all existing data" | imenu -C; then
                unset DISK
            fi
        else
            chmod +x /root/instantARCH/askdisk.sh
            /root/instantARCH/askdisk.sh
        fi
    done

    if ! grep -q '^other' <<<"$DISK"; then

        echo "$DISK" | grep -o '/dev/[^:]*' | iroot i disk

        if ! efibootmgr; then
            echo "$DISK" | grep -o '/dev/[^:]*' | iroot i grubdisk
        fi
    fi

    # choice between multiple nvidia drivers
    askdrivers

    # create user and add to groups
    askuser

    while [ -z "$NEWHOSTNAME" ]; do
        NEWHOSTNAME=$(imenu -i "enter name of this computer")
    done

    iroot hostname "$NEWHOSTNAME"

    wallstatus install
    SUMMARY="Installation Summary:"

    addsum "Username" "user"
    addsum "Locale" "locale"
    addsum "Region" "region"
    addsum "Nearest City" "city"
    addsum "Keyboard layout" "keyboard"
    addsum "Target install drive" "disk"
    addsum "Hostname" "hostname"

    if efibootmgr; then
        SUMMARY="$SUMMARY
GRUB: UEFI"
    else
        SUMMARY="$SUMMARY
GRUB: BIOS"
    fi

    SUMMARY="$SUMMARY
Should installation proceed with these parameters?"

    if imenu -C <<<"$SUMMARY"; then
        iroot confirm 1
    else
        unset CITY
        unset REGION
        unset DISK
        unset NEWKEY
        unset NEWLOCALE
        unset NEWPASS2
        unset NEWPASS
        unset NEWHOSTNAME
        unset NEWUSER
    fi

done

imenu -M <<<"The installation will now begin.
This could take a while.
Keep the machine powered and connected to the internet"
