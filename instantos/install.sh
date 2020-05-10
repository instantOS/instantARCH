#!/bin/bash

cd
git clone --depth 1 https://github.com/instantOS/instantOS
cd instantOS
bash repo.sh
pacman -Sy --noconfirm
pacman -S instantos --noconfirm
pacman -S instantdepend --noconfirm
cd ~/instantOS
bash rootinstall.sh