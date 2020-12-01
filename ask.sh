#!/bin/bash

# This is the interactive part of the installer
# Everything requiring user input is asked first,
# NO INSTALLATION IS DONE IN THIS SCRIPT
# Results get saved in /root/instantARCH/config
# and read out during installation
# results also get copied to the target root partition

mkdir /root/instantARCH/config
mkdir config

source <(curl -Ls git.io/paperbash)
pb dialog

if [ -e /usr/share/liveutils ] && ! [ -e /tmp/nogui ]; then
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
        imenu -m "WARNING: you're running a test version of the installer"
    fi
fi

/root/instantARCH/askloop.sh || {
    imenu -m "installation was canceled"
    exit 0
}

imenu -M <<<'The installation will now begin.
This could take a while.
You can check install progress and logs
by clicking on "2" in the top right.
Keep the machine powered and connected to the internet.
When installation is finished the machine will automatically reboot'
