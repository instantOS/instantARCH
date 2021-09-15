#!/bin/bash

# install all instantOS software
# and apply instantOS specific changes and workarounds
source /root/instantARCH/moduleutils.sh

cd || exit 1

[ -e instantOS ] && rm -rf instantOS

while ! git clone --depth 1 https://github.com/instantOS/instantOS; do
    imenu -m "pull failed, please connect to the internet"
done

cd instantOS || exit 1

bash repo.sh
pacman -Sy --noconfirm

if command -v systemctl; then
    DEPENDPACKAGE="instantdepend"
else
    DEPENDPACKAGE="instantdepend-nosystemd"
fi


pacloop instantos "$DEPENDPACKAGE"


# don't install arch pamac on Manjaro
if ! grep -iq Manjaro /etc/os-release && ! command -v pamac; then
    echo "installing pamac"
    sudo pacman -S pamac-all --noconfirm
    sed -i 's/#EnableAUR/EnableAUR/g' /etc/pamac.conf
    sed -i 's/#CheckAURUpdates/CheckAURUpdates/g' /etc/pamac.conf
    echo 'EnableFlatpak' >>/etc/pamac.conf
fi

# needs yes because replacing packages has default no
yes | pacman -S libxft-bgra

cd ~/instantOS || exit 1

# disable plymouth on artix
if ! command -v systemctl || iroot noplymouth; then
    touch /opt/instantos/noplymouth
fi

bash rootinstall.sh

# change greeter appearance
[ -e /etc/lightdm ] || mkdir -p /etc/lightdm
cat /usr/share/instantdotfiles/rootconfig/lightdm-gtk-greeter.conf >/etc/lightdm/lightdm-gtk-greeter.conf

if ! iroot nobootloader; then
    # fix grub on manjaro
    if grep -iq 'manjaro' /etc/os-release; then
        update-grub
        mkinitcpio -P
    else
        # custom grub theme
        sed -i 's~^#GRUB_THEME.*~GRUB_THEME=/usr/share/grub/themes/instantos/theme.txt~g' /etc/default/grub
        update-grub
    fi
fi

# TODO: come up with alternative way for non systemd
if command -v systemctl; then
    echo "setting up trigger for first boot"
    systemctl enable instantpostinstall
fi
