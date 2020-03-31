#!/bin/bash
source <(curl -Ls git.io/paperbash)
pb dialog

while ! [ -e /tmp/localedone ]; do
    while [ -z "$NEWLOCALE" ]; do
        NEWLOCALE=$(cat /etc/locale.gen | grep '^#[^ ]' | fzf --prompt 'select locale')
    done
    NEWGEN=$(grep '[^#]*' <<<"$NEWLOCALE")
    sed -i "s/$NEWLOCALE/$NEWGEN/g" /etc/locale.gen
    if confirm "Add another locale?"; then
        unset NEWLOCALE
    else
        touch /tmp/localedone
    fi
done

locale-gen
