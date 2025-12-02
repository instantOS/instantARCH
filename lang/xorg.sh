#!/bin/bash

# apply user keymap

KEYLANG=$(iroot keyboard)

NEWXORG="$(tail -1 /root/instantARCH/data/lang/keyboard/"$KEYLANG")"

if ! iroot otherkey; then
    NEWKEYMAP="$(head -1 /root/instantARCH/data/lang/keyboard/"$KEYLANG")"
fi

echo "setting xorg keymap to $NEWXORG"

if pgrep Xorg; then
    setxkbmap -layout "$NEWXORG"
fi

localectl --no-convert set-x11-keymap "$NEWXORG"
if [ -n "$NEWKEYMAP" ]; then
    echo "setting global keymap to $NEWKEYMAP"
    # set tty keymap
    localectl --no-convert set-keymap "$NEWKEYMAP"
fi
