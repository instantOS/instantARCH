#!/bin/bash

# set up keyboard layout
while [ -z "$LAYOUT" ]; do
    LAYOUT=$(cat /root/instantARCH/lang/layouts | fzf --prompt "select keyboard layout")
done

loadkeys "$LAYOUT"
echo "set layout to $LAYOUT"
