#!/bin/bash

# all actions requiring user input for the installer
# on top of an existing arch base

source <(curl -Ls git.io/paperbash)
pb dialog

source /root/instantARCH/askutils.sh

asklayout
askregion
asklocale
askdrivers
