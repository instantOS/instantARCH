#!/bin/bash

echo "cleaning pacman cache"
command -v paccache && paccache -rk 0
