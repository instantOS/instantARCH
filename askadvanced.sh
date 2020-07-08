#!/bin/bash

############################################################################################
## optional advanced options that allow more experienced users to customize their install ##
############################################################################################

editautologin() {
    if imenu -c "enable autologin ? "; then
        iroot r noautologin
    else
        iroot noautologin 1
        echo "disabling autologin"
    fi
}

editplymouth() {
    if imenu -c "enable plymouth ? "; then
        iroot r noplymouth
    else
        iroot noplymouth 1
        echo "disabling plymouth"
    fi
}

choosekernel() {
    KERNEL="$(echo 'linux
linux-lts
default' | imenu -l 'select kernel')"

    iroot kernel "$KERNEL"
}

selectpackages() {
    PACKAGELIST="$(echo 'steam
libreoffice-fresh
lutris
steam
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

    if grep 'steam' <<<"$PACKAGELIST"; then
        PACKAGELIST="$PACKAGELIST
steam-native-runtime"
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

}

chooselogs() {
    if imenu -c "backup installation logs to ix.io ? (disabled by default)"; then
        iroot logging 1
    else
        iroot r logging
    fi
}

while :; do
    CHOICE="$(echo 'autologin
plymouth
kernel
logging
extra software
OK' | imenu -l 'select option')"
    case "$CHOICE" in
    autolog*)
        echo "editing autologin"
        editautologin
        ;;
    plymouth)
        editplymouth
        ;;
    kernel)
        choosekernel
        echo "selected $(iroot kernel) kernel"
        ;;
    logging)
        chooselogs
        ;;
    "extra software")
        selectpackages
        ;;
    OK)
        echo "advanced options done"
        exit
        ;;
    esac
done
