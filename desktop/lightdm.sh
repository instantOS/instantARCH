#!/bin/bash

# this is run upon the first boot
# for some reason lightdm doesn't get enabled sucessfully during installation

if command -v lightdm; then
    echo "enabling lightdm"
    sudo systemctl enable --now lightdm
else
    echo "lightdm not found"
    exit 1
fi
