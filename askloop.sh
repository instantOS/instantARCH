#!/bin/bash

# new insteractive loop for ask.sh

mkdir /root/instantARCH/config
mkdir config

source <(curl -Ls git.io/paperbash)
pb dialog

source /root/instantARCH/askutils.sh

backmenu() {
    BACKCHOICE="$(echo ':g Continue installation
:b Back
:r ﰸCancel installation' | instantmenu -q 'back menu' -i -l 209 -h -1 -bw 8 -a 20 -w -1 -c)"

    case $BACKCHOICE in
    *Back)
        backpop
        export GOINGBACK="true"
        return 0
        ;;
    Cancel)
        if imenu -c "are you sure you want to cancel the installation?"; then
            iroot cancelinstall 1
            exit
        fi
        ;;
    *)
        echo "continuing installation"
        return 0
        ;;
    esac

}



export ASKTASK=artix

askquestion() {
    case "$ASKTASK" in
    artix)
        artixinfo
        ;;
    layout)
        asklayout
        ;;
    locale)
        asklocale
        ;;
    mirrors)
        askmirrors
        ;;
    region)
        askregion
        ;;
    drivers)
        askdrivers
        ;;
    vm)
        askvm
        ;;
    installdisk)
        askinstalldisk
        ;;
    partitioning)
        partitioning
        ;;
    editparts)
        askeditparts
        ;;
    root)
        askroot
        ;;
    home)
        askhome
        ;;
    grub)
        askgrub
        ;;
    swap)
        askswap
        ;;
    user)
        askuser
        ;;
    hostname)
        askhostname
        ;;
    esac

}

askloop() {
    while [ -z "$ASKCONFIRM" ]; do
        askquestion
        if [ -z "$GOINGBACK" ]; then
            echo "going back"
            unset GOINGBACK
            ASKTASK="$BACKASK"
        fi
    done
    echo "confirmed selection"
}
