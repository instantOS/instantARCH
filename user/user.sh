#!/bin/bash

# user and password creation
source <(curl -Ls https://git.io/paperbash)
pb dialog

NEWUSER="$(textbox 'set username')"
NEWPASS="$(passwordbox 'set password')"

groupadd video &>/dev/null
groupadd wheel &>/dev/null
groupadd docker &>/dev/null

useradd -m "$NEWUSER" -s /bin/bash -G wheel,docker,video
echo "root:$NEWPASS" | chpasswd
echo "$NEWUSER:$NEWPASS" | chpasswd
