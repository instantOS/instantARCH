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
