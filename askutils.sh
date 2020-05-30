#!/bin/bash

# User questions are seperated into functions to be reused in alternative installers
# like topinstall.sh


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

# add installation info to summary
addsum() {
    SUMMARY="$SUMMARY
        $1: $(cat /root/instantARCH/config/$2)"
}

# set status wallpaper
wallstatus() {
    guimode && feh --bg-scale /usr/share/liveutils/$1.jpg &
}

# ask for keyboard layout
asklayout() {
    cd /root/instantARCH/data/lang/keyboard
    while [ -z "$NEWKEY" ]; do
        wallstatus worldmap
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
}

# ask for default locale
asklocale() {
    cd /root/instantARCH/data/lang/locale
    while [ -z "$NEWLOCALE" ]; do
        NEWLOCALE="$(ls | imenu -l 'Select language> ')"
    done
    echo "$NEWLOCALE" >/root/instantARCH/config/locale

}

# ask for region with region/city
askregion() {
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

}

# choose between different nvidia drivers
askdrivers() {
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

}

# ask for user details
askuser() {
    while [ -z $NEWUSER ]; do
        wallstatus user
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

}
