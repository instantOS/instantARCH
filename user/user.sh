#!/bin/bash

# create user account
# make user default lightdm user
# add user to required groups

NEWUSER="$(iroot user)"
NEWPASS="$(iroot password)"

groupadd video &>/dev/null
groupadd wheel &>/dev/null
groupadd docker &>/dev/null
groupadd dav_group &>/dev/null


useradd -m "$NEWUSER" -s /usr/bin/zsh -G wheel,docker,video,dav_group
echo "root:$NEWPASS" | chpasswd
echo "$NEWUSER:$NEWPASS" | chpasswd

groupadd -r autologin
gpasswd -a "$NEWUSER" autologin

# enable autologin
if ! iroot noautologin; then
    sed -i "s/^\[Seat:\*\]/[Seat:*]\nautologin-user=$NEWUSER/g" /etc/lightdm/lightdm.conf
fi
