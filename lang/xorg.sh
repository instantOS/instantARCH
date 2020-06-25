#!/bin/bash

# apply user keymap

KEYLANG=$(iroot keyboard)

NEWXORG=$(tail -1 /root/instantARCH/data/lang/keyboard/$KEYLANG)
NEWKEYMAP=$(head -1 /root/instantARCH/data/lang/keyboard/$KEYLANG)

echo "setting keymap to $NEWXORG"

if command -v localectl; then
    localectl --no-convert set-x11-keymap "$NEWXORG"
fi
setxkbmap -layout "$NEWXORG"

if grep -q .. <<<"$NEWKEYMAP"; then
    if command -v localectl; then
        localectl --no-convert set-keymap "$NEWKEYMAP"
    fi
fi
