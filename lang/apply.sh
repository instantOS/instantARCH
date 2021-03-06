#!/bin/bash

# apply locale settings

export INSTANTARCH="${INSTANTARCH:-/root/instantARCH}"

SETLOCALE="$(grep '.' "$INSTANTARCH"/data/lang/locale/"$(iroot locale)" | tail -1 | grep -o '^[^ ]*')"

echo "setting localectl locale to $SETLOCALE"
if command -v localectl; then
    localectl set-locale LANG="$SETLOCALE"
else
    echo "artix locale configuration"
    echo 'export LANG="'"$SETLOCALE"'"' >/etc/locale.conf
    echo 'export LC_COLLATE="C"' >>/etc/locale.conf
fi

echo "finished applying locale"
