#!/bin/bash

# insteractive loop for ask.sh
# allows going back, cancelling the installation etc

source <(curl -Ls 'https://raw.githubusercontent.com/paperbenni/bash/master/import.sh')
pb dialog

command -v backpush || source /root/instantARCH/askutils.sh
source /root/instantARCH/utils.sh

# enable choosing nothing to go back
export IMENUACCEPTEMPTY="true"

# TODO make questions activate this when canceled
backmenu() {
    if ! [ -e /tmp/climenu ]; then
        BACKCHOICE="$(echo ':g Continue installation
:b Back
:r ﰸCancel installation' | instantmenu -q 'back menu' -i -l 209 -h -1 -bw 8 -a 20 -w -1 -c)"

    else
        BACKCHOICE="$(echo 'Continue installation
 Back
 Cancel installation' | imenu -l)"

    fi

    case $BACKCHOICE in
        *Back)
            backpop
            return 0
            ;;
        *Cancel*)
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
export ASKTASK=""

installerror() {
    imenu -m "there has been an error in the installer"
}

# ask the "next" question based on the ASKTASK value
askquestion() {
    echo "asking question $ASKTASK"
    case "$ASKTASK" in
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
        partswap)
            askpartswap
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
        keyboardvariant)
            askkeyboardvariant
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
        [ -z "$ASKTASK" ] && ASKTASK='layout'
        askquestion
    done
    echo "confirmed selection"
}

if [ -z "$LOOPDEBUG" ]; then
    askloop
else
    echo "debugging loop"
fi
