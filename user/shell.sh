#!/bin/bash
# install instantSHELL and plugins

echo "setting up user shell"
USERNAME="$(iroot user)"
[ -z "$USERNAME" ] && exit
[ -e /home/"$USERNAME" ] || exit
command -v instantshell || exit
sudo -u "$USERNAME" instantshell install

echo "finished setting up user shell"
