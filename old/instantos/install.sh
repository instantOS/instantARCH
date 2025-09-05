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

# install pacman repos
bash repo.sh
pacman -Sy --noconfirm

pacloop instantos instantdepend

echo "installing pamac"
sudo pacman -S pamac-all --noconfirm
sed -i 's/#EnableAUR/EnableAUR/g' /etc/pamac.conf
sed -i 's/#CheckAURUpdates/CheckAURUpdates/g' /etc/pamac.conf
echo 'EnableFlatpak' >>/etc/pamac.conf

cd ~/instantOS || exit 1

if iroot noplymouth; then
    touch /opt/instantos/noplymouth
fi

bash rootinstall.sh

# change greeter appearance
[ -e /etc/lightdm ] || mkdir -p /etc/lightdm
cat /usr/share/instantdotfiles/rootconfig/lightdm-gtk-greeter.conf >/etc/lightdm/lightdm-gtk-greeter.conf

if ! iroot nobootloader; then
    # custom grub theme
    sed -i 's~^#GRUB_THEME.*~GRUB_THEME=/usr/share/grub/themes/instantos/theme.txt~g' /etc/default/grub
    update-grub
fi

echo "setting up trigger for first boot"
systemctl enable instantpostinstall
