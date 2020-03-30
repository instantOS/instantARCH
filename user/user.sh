#!/bin/bash

# user and password creation
source <(curl -Ls https://git.io/JerLG)
pb dialog

NEWUSER="$(textbox 'set username')"
NEWPASS="$(passwordbox 'set password')"
clear

groupadd video
groupadd wheel
groupadd docker

useradd -m "$NEWUSER" -s /bin/bash -G wheel,docker,video
echo "$NEWPASS" | passwd "$NEWUSER" --stdin
