#!/bin/bash

# apply locale settings

export INSTANTARCH="${INSTANTARCH:-/root/instantARCH}"

SETLOCALE="$(grep '.' "$INSTANTARCH"/data/lang/locale/"$(iroot locale)" | tail -1 | grep -o '^[^ ]*')"

echo "setting localectl locale to $SETLOCALE"
localectl set-locale LANG="$SETLOCALE"

echo "finished applying locale"
