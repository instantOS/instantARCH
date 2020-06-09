#!/bin/bash

# enable all sorts of configuration concerning login, lightdm, networking and grub

# enable lightdm greeter
if grep -q 'greeter-session' /etc/lightdm/lightdm.conf; then
    LASTSESSION="$(grep 'greeter-session' /etc/lightdm/lightdm.conf | tail -1)"
    sed -i "s/$LASTSESSION/greeter-session=lightdm-gtk-greeter/g" /etc/lightdm/lightdm.conf
else
    sed -i 's/^\[Seat:\*\]/\[Seat:\*\]\ngreeter-session=lightdm-gtk-greeter/g' /etc/lightdm/lightdm.conf
fi

# set up instantwm as a default user session
if grep-q '^user-session.*' /etc/lightdm/lightdm.conf; then
    echo "adjusting user session"
    sed -i 's/^user-session=.*/user-session=instantwm/g' /etc/lightdm/lightdm.conf
fi

# fix gui not showing up
sed -i 's/^#logind-check-graphical=.*/logind-check-graphical=true/' /etc/lightdm/lightdm.conf

# needed to get internet to work
if ! [ -e /opt/topinstall ] && ! iroot partswap; then
    if ! grep -iq manjaro /etc/os-release; then
        # enable swap
        systemctl enable systemd-swap
        sed -i 's/^swapfc_enabled=.*/swapfc_enabled=1/' /etc/systemd/swap.conf
    fi
fi

sed -i 's/# %wheel/%wheel/g' /etc/sudoers
systemctl enable lightdm
systemctl enable NetworkManager

if ! command -v update-grub &>/dev/null; then
    # can't include this in package
    echo '#! /bin/sh
grub-mkconfig -o /boot/grub/grub.cfg' >/usr/bin/update-grub
    chmod 755 /usr/bin/update-grub
fi
