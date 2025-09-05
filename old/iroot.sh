#!/bin/bash

# utility to manage installer variables

IROOT="${IROOT:-/root/instantARCH/config}"

[ -e "$IROOT" ] || mkdir -p "$IROOT"

if [ -z "$1" ]; then
    echo "usage: 
set value:    iroot field value
get value:    iroot field
remove/stdin: iroot r/i field"
    exit
fi

if [ "$1" = "i" ]; then
    cat /dev/stdin >"$IROOT/$2"
elif [ "$1" = "r" ]; then
    [ -e "$IROOT/$2" ] && rm "$IROOT/$2"
elif [ -n "$2" ]; then
    echo "$2" >"$IROOT/$1"
else
    if [ -e "$IROOT/$1" ]; then
        cat "$IROOT/$1"
    else
        exit 1
    fi
fi
