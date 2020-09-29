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
if grep -q '^user-session.*' /etc/lightdm/lightdm.conf; then
    echo "adjusting user session"
    sed -i 's/^user-session=.*/user-session=instantwm/g' /etc/lightdm/lightdm.conf
fi

# fix gui not showing up
sed -i 's/^#logind-check-graphical=.*/logind-check-graphical=true/' /etc/lightdm/lightdm.conf

# needed to get internet to work
if ! [ -e /opt/topinstall ] && ! iroot partswap; then
    if command -v systemctl; then
        if ! grep -iq manjaro /etc/os-release; then
            # enable swap
            systemctl enable systemd-swap
            {
                echo "swapfc_enabled=1"
                echo "swapfc_max_count=8"
            } >> /etc/systemd/swap.conf
        fi
    fi
fi

sed -i 's/# %wheel/%wheel/g' /etc/sudoers
echo 'Defaults env_reset,pwfeedback' >> /etc/sudoers

if command -v systemctl; then
    systemctl enable lightdm
    systemctl enable NetworkManager
fi

if ! command -v update-grub &>/dev/null; then
    # can't include this in package
    echo '#! /bin/sh
grub-mkconfig -o /boot/grub/grub.cfg' >/usr/bin/update-grub
    chmod 755 /usr/bin/update-grub
fi

# indicator file
if iroot kvm; then
    [ -e /opt/instantos ] || mkdir -p /opt/instantos
    echo "kvm" >/opt/instantos/kvm
fi
