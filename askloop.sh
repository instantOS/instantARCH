#!/bin/bash

# new insteractive loop for ask.sh

source <(curl -Ls git.io/paperbash)
pb dialog

command -v guimode || source /root/instantARCH/askutils.sh

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
    *installation)
        unset IMENUACCEPTEMPTY
        if imenu -c "are you sure you want to cancel the installation?"; then
            iroot cancelinstall 1
            exit
        fi
        export IMENUACCEPTEMPTY="true"
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
        askpartitioning
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
    confirm)
        confirmask
        ;;
    *)
        echo "error: unknown question"
        exit 1
        ;;
    esac

}


askloop() {
    while [ -z "$ASKCONFIRM" ]; do
        [ -z "$ASKTASK" ] && ASKTASK='artix'
        askquestion
    done
    echo "confirmed selection"
}

askloop
