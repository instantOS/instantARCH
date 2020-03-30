#!/bin/bash

if grep -q 'greeter-session' /etc/lightdm/lightdm.conf; then
    LASTSESSION="$(grep 'greeter-session' /etc/lightdm/lightdm.conf | tail -1)"
    sed -i "s/$LASTSESSION/greeter-session=lightdm-gtk-greeter/g"
else
    sed -i 's/^\[Seat:\*\]/\[Seat:\*\]\ngreeter-session=lightdm-gtk-greeter/g' /etc/lightdm.conf
fi

systemctl enable lightdm
systemctl enable NetworkManager
