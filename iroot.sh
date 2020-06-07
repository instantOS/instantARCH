#!/bin/bash

# utility to manage installer variables

IROOT="/root/instantARCH/config"
case "$1" in
g)
    # get value of conf
    # return 1 if value is not set
    if [ -e "$IROOT/$2" ]; then
        cat "$IROOT/$2"
    else
        exit 1
    fi
    ;;
s)
    # set config $2 to value $3
    echo "$3" >"$IROOT/$2"
    ;;
i)
    # set config $2 to stdin
    cat /dev/stdin >"$IROOT/$2"
    ;;
esac
