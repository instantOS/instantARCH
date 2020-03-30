#!/bin/bash

while [ -z "$NEWXORG" ]; do
    NEWXORG="$(cat /root/instantARCH/lang/xorgmaps | fzf --prompt 'select xorg keyboard layout')"
done
echo "setting keymap to"
localectl --no-convert set-x11-keymap "$NEWXORG"
localectl --no-convert set-keymap "$(cat /root/instantARCH/keylayout)"
