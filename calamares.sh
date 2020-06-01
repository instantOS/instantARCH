#!/bin/bash

# modify the calamares install of a manjaro session
# to install instantOS manjaro edition

if ! command -v calamares_polkit; then
    echo "please run this on a manjaro live session"
    exit
fi

sudo sed -i 's/postcfg/postcfg\n        - shellprocess/g' \
    /etc/calamares/settings.conf

curl -s 'https://raw.githubusercontent.com/instantOS/instantARCH/master/manjaro/shellprocess.conf' |
    sudo tee /etc/calamares/modules/shellprocess.conf

curl -s 'https://raw.githubusercontent.com/instantOS/instantARCH/master/calamares.sh' | sudo tee /usr/bin/instantcalamares
sudo chmod +x /usr/bin/instantcalamares
