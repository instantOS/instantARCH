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
    if [ -e /opt/noguimode ]; then
        return 1
    fi

    if [ -n "$GUIMODE" ]; then
        return 0
    else
        return 1
    fi
}

# switch imenu to fzf and dialog
if ! guimode; then
    touch /tmp/climenu
fi

imenu -m "Welcome to the instantOS installer"

# go back to the beginning if user isn't happy with settings
while ! [ -e /root/instantARCH/config/confirm ]; do
    cd /root/instantARCH/data/lang/keyboard
    while [ -z "$NEWKEY" ]; do

        guimode && feh --bg-scale /usr/share/liveutils/worldmap.jpg &
        NEWKEY="$(ls | imenu -l 'Select keyboard layout ')"

        # allow directly typing in layout name
        if [ "$NEWKEY" = "other" ]; then
            OTHERKEY="$(localectl list-x11-keymap-layouts | imenu -l 'select keyboard layout ')"

            if [ -z "$OTHERKEY" ]; then
                unset NEWKEY
            else
                echo "
$OTHERKEY" >/root/instantARCH/data/lang/keyboard/other
            fi
        fi

    done

    # option to cancel the installer
    if [ "${NEWKEY}" = "forcequit" ]; then
        exit 1
    fi

    echo "$NEWKEY" >/root/instantARCH/config/keyboard

    if head -1 /root/instantARCH/data/lang/keyboard/"$NEWKEY" | grep -q '[^ ][^ ]'; then
        loadkeys $(head -1 /root/instantARCH/data/lang/keyboard/"$NEWKEY")
    fi

    guimode && setxkbmap -layout $(tail -1 /root/instantARCH/data/lang/keyboard/"$NEWKEY")

    cd ../locale
    while [ -z "$NEWLOCALE" ]; do
        NEWLOCALE="$(ls | imenu -l 'Select language> ')"
    done

    echo "$NEWLOCALE" >/root/instantARCH/config/locale

    cd /usr/share/zoneinfo

    while [ -z "$REGION" ]; do
        REGION=$(ls | imenu -l "select region ")
    done

    if [ -d "$REGION" ]; then
        cd "$REGION"
        while [ -z "$CITY" ]; do
            CITY=$(ls | imenu -l "select the City nearest to you ")
        done
    fi

    echo "$REGION" >/root/instantARCH/config/region
    [ -n "$CITY" ] && echo "$CITY" >/root/instantARCH/config/city

    while [ -z "$DISK" ]; do
        guimode && feh --bg-scale /usr/share/liveutils/install.jpg &
        DISK=$(fdisk -l | grep -i '^Disk /.*:' | imenu -l "select disk> ")
        if ! echo "Install on $DISK ?
this will delete all existing data" | imenu -C; then
            unset DISK
        fi
    done

    echo "$DISK" | grep -o '/dev/[^:]*' >/root/instantARCH/config/disk

    # select drivers
    if lspci | grep -iq 'nvidia'; then
        echo "nvidia card detected"
        while [ -z "$DRIVERCHOICE" ]; do
            DRIVERCHOICE="$(echo 'nvidia proprietary (recommended)
nvidia-dkms (try if proprietary does not work)
nouveau open source
install without graphics drivers (not recommended)' | imenu -l 'select graphics drivers')"

            if grep -q "without" <<<"$DRIVERCHOICE"; then
                if ! echo "are you sure you do not want to install graphics drivers?
This could prevent the system from booting" | imenu -C; then
                    unset DRIVERCHOICE
                fi
            fi

        done

        if grep -qi "dkms" <<<"$DRIVERCHOICE"; then
            echo "dkms" >/root/instantARCH/config/graphics
        elif grep -qi "nvidia" <<<"$DRIVERCHOICE"; then
            echo "nvidia" >/root/instantARCH/config/graphics
        elif grep -qi "open" <<<"$DRIVERCHOICE"; then
            echo "open" >/root/instantARCH/config/graphics
        elif [ -z "$DRIVERCHOICE" ]; then
            echo "nodriver" >/root/instantARCH/config/graphics
        fi

    else
        echo "no nvidia card detected"
    fi

    while [ -z $NEWUSER ]; do
        guimode && feh --bg-scale /usr/share/liveutils/user.jpg &
        NEWUSER="$(imenu -i 'set username')"

        # validate input as a unix name
        if ! grep -Eq '^[a-z_]([a-z0-9_-]{0,31}|[a-z0-9_-]{0,30}\$)$' <<<"$NEWUSER"; then
            imenu -m "invalid username"
            unset NEWUSER
        fi
    done

    while ! [ "$NEWPASS" = "$NEWPASS2" ] || [ -z "$NEWPASS" ]; do
        NEWPASS="$(imenu -P 'set password')"
        NEWPASS2="$(imenu -P 'confirm password')"
    done

    echo "$NEWUSER" >/root/instantARCH/config/user
    echo "$NEWPASS" >/root/instantARCH/config/password

    while [ -z "$NEWHOSTNAME" ]; do
        NEWHOSTNAME=$(imenu -i "enter name of this computer")
    done

    echo "$NEWHOSTNAME" >/root/instantARCH/config/hostname

    guimode && feh --bg-scale /usr/share/liveutils/install.jpg &
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
        SUMMARY="$SUMMARY
GRUB: UEFI"
    else
        SUMMARY="$SUMMARY
GRUB: BIOS"
    fi

    SUMMARY="$SUMMARY
Should installation proceed with these parameters?"

    if guimode; then
        if imenu -C <<<"$SUMMARY"; then
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
    else
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
    fi
done


imenu -M <<<"The installation will now begin.
This could take a while.
Keep the machine powered and connected to the internet" &
clear
