#!/bin/bash

# apply default theme

echo "setting up default theme"

# checking all requirements are there
USERNAME="$(iroot user)"
[ -z "$USERNAME" ] && exit
[ -e /home/"$USERNAME" ] || exit
command -v instantthemes || command -v imosid || exit
chown -R "$USERNAME" /home/*

sudo -u "$USERNAME" instantthemes apply instantos

chown -R "$USERNAME" /home/*

echo "finished setting up default themes"
