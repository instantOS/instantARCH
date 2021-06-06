#!/bin/bash

# enables trim if the root disk supports it

command -v systemctl || exit

DISK="$(iroot disk)"

if hdparm -I "$DISK" | grep -i trim | grep -iq supported; then
    echo 'enabling trim'
    systemctl enable fstrim.timer
fi
