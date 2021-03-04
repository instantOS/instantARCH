#!/bin/bash

echo "cleaning pacman cache"
yes | pacman -Scc
