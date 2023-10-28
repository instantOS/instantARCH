#!/bin/bash

# read out user selected locale
# generate it

export INSTANTARCH="${INSTANTARCH:-/root/instantARCH}"

# clear previous locale settings

sed -i 's/^[^#].*//g' /etc/locale.gen
cat "$INSTANTARCH"/data/lang/locale/"$(iroot locale)" >>/etc/locale.gen

echo "
# modified by instantARCH

" >>/etc/locale.gen
sleep 0.3
echo "generating locales"
locale-gen

