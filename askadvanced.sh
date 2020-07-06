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
    KERNEL=$(echo "linux
linux-lts
default" | imenu -l "select kernel")

    iroot kernel "$KERNEL"
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
    OK)
        echo "advanced options done"
        exit
        ;;
    esac
done
