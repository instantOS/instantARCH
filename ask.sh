#!/bin/bash

# This is the interactive part of the installer
# Everything requiring user input is asked first,
# NO INSTALLATION IS DONE IN THIS SCRIPT
# Results get saved in $INSTANTARCH/config
# and read out during installation
# results also get copied to the target root partition

mkdir -p "$INSTANTARCH"/config &>/dev/null
mkdir config &>/dev/null

source <(curl -Ls https://raw.githubusercontent.com/paperbenni/bash/master/import.sh)
pb dialog

source /root/instantARCH/askutils.sh

if [ -e /usr/share/liveutils ] && ! [ -e /tmp/nogui ] && ! [ -n "$CLIMODE" ]; then
    echo "GUI Mode active"
    export GUIMODE="True"
    GUIMODE="True"
fi

# switch imenu to fzf and dialog
if ! guimode; then
    touch /tmp/climenu
    imenu -m "Welcome to the instantOS installer"
else
    NEXTCHOICE="$(echo '>>h              Welcome to the instantOS installer
:g Next
:r ﰸCancel' | instantmenu -q 'select using the mouse, keywords and arrow keys' -i -l 209 -h -1 -bw 8 -a 60 -w -1 -c)"

    if grep -iq 'cancel' <<<"$NEXTCHOICE"; then
        echo "canceling installation"
        mkdir /opt/instantos
        touch /opt/instantos/installcanceled
        touch /opt/instantos/statuscanceled
        exit 1
    fi
    if iroot installtest; then
        imenu -m "WARNING: you're running a test version of the installer
    branch: $TESTBRANCH
    pacman repo: ${CUSTOMINSTANTREPO:-default}"
    fi

    if [ -n "$INSTANTARCHTESTING" ]; then
        if imenu -c 'enable debug mode?'; then
            echo 'enabling debug mode'
            touch /tmp/installdebug
            export INSTALLDEBUG='true'
        fi
    fi

fi

/root/instantARCH/askloop.sh || {
    imenu -m "installation was canceled"
    iroot cancelinstall 1
    exit 0
}

if ! iroot confirm; then
    if ! iroot cancelinstall; then
        imenu -m 'there was an error, installation will not continue'
        # TODO offer uploading logs
    fi
    exit 1
fi

if guimode; then
    imenu -M <<<'The installation will now begin.
This could take a while.
You can check install progress and logs
by clicking on "2" in the top left.
Keep the machine powered and connected to the internet.
When installation is finished the machine will automatically reboot'
else
    imenu -M <<<'The installation will now begin.
This could take a while.
Keep the machine powered and connected to the internet.
When installation is finished the machine will automatically reboot'
fi
