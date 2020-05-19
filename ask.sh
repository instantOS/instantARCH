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

if guimode; then
    pgrep instantmenu && pkill instantmenu
    imenu -m "Welcome to the instantOS installer"
else
    messagebox "Welcome to the instantOS installer"
fi

# go back to the beginning if user isn't happy with settings
while ! [ -e /root/instantARCH/config/confirm ]; do
    cd /root/instantARCH/data/lang/keyboard
    while [ -z "$NEWKEY" ]; do
        if guimode; then
            feh --bg-scale /usr/share/liveutils/worldmap.jpg &
            NEWKEY="$(ls | imenu -l 'Select keyboard layout')"
        else
            NEWKEY="$(ls | fzf --prompt 'Select keyboard layout> ')"
        fi

        # allow directly typing in layout name
        if [ "$NEWKEY" = "other" ]; then
            if guimode; then
                OTHERKEY="$(localectl list-x11-keymap-layouts | instantmenu -l 20 -c -p 'select keyboard layout')"
            else
                OTHERKEY="$(localectl list-x11-keymap-layouts | fzf --prompt 'select keyboard layout')"
            fi

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

    if head -1 /root/instantARCH/data/lang/keyboard/"$NEWKEY" | greo -q '[^ ][^ ]'; then
        loadkeys $(head -1 /root/instantARCH/data/lang/keyboard/"$NEWKEY")
    fi

    guimode && setxkbmap -layout $(tail -1 /root/instantARCH/data/lang/keyboard/"$NEWKEY")

    cd ../locale
    while [ -z "$NEWLOCALE" ]; do
        if guimode; then
            NEWLOCALE="$(ls | imenu -l 'Select language> ')"
        else
            NEWLOCALE="$(ls | fzf --prompt 'Select language> ')"
        fi
    done

    echo "$NEWLOCALE" >/root/instantARCH/config/locale

    cd /usr/share/zoneinfo

    while [ -z "$REGION" ]; do
        if guimode; then
            REGION=$(ls | imenu -l "select region")
        else
            REGION=$(ls | fzf --prompt "select region> ")
        fi
    done

    if [ -d "$REGION" ]; then
        cd "$REGION"
        while [ -z "$CITY" ]; do
            if guimode; then
                CITY=$(ls | imenu -l "select the City nearest to you")
            else
                CITY=$(ls | fzf --prompt "select the City nearest to you> ")
            fi
        done
    fi

    echo "$REGION" >/root/instantARCH/config/region
    [ -n "$CITY" ] && echo "$CITY" >/root/instantARCH/config/city

    while [ -z "$DISK" ]; do
        if guimode; then
            feh --bg-scale /usr/share/liveutils/install.jpg &
            DISK=$(fdisk -l | grep -i '^Disk /.*:' | imenu -l "select disk> ")
            if ! echo "Install on $DISK ?
this will delete all existing data" | imenu -C; then
                unset DISK
            fi
        else
            DISK=$(fdisk -l | grep -i '^Disk /.*:' | fzf --prompt "select disk> ")
            if ! confirm "Install on $DISK ?\n this will delete all existing data"; then
                unset DISK
            fi
        fi
    done

    echo "$DISK" | grep -o '/dev/[^:]*' >/root/instantARCH/config/disk

    # select drivers
    if lspci | grep -iq 'nvidia'; then
        echo "nvidia card detected"
        while [ -z "$DRIVERCHOICE" ]; do
            if guimode; then
                DRIVERCHOICE="$(echo 'nvidia proprietary (recommended)
nouveau open source
install without graphics drivers (not recommended)' | imenu -l 'select graphics drivers')"

                if grep -q "without" <<<"$DRIVERCHOICE"; then
                    if ! echo "are you sure you do not want to install graphics drivers?
This could prevent the system from booting" | imenu -C; then
                        unset DRIVERCHOICE
                    fi
                fi
            else

                while [ -z "$DRIVERCHOICE" ]; do
                    while [ -z "$DRIVERCHOICE" ]; do
                        if (lspci | grep -i 'nvidia' | grep -iq 'nvidia.*\[.*7[5678]0.*\]'); then
                            DRIVERCHOICE="$(echo 'nouveau open source
install without graphics (not recommended)' | fzf --prompt 'select graphics drivers')"
                        else
                            DRIVERCHOICE="$(echo 'nvidia proprietary (recommended)
nvidia-dkms (try if proprietary doesn't work)
nouveau open source
install without graphics (not recommended)' | fzf --prompt 'select graphics drivers')"
                        fi
                    done

                    if grep -q "without" <<<"$DRIVERCHOICE"; then
                        if ! confirm "are you sure you do not want to install graphics drivers?
This could prevent the system from booting"; then
                            unset DRIVERCHOICE
                        fi
                    fi
                done

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
        if guimode; then
            feh --bg-scale /usr/share/liveutils/user.jpg &
            NEWUSER="$(imenu -i 'set username')"
        else
            NEWUSER="$(textbox 'set username')"
        fi

        # validate input as a unix name
        if ! grep -Eq '^[a-z_]([a-z0-9_-]{0,31}|[a-z0-9_-]{0,30}\$)$' <<<"$NEWUSER"; then
            if guimode; then
                imenu -m "invalid username"
            else
                msgbox "invalid username"
            fi
            unset NEWUSER
        fi
    done

    while ! [ "$NEWPASS" = "$NEWPASS2" ] || [ -z "$NEWPASS" ]; do
        if guimode; then
            NEWPASS="$(imenu -P 'set password')"
            NEWPASS2="$(imenu -P 'confirm password')"
        else
            NEWPASS="$(passwordbox 'set password')"
            NEWPASS2="$(passwordbox 'confirm password')"
        fi
    done

    echo "$NEWUSER" >/root/instantARCH/config/user
    echo "$NEWPASS" >/root/instantARCH/config/password

    while [ -z "$NEWHOSTNAME" ]; do
        if guimode; then
            NEWHOSTNAME=$(imenu -i "enter name of this computer")
        else
            NEWHOSTNAME=$(textbox "enter name of this computer")
        fi
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

if guimode; then
    imenu -M <<<"The installation will now begin.
    This could take a while.
    Keep the machine powered and connected to the internet" &
else
    messagebox "The installation will now begin. This could take a while. Keep the machine powered and connected to the internet"
    clear
fi
