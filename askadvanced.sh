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

while :; do
    CHOICE="$(echo 'autologin
plymouth
OK' | imenu -l 'select option')"
    case "$CHOICE" in
    autolog*)
        echo "editing autologin"
        editautologin
        ;;
    plymouth)
        editplymouth
        ;;
    OK)
        echo "advanced options done"
        exit
        ;;
    esac
done
