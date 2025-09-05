#!/bin/bash

# ensure system time is correct

echo "configuring time"
if command -v timedatectl; then
    timedatectl set-ntp true
fi
