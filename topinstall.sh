#!/bin/bash
# shellcheck disable=SC2010


# Simplified Assertion By Jacob Hrbek under the Terms of GPL-3
lineno() {
	if command -v bash 1>/dev/null; then
		printf "%s\n" "$LINENO"
		return 0
	elif ! command -v bash 1>/dev/null; then
		return 1
	else
		printf "%s\n" "Fatal: Unexpected!"
	fi
}

set -e

die() {
	case "$2" in
		*) printf 'FATAL: %s\n' "$3 $1"
	esac
	
	exit "$2"
}

# Die
alias die="die \"[ line \$LINENO\"\ ]"


if command -v ping 1>/dev/null; then
    ping -i 0.5 -c 5 raw.githubusercontent.com || die 1 "Domain 'raw.githubusercontent.com' is not reachable from this environment."
else
    die 1 "Unknown Error!"
fi

# print instantOS logo
printf "\n\n"
curl -s 'https://raw.githubusercontent.com/instantOS/instantLOGO/master/ascii.txt' | sed 's/^/    /g'
printf "\n\n"

if ! [ "$(id -u)" = 0 ]; then
    die 1 "The Script needs to be executed as Root."
else
    printf "%s\n" "Superuser Permission: Granted!"
fi


# imenu #
if ! command -v imenu; then
    curl -s https://raw.githubusercontent.com/instantOS/imenu/master/imenu.sh > /usr/local/bin/imenu
    if [ -f "/usr/local/bin/imenu" ]; then
        chmod 755 /usr/local/bin/imenu
    else
        die 1 "Unable to the change permission."
    fi
fi

# climenu #
if [ ! -f "/tmp/climenu" ]; then
    touch /tmp/climenu
else
    die 1 "Unable to create '/tmp/climenu'."
fi


# only runs on Arch GNU/Linux based distros
if ! grep -Eiq '(arch|manjaro)' /etc/os-release; then
    printf "%s\n" "system does not appear to be arch based.
instantARCH only works on arch based systems like Arch and Manjaro
are you sure you want to run this?" | imenu -C || {
        imenu -m "installation canceled"
        exit
    }
fi

if [ ! -f "/opt/topinstall" ]; then
    touch /opt/topinstall
else
    die 1 "Unable to create '/opt/topinstall'."
fi

if command -v pacman >/dev/null; then
    # todo: askmirrors
    pacman -Sy --noconfirm
    pacman -S git --noconfirm --needed
else
    die 1 "pacman was not found on this system."
fi

if [ -d "/root" ]; then
    cd /root || exit
    [ -e instantARCH ] ; rm -rf instantARCH
    if command -v ping 1>/dev/null; then
		ping -i 0.5 -c 5 github.com || die 1 "Domain 'github.com' is not reachable from this environment."
	else
		die 1 "Unknown Error!"
	fi
    git clone --depth=1 https://github.com/instantos/instantARCH.git
    if [ -d "instantARCH" ]; then
        cd instantARCH || die 1 "Failed to cd into '$(pwd)/instantARCH'"

        # Changing Permissions
        chmod +x -- *.sh
        chmod 755 ./*/*.sh

        mkdir -v config

        if [ -f "depend/depend.sh" ]; then
            ./depend/depend.sh
        else
            die 1 "Failed to execute 'depend/depend.sh'."
        fi

        if [ -f "topask.sh" ]; then
            # do all actions requiring user input first
            ./topask.sh
        else
            die 1 "Failed to execute 'topask.sh'."
        fi
    fi
fi


if ! command -v mhwd && iroot automirror; then
    pacman -S reflector --noconfirm --needed
    printf "%s\n" "selecting fastest mirror"
    reflector --latest 40 --protocol http --protocol https --sort rate --save /etc/pacman.d/mirrorlist
    pacman -Sy --noconfirm
fi

if [ -f "init/init.sh" ]; then
    ./init/init.sh
else
    die 1 "Failed to execute 'init/init.sh'."
fi


if command -v pacman >/dev/null; then
    pacman -S --noconfirm --needed base \
    linux linux-headers \
    linux-lts linux-lts-headers \
    linux-firmware
else
    die 1 "pacman was not found on this system."
fi


if [ -f "depend/system.sh" ]; then
    ./depend/system.sh
else
    die 1 "Failed to execute 'depend/system.sh'."
fi

if [ -f "chroot/chroot.sh" ]; then
    ./chroot/chroot.sh
else
    die 1 "Failed to execute 'chroot/chroot.sh'."
fi

if [ -f "chroot/drivers.sh" ]; then
    ./chroot/drivers.sh
else
    die 1 "Failed to execute 'chroot/drivers.sh'."
fi

if [ -f "network/network.sh" ]; then
    ./network/network.sh
else
    die 1 "Failed to execute 'network/network.sh'."
fi

if [ -f "bootloader/config.sh" ]; then
    ./bootloader/config.sh
else
    die 1 "Failed to execute 'bootloader/config.sh'."
fi

if ! ls /home/ | grep -q ..; then
    if [ -f "user/modify.sh" ]; then
        ./user/modify.sh
    else
        die 1 "Failed to execute 'user/modify.sh'."
    fi
else
    if [ -f "user/user.sh" ]; then
        ./user/user.sh
    else
        die 1 "Failed to execute 'user/user.sh'."
    fi
fi


if [ -f "lang/timezone.sh" ]; then
    ./lang/timezone.sh
else
    die 1 "Failed to execute 'lang/timezone.sh'."
fi

if [ -f "lang/locale.sh" ]; then
    ./lang/locale.sh
else
    die 1 "Failed to execute 'lang/locale.sh'."
fi

if [ -f "lang/xorg.sh" ]; then
    ./lang/xorg.sh
else
    die 1 "Failed to execute 'lang/xorg.sh'."
fi

if [ -f "instantos/install.sh" ]; then
    ./instantos/install.sh
else
    die 1 "Failed to execute 'instantos/install.sh'."
fi

printf "%s\n" "Done installing instantOS!"
imenu -c "A reboot is required. reboot now?"

if [ ! -f "/tmp/instantosreboot" ]; then
    touch /tmp/instantosreboot
else
    die 1 "Unable to create '/tmp/instantosreboot'."
fi

if [ -f "/tmp/climenu" ]; then
    rm -v /tmp/climenu
fi

[ -e /usr/local/bin/imenu ] ; rm -v /usr/local/bin/imenu
[ -e /tmp/instantosreboot ] ; reboot