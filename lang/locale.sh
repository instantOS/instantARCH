#!/bin/bash

while [ -z "$NEWLOCALE" ]; do
    NEWLOCALE=$(cat /etc/locale.gen | grep '^#[^ ]' | fzf --prompt 'select locale')
done

NEWGEN=$(grep '[^#]*' <<<"$NEWLOCALE")
sed -i "s/$NEWLOCALE/$NEWGEN/g" /etc/locale.gen
locale-gen
