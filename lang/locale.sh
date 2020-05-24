#!/bin/bash

cat /root/instantARCH/data/lang/locale/"$(cat /root/instantARCH/config/locale)" >>/etc/locale.gen
echo "" >>/etc/locale.gen
sleep 1
locale-gen

if ! [ -e /usr/bin/liveutils ]; then
    SETLOCALE="$(cat /root/instantARCH/data/lang/locale/$(cat /root/instantARCH/config/locale) |
        grep '.' | tail -1 | grep -o '^[^ ]*')"
    echo "setting localectl locale to $SETLOCALE"
    localectl set-locale LANG="$SETLOCALE"
fi
