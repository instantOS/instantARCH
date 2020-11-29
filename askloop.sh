#!/bin/bash

# new insteractive loop for ask.sh

mkdir /root/instantARCH/config
mkdir config

source <(curl -Ls git.io/paperbash)
pb dialog

source /root/instantARCH/askutils.sh

# enable choosing nothing to go back
export IMENUACCEPTEMPTY="true"

# very WIP back menu
# TODO make questions activate this when canceled
backmenu() {
    BACKCHOICE="$(echo ':g Continue installation
:b Back
:r ﰸCancel installation' | instantmenu -q 'back menu' -i -l 209 -h -1 -bw 8 -a 20 -w -1 -c)"

    case $BACKCHOICE in
    *Back)
        backpop
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

# starting point
export ASKTASK=artix

installerror() {
    imenu -m "there has been an error in the installer"
}

# ask the "next" question based on the ASKTASK value
askquestion() {
    echo "asking question $ASKTASK"
    case "$ASKTASK" in
        ## artix warning
    artix)
        artixinfo
        ;;
        ## localisation questions
    layout)
        asklayout || installerror
        ;;
    locale)
        asklocale || installerror
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
        ## disk questions
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
        ## naming/account questions
    user)
        askuser
        ;;
    hostname)
        askhostname
        ;;
        ## Advanced options
    advanced)
        askadvanced
        ;;
    plymouth)
        askplymouth
        ;;
    autologin)
        askautologin
        ;;
    swapfile)
        askswapfile
        ;;
    kernel)
        askkernel
        ;;
    packages)
        askpackages
        ;;
    logs)
        asklogs
        ;;
    esac

}

askloop() {
    while [ -z "$ASKCONFIRM" ]; do
        askquestion
    done
    echo "confirmed selection"
}
