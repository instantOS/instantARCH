#!/bin/bash

# record version info for upgrading purposes

echo "getting installation information"
INSTANTOSVERSION=6
export INSTANTOSVERSION

mkdir -p /etc/instantos
cd /etc/instantos/ || exit 1

echo "$INSTANTOSVERSION" >version

if iroot liveversion; then
    LIVEVERSION="$(iroot liveversion)"
    echo "detected instllation iso version $LIVEVERSION"
else
    echo 'old installation iso used, unversioned'
fi

{
    echo "DATE=$(date '+%Y%m%d%H%M')"
    if [ -n "$LIVEVERSION" ]; then
        echo "ISOVERSION=$LIVEVERSION"
    fi
    echo "VERSION=$INSTANTOSVERSION"
    INSTANTARCHVERSION="$(iroot instantarchversion)"
    if [ -n "$LIVEVERSION" ]; then
        echo "INSTANTARCHVERSION=$INSTANTARCHVERSION"
    fi
} >/etc/instantos/installinfo

echo "finished getting installation information"
