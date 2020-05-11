#!/bin/bash

# user and password creation

NEWUSER="$(cat /root/instantARCH/config/user)"
NEWPASS="$(cat /root/instantARCH/config/password)"

groupadd video &>/dev/null
groupadd wheel &>/dev/null
groupadd docker &>/dev/null

useradd -m "$NEWUSER" -s /bin/bash -G wheel,docker,video
echo "root:$NEWPASS" | chpasswd
echo "$NEWUSER:$NEWPASS" | chpasswd

groupadd -r autologin
gpasswd -a "$NEWUSER" autologin

sed -i "s/^#autologin-user=.*/autologin-user=$NEWUSER/" /etc/lightdm/lightdm.conf
sed -i "s/^#autologin-user-timeout=.*/autologin-user-timeout=0/" /etc/lightdm/lightdm.conf
sed -i "s/^#autologin-session=.*/autologin-session=instantos/" /etc/lightdm/lightdm.conf
