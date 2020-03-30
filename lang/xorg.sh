#!/bin/bash

while [ -z "$NEWXORG" ]; do
    NEWXORG="$(cat /root/instantARCH/lang/xorgmaps | fzf --prompt 'select xorg keyboard layout')"
done

localectl --no-convert set-x11-keymap "$NEWXORG"
