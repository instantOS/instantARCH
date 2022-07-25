#!/bin/bash

# all actions requiring user input for the installer
# on top of an existing arch base

source <(curl -Ls https://raw.githubusercontent.com/paperbenni/bash/master/import.sh)
pb dialog

source /root/instantARCH/askutils.sh

asklayout
askregion
asklocale
askdrivers

if ! ls /home/ | grep -q ..; then
    askuser
fi
