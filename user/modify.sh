#!/bin/bash
# modify existing users to work with instantOS

echo "adding groups"
groupadd video &>/dev/null
groupadd wheel &>/dev/null
groupadd docker &>/dev/null

usermod -a -G examplegroup exampleusername
REALUSERS="$(ls /home/ | grep -v '+')"
for i in $REALUSERS; do
    echo "processing user $i"
    usermod -a -G wheel "$i"
    usermod -a -G video "$i"
    usermod -a -G docker "$i"
done
