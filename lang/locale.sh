#!/bin/bash

while [ -z "$NEWLOCALE" ]; do
    NEWLOCALE=$(cat /etc/locale.gen | fzf --prompt 'select locale')
done
