#!/bin/bash

# utility to manage installer variables

IROOT="/root/instantARCH/config"

if [ "$1" = "i" ]; then
    cat /dev/stdin >"$IROOT/$2"
elif [ -n "$2" ]; then
    echo "$2" >"$IROOT/$1"
else
    if [ -e "$IROOT/$1" ]; then
        cat "$IROOT/$1"
    else
        exit 1
    fi
fi
