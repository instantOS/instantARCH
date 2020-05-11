#!/bin/bash

# start this on the first reboot after the actual install

cd /root/instantARCH

bash ./lang/xorg.sh
sleep 1
bash ./lang/locale.sh
