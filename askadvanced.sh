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

while :; do
    CHOICE="$(echo 'autologin
plymouth
kernel
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
    OK)
        echo "advanced options done"
        exit
        ;;
    esac
done
