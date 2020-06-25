#!/bin/bash

# read out user selected locale
# build it and set it using localectl

cat /root/instantARCH/data/lang/locale/"$(iroot locale)" >>/etc/locale.gen

echo "" >>/etc/locale.gen
sleep 0.3
locale-gen

if ! [ -e /usr/bin/liveutils ]; then
    SETLOCALE="$(cat /root/instantARCH/data/lang/locale/$(iroot locale) |
        grep '.' | tail -1 | grep -o '^[^ ]*')"
    echo "setting localectl locale to $SETLOCALE"
    if command -v localectl; then
        localectl set-locale LANG="$SETLOCALE"
    fi
fi
