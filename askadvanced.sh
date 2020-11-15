#!/bin/bash

############################################################################################
## optional advanced options that allow more experienced users to customize their install ##
############################################################################################

askplymouth() {
    if imenu -c "enable autologin ? "; then
        iroot r noautologin
    else
        iroot noautologin 1
        echo "disabling autologin"
    fi
    export ASKTASK="advanced"
}

askautologin() {
    echo "editing autologin"
    if imenu -c "enable plymouth ? "; then
        iroot r noplymouth
    else
        iroot noplymouth 1
        echo "disabling plymouth"
    fi
    export ASKTASK="advanced"
}

askswapfile() {
    SWAPMETHOD="$(echo 'systemd-swap
swapfile
none' | imenu -C 'choose swap method')"

    iroot swapmethod "$SWAPMETHOD"
    export ASKTASK="advanced"

}

askkernel() {
    KERNEL="$(echo 'linux
linux-lts
linux-zen' | imenu -l 'select kernel')"

    iroot kernel "$KERNEL"
    echo "selected $(iroot kernel) kernel"
    export ASKTASK="advanced"
}

askpackages() {
    PACKAGELIST="$(echo 'libreoffice-fresh
lutris
chromium
code
pcmanfm
obs-studio
krita
gimp
inkscape
audacity
virtualbox' | imenu -b 'select extra packages to install')"

    if [ -z "${PACKAGELIST[0]}" ]; then
        echo "No extra packages to install"
        return
    fi

    if grep 'lutris' <<<"$PACKAGELIST"; then
        PACKAGELIST="$PACKAGELIST
wine
vulkan-tools"
    fi

    if grep 'virtualbox' <<<"$PACKAGELIST"; then
        PACKAGELIST="$PACKAGELIST
virtualbox-host-modules-arch"
    fi

    echo "adding extra packages to installation"
    iroot packages "$PACKAGELIST"

    export ASKTASK="advanced"
}

asklogs() {
    if imenu -c "backup installation logs to ix.io ? (disabled by default)"; then
        iroot logging 1
    else
        iroot r logging
    fi
    export ASKTASK="advanced"
}

askadvanced() {
    if ! iroot advancedsettings && ! imenu -c -i "edit advanced settings? (use only if you know what you're doing)"; then
        backpush advanced
        export ASKTASK="confirm"
        return
    fi

    iroot advancedsettings 1

    CHOICE="$(echo 'autologin
plymouth
kernel
logs
swap
packages
OK' | imenu -l 'select option')"

    [ -z "$CHOICE" ] && return
    if [ "$CHOICE" = "OK" ]; then
        echo "confirming advanced settings"
        backpush advanced
        export ASKTASK="confirm"
        return
    fi

    export ASKTASK="$CHOICE"

}
