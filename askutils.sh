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
        $1: $(iroot $2)"
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
                # newline is intentional!!!
                echo "
$OTHERKEY" >/root/instantARCH/data/lang/keyboard/other
            fi
        fi
    done

    # option to cancel the installer
    if [ "${NEWKEY}" = "forcequit" ]; then
        exit 1
    fi
    iroot keyboard "$NEWKEY"
}

# ask for default locale
asklocale() {
    cd /root/instantARCH/data/lang/locale
    while [ -z "$NEWLOCALE" ]; do
        NEWLOCALE="$(ls | imenu -l 'Select language> ')"
    done
    iroot locale "$NEWLOCALE"

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

    [ -n "$CITY" ] && iroot city "$CITY"

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
            iroot graphics "dkms"
        elif grep -qi "nvidia" <<<"$DRIVERCHOICE"; then
            iroot graphics "nvidia"
        elif grep -qi "open" <<<"$DRIVERCHOICE"; then
            iroot graphics "open"
        elif [ -z "$DRIVERCHOICE" ]; then
            iroot graphics "nodriver"
        fi

    else
        echo "no nvidia card detected"
    fi

}

# offer to choose mirror country
askmirrors() {
    curl -s 'https://www.archlinux.org/mirrorlist/' | grep -i '<option value' >/tmp/mirrors.html
    grep -v '>All<' /tmp/mirrors.html | sed 's/.*<option value=".*">\(.*\)<\/option>.*/\1/g' |
        sed -e "1iauto detect mirrors" |
        imenu -l "choose mirror location" >/tmp/mirrorselect
    if ! grep -q 'auto detect' </tmp/mirrorselect; then
        cat /tmp/mirrors.html | grep ">$(cat /tmp/mirrorselect)<" | grep -o '".*"' | grep -o '[^"]*' >/tmp/countrycode
        echo "fetching mirrors for $(cat /tmp/mirrorselect)"
        curl -s "https://www.archlinux.org/mirrorlist/?country=$(cat /tmp/countrycode)&protocol=http&protocol=https&ip_version=4" |
            sed 's/^#Server /Server /g' >/tmp/mirrorlist
        cat /etc/pacman.d/mirrorlist >/tmp/oldmirrorlist

        if echo "would you like to sort mirrors by speed? (recommended)" | imenu -C; then
            touch /tmp/sortmirrors
        fi

        if [ -e /tmp/sortmirrors]; then
            cat /tmp/mirrorlist >/tmp/mirrorlist2
            rankmirrors -n 6 /tmp/mirrorlist2 | tee /tmp/mirrorlist
            touch /tmp/mirrorcontinue
        else
            touch /tmp/mirrorcontinue
        fi &

        while ! [ -e /tmp/mirrorcontinue ]; do
            imenu -m "sorting mirrors, please wait"
        done

        rm /tmp/mirrorcontinue
        /tmp/sortmirrors

        cat /tmp/mirrorlist >/etc/pacman.d/mirrorlist
        cat /tmp/oldmirrorlist >>/etc/pacman.d/mirrorlist
    else
        echo "ranking mirrors"
        reflector --latest 40 --protocol http --protocol https --sort rate --save /etc/pacman.d/mirrorlist
        iroot automirror 1
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

    iroot user "$NEWUSER"
    iroot password "$NEWPASS"

}

# ask about which hypervisor is used
askvm() {
    if imvirt | grep -iq 'physical'; then
        echo "system does not appear to be a virtual machine"
        return
    fi

    while [ -z "$VIRTCONFIRM" ]; do
        if ! imenu -c "is this system a virtual machine?"; then
            if echo "Are you sure it's not?
giving the wrong answer here might greatly decrease performance. " | imenu -C; then
                return
            fi
        else
            VIRTCONFIRM="true"
        fi
    done
    iroot isvm 1

    echo "virtualbox
kvm/qemu
other" | imenu -l "which hypervisor is being used?" >/tmp/vmtype

    HYPERVISOR="$(cat /tmp/vmtype)"
    case "$HYPERVISOR" in
    kvm*)
        if grep 'vendor' /proc/cpuinfo | grep -iq 'AMD'; then
            echo "WARNING:
        kvm/QEMU on AMD is not meant for desktop use and
        is lacking some graphics features.
        This installation will work, but some features will have to be disabled and
        others might not perform well. 
        It is highly recommended to use Virtualbox instead." | imenu -M
            iroot kvm 1
            if lshw -c video | grep -iq 'qxl'; then
                echo "WARNING:
QXL graphics detected
These may trigger a severe Xorg memory leak on kvm/QEMU on AMD,
leading to degraded video and input performance,
please switch your video card to either virtio or passthrough
until this is fixed" | imenu -M
            fi
        fi
        ;;
    virtualbox)
        iroot virtualbox 1
        ;;
    other)
        iroot othervm 1
        echo "selecting other"
        ;;
    esac

}
