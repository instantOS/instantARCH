#!/bin/bash

# start this on the first reboot after the actual install

cd /root/instantARCH

# wait for xsession to start
while ! pgrep lightdm; do
    sleep 10
done

bash ./lang/xorg.sh
sleep 1
bash ./lang/locale.sh

systemctl disable instantarch
