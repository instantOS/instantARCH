#!/bin/bash

mkdir /root/instantARCH/config
mkdir config

source <(curl -Ls git.io/paperbash)
pb dialog

if [ -e /usr/share/liveutils ]; then
    echo "GUI Mode active"
    export GUIMODE="True"
    GUIMODE="True"
fi

# check if the install session is GUI or cli
guimode() {
    if [ -n "$GUIMODE" ]; then
        return 0
    else
        return 1
    fi
}

if guimode; then
    echo "> Welcome to the instantOS installation
Continue" | instantmenu -w 600 -l 20 -c
else
    messagebox "Welcome to the instantOS installer"
fi

# go back to the beginning if user isn't happy with settings
while ! [ -e /root/instantARCH/config/confirm ]; do
    cd /root/instantARCH/data/lang/keyboard
    while [ -z "$NEWKEY" ]; do
        if guimode; then
            NEWKEY="$(ls | instantmenu -p 'Select keyboard layout')"
        else
            NEWKEY="$(ls | fzf --prompt 'Select keyboard layout> ')"
        fi
    done

    echo "$NEWKEY" >/root/instantARCH/config/keyboard

    loadkeys $(tail -1 /root/instantARCH/data/lang/keyboard/"$NEWKEY")

    cd ../locale
    while [ -z "$NEWLOCALE" ]; do
        NEWLOCALE="$(ls | fzf --prompt 'Select language> ')"
    done
    echo "$NEWLOCALE" >/root/instantARCH/config/locale

    cd /usr/share/zoneinfo

    while [ -z "$REGION" ]; do
        REGION=$(ls | fzf --prompt "select region> ")
    done

    if [ -d "$REGION" ]; then
        cd "$REGION"
        while [ -z "$CITY" ]; do
            CITY=$(ls | fzf --prompt "select the City nearest to you> ")
        done
    fi

    echo "$REGION" >/root/instantARCH/config/region
    [ -n "$CITY" ] && echo "$CITY" >/root/instantARCH/config/city

    while [ -z "$DISK" ]; do
        DISK=$(fdisk -l | grep -i '^Disk /.*:' | fzf --prompt "select disk> ")
        if ! confirm "Install on $DISK ?\n this will delete all existing data"; then
            unset DISK
        fi
    done

    echo "$DISK" | grep -o '/dev/[^:]*' >/root/instantARCH/config/disk

    NEWUSER="$(textbox 'set username')"

    while ! [ "$NEWPASS" = "$NEWPASS2" ] || [ -z "$NEWPASS" ]; do
        NEWPASS="$(passwordbox 'set password')"
        NEWPASS2="$(passwordbox 'confirm password')"
    done

    echo "$NEWUSER" >/root/instantARCH/config/user
    echo "$NEWPASS" >/root/instantARCH/config/password

    while [ -z "$NEWHOSTNAME" ]; do
        NEWHOSTNAME=$(textbox "enter name of this computer")
    done

    echo "$NEWHOSTNAME" >/root/instantARCH/config/hostname

    SUMMARY="Installation Summary:"

    addsum() {
        SUMMARY="$SUMMARY
        $1: $(cat /root/instantARCH/config/$2)"
    }

    addsum "Username" "user"
    addsum "Locale" "locale"
    addsum "Region" "region"
    addsum "Nearest City" "city"
    addsum "Keyboard layout" "keyboard"
    addsum "Target install drive" "disk"
    addsum "Hostname" "hostname"
    if efibootmgr; then
        addsum "GRUB: UEFI"
    else
        addsum "GRUB: BIOS"
    fi

    SUMMARY="$SUMMARY
Should installation proceed with these parameters?"

    if confirm "$SUMMARY"; then
        touch /root/instantARCH/config/confirm
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

messagebox "The installation will now begin. this could take a while. "
clear
