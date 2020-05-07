#!/bin/bash

KEYLANG=$(cat /root/instantARCH/config/keyboard)

NEWXORG=$(tail -1 /root/instantARCH/data/lang/keyboard/$KEYLANG)
NEWKEYMAP=$(head -1 /root/instantARCH/data/lang/keyboard/$KEYLANG)

echo "setting keymap to $NEWXORG"
localectl --no-convert set-x11-keymap "$NEWXORG"
localectl --no-convert set-keymap "$NEWKEYMAP"