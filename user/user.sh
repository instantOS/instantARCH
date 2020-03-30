#!/bin/bash

# user and password creation
source <(curl -Ls https://git.io/paperbash)
pb dialog

NEWUSER="$(textbox 'set username')"
NEWPASS="$(passwordbox 'set password')"
clear

groupadd video
groupadd wheel
groupadd docker

useradd -m "$NEWUSER" -s /bin/bash -G wheel,docker,video
echo "root:$NEWPASS" | chpasswd
echo "$NEWUSER:$NEWPASS" | chpasswd
