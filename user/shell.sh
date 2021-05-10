#!/bin/bash
# install instantSHELL and plugins

echo "setting up user shell"
USERNAME="$(iroot user)"
[ -z "$USERNAME" ] && exit
[ -e /home/"$USERNAME" ] || exit
command -v instantshell || exit
chown -R "$USERNAME" /home/*
sudo -u "$USERNAME" instantshell install
chown -R "$USERNAME" /home/*

echo "finished setting up user shell"
