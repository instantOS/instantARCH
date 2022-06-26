#!/bin/bash

# clean up installation leftovers

echo "cleaning installation leftovers"

if iroot hasnvidia || sudo lshw -C display | grep -i '^ *vendor' | grep -qi intel
then
    echo "clearing unneeded vulkan drivers"
    if pacman -Q amdvlk
    then
        pacman -R --noconfirm amdvlk
    fi

    if pacman -Q lib32-amdvlk
    then
        pacman -R --noconfirm lib32-amdvlk
    fi

fi
