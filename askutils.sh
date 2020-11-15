#!/bin/bash

# User questions are seperated into functions to be reused in alternative installers
# like topinstall.sh

# check if the install session is GUI or cli

if [ -z "$INSTANTARCH" ]; then
    echo "defaulting instantarch location to /root/instantARCH"
    INSTANTARCH="/root/instantARCH"
fi

shopt -s expand_aliases
alias goback='backmenu && [ -n $GOINGBACK ] && return'

guimode() {
    if [ -e /opt/noguimode ]; then
        return 1
    fi

    if [ -n "$GUIMODE" ]; then
        return 0
    else
        return 1
    fi
}

BACKSTACK="artix"

# add element to back stack
backpush() {
    BACKSTACK="$BACKSTACK
$1"
}

# pop element from back stack
backpop() {
    ASKTASK="$(tail -1 <<<"$BACKSTACK")"
    echo "going back to $ASKTASK"
    BACKSTACK="$(sed '$d' <<<"$BACKSTACK")"
}

# add installation info to summary
addsum() {
    SUMMARY="$SUMMARY
        $1: $(iroot "$2")"
}

# set status wallpaper
wallstatus() {
    guimode && feh --bg-scale /usr/share/liveutils/"$1".jpg &
}

# menu that allows choosing a partition and put it in stdout
# no var
choosepart() {
    unset RETURNPART
    while [ -z "$RETURNPART" ]; do
        fdisk -l | grep '^/dev' | sed 's/\*/ b /g' | imenu -l "$1" | grep -o '^[^ ]*' >/tmp/diskchoice
        RETURNPART="$(cat /tmp/diskchoice)"
        if ! [ -e "$RETURNPART" ]; then
            imenu -m "$RETURNPART does not exist" &>/dev/null
            unset RETURNPART
        fi

        for i in /root/instantARCH/config/part*; do
            if grep "^$RETURNPART$" "$i"; then
                echo "partition $RETURNPART already taken"
                imenu -m "partition $RETURNPART is already selected for $i"
                CANCELOPTION="$(echo '> alternative options
select another partition
cancel partition selection' | imenu -l ' ')"
                if grep -q 'cancel' <<<"$CANCELOPTION"; then
                    touch /tmp/loopaskdisk
                    rm /tmp/homecancel
                    iroot r manualpartitioning
                    exit 1
                fi
                unset RETURNPART
            fi
        done

    done
    echo "$RETURNPART"
}

# var: artix
artixinfo() {
    if command -v systemctl; then
        echo "regular arch based iso detected"
        return
    fi

    echo "You appear to be installing the non-systemd version of instantOS.
Support for non-systemd setups is experimental
Any issues should be solvable with manual intervention
Here's a list of things that do not work from the installer and how to work around them:
disk editor: set up partitions beforehand or use automatic partitioning
keyboard locale: set it manually after installation in the settings
systemd-swap (obviously)" | imenu -M
    backpush artix
    export ASKTASK="layout"

}


# ask for keyboard layout
# var: layout
asklayout() {
    cd "$INSTANTARCH"/data/lang/keyboard || return 1
    wallstatus worldmap

    LAYOUTLIST="$(ls)"
    if command -v localectl; then
        LAYOUTLIST="$LAYOUTLIST
$(localectl list-x11-keymap-layouts | sed 's/^/- /g')"
    fi

    NEWKEY="$(echo "$LAYOUTLIST" | imenu -l 'Select keyboard layout ')"

    if grep -q '^-' <<<"$NEWKEY"; then
        iroot otherkey "$NEWKEY"
        NEWKEY="$(sed 's/- //g' <<<"$NEWKEY")"
        echo "
$NEWKEY" >/root/instantARCH/data/lang/keyboard/other
    fi

    # option to cancel the installer
    if [ "${NEWKEY}" = "forcequit" ]; then
        exit 1
    fi

    if iroot otherkey; then
        iroot keyboard other
        NEWKEY="other"
    else
        iroot keyboard "$NEWKEY"
    fi

    backpush layout
    export ASKTASK="locale"
}

# ask for default locale
# var: locale
asklocale() {
    cd "$INSTANTARCH"/data/lang/locale || return 1
    while [ -z "$NEWLOCALE" ]; do
        NEWLOCALE="$(ls | imenu -l 'Select language> ')"
    done
    iroot locale "$NEWLOCALE"

    backpush locale
    ASKTASK="mirrors"
}

# ask about which hypervisor is used
# var: vm
askvm() {
    if imvirt | grep -iq 'physical'; then
        echo "system does not appear to be a virtual machine"
        export ASKTASK="region"
        return
    fi

    if ! imenu -c "is this system a virtual machine?"; then
        if echo "Are you sure it's not?
giving the wrong answer here might greatly decrease performance. " | imenu -C; then
            export ASKTASK="region"
            return
        fi
    fi

    iroot isvm 1

    echo "virtualbox
kvm/qemu
other" | imenu -l "which hypervisor is being used?" >/tmp/vmtype

    HYPERVISOR="$(cat /tmp/vmtype)"
    case "$HYPERVISOR" in
    kvm*)
        if grep 'vendor' /proc/cpuinfo | grep -iq 'AMD'; then
            echo "WARNING:
        kvm/QEMU on AMD is not meant for desktop use and
        is lacking some graphics features.
        This installation will work, but some features will have to be disabled and
        others might not perform well. 
        It is highly recommended to use Virtualbox instead." | imenu -M
            iroot kvm 1
            if lshw -c video | grep -iq 'qxl'; then
                echo "WARNING:
QXL graphics detected
These may trigger a severe Xorg memory leak on kvm/QEMU on AMD,
leading to degraded video and input performance,
please switch your video card to either virtio or passthrough
until this is fixed" | imenu -M
            fi
        fi
        ;;
    virtualbox)
        iroot virtualbox 1
        if imenu -c "would you like to install virtualbox guest additions?"; then
            iroot guestadditions 1
        fi
        ;;
    other)
        iroot othervm 1
        echo "selecting other"
        ;;
    esac
    backpush vm
    export ASKTASK="region"

}

# ask for region with region/city
# var: region
askregion() {
    cd /usr/share/zoneinfo || return 1
    while [ -z "$REGION" ]; do
        REGION=$(ls | imenu -l "select region ")
    done

    if [ -d "$REGION" ]; then
        cd "$REGION" || return 1
        while [ -z "$CITY" ]; do
            CITY="$(ls | imenu -l "select the City nearest to you ")"
        done
    fi

    iroot region "$REGION"
    [ -n "$CITY" ] && iroot city "$CITY"

    backpush region
    export ASKTASK="disk"
}


# offer to choose mirror country
# var: mirrors
askmirrors() {
    if command -v pacstrap; then
        echo "pacstrap detected"
    else
        echo "non-arch base, not doing mirrors"
        export ASKTASK="vm"
        return
    fi

    iroot askmirrors 1
    curl -s 'https://www.archlinux.org/mirrorlist/' | grep -i '<option value' >/tmp/mirrors.html
    grep -v '>All<' /tmp/mirrors.html | sed 's/.*<option value=".*">\(.*\)<\/option>.*/\1/g' |
        sed -e "1iauto detect mirrors (not recommended for speed)" |
        imenu -l "choose mirror location" >/tmp/mirrorselect
    if ! grep -q 'auto detect' </tmp/mirrorselect; then
        grep ">$(cat /tmp/mirrorselect)<" /tmp/mirrors.html | grep -o '".*"' | grep -o '[^"]*' | iroot i countrycode
        if echo '> manually sorting mirrors may take a long time
use arch ranking score (recommended)
sort all mirrors by speed' | imenu -l 'choose mirror settings' | grep -q 'speed'; then
            iroot sortmirrors 1
        fi
    else
        iroot automirrors 1
    fi

    backpush mirrors
    export ASKTASK="vm"
}

# choose between disks and manual partitioning
# var: installdisk
askinstalldisk() {
    wallstatus install
    DISK=$(fdisk -l | grep -i '^Disk /.*:' | sed -e "\$aother (experimental)" |
        imenu -l "select disk> ")

    if grep -q '^other' <<<"$DISK"; then
        backpush "installdisk"
        export ASKTASK="partitioning"
        return
    fi

    # use auto partitioning
    if ! echo "Install on $DISK ?
this will delete all existing data" | imenu -C; then
        unset DISK
        return
    fi

    DISKNAME="$(grep -o '/dev/[^:]*' <<<"$DISK")"

    # check if disk is valid
    if ! [ -e "$DISKNAME" ]; then
        imenu -m "$DISKNAME is an invalid disk name"
        unset DISK
        unset DISKNAME
        return
    fi

    iroot disk "$DISKNAME"
    # no efi partition needed, install on disk
    if ! efibootmgr; then
        echo "legacy bios detected, installing grub on $DISKNAME"
        iroot grubdisk "$DISKNAME"
    fi

    backpush installdisk
    export ASKTASK="drivers"
}


##############################################
## Beginning of partition related questions ##
##############################################

# var: partitioning
askpartitioning() {
    STARTCHOICE="$(echo 'edit partitions
choose partitions
use auto partitioning' | imenu -l)"

    case "$STARTCHOICE" in
    edit*)
        export ASKTASK="editparts"
        ;;
    choose*)
        export ASKTASK="root"
        ;;
    *partitioning)
        export ASKTASK="installdisk"
        ;;
    esac

    backpush partitioning
}

# choose root partition for programs etc
# var: root
askroot() {
    while [ -z "$ROOTCONFIRM" ]; do
        PARTROOT="$(choosepart 'choose root partition (required) ')"
        if imenu -c "This will erase all data on that partition. Continue?"; then
            ROOTCONFIRM="true"
            echo "instantOS will be installed on $PARTROOT"
        fi
        echo "$PARTROOT" | iroot i partroot
    done

    backpush root
    ASKTASK="home"
}

# cfdisk wrapper to modify partition table during installation
# var: editparts
askeditparts() {
    echo 'instantOS requires the following paritions: 
 - a root partition, all data on it will be erased
 - an optional home partition.
       If not specified, the same partition as root will be used. 
       Gives you the option to keep existing data on the partition
 - an optional swap partition. 
       If not specified a swap file will be used. 

The Bootloader requires

 - an EFI partition on uefi systems
 - a disk to install it to on legacy-bios systems
' | imenu -M

    EDITDISK="$(fdisk -l | grep -i '^Disk /.*:' | imenu -l 'choose disk to edit> ' | grep -o '/dev/[^:]*')"
    echo "editing disk $EDITDISK"

    if guimode; then
        if command -v st &>/dev/null; then
            st -e bash -c "cfdisk $EDITDISK"
        elif command -v urxvt &>/dev/null; then
            urxvt -e bash -c "cfdisk $EDITDISK"
        else
            xterm -e bash -c "cfdisk $EDITDISK"
        fi
    else
        cfdisk "$EDITDISK"
    fi

    iroot disk "$EDITDISK"
    startchoice
}

# choose home partition, allow using existing content or reformatting
askhome() {
    if ! imenu -c "do you want to use a seperate home partition?"; then
        return
    fi

    HOMEPART="$(choosepart 'choose home partition >')"
    case "$(echo 'keep current home data
erase partition to start fresh' | imenu -l)" in
    keep*)
        echo "keeping data"

        if imenu -c "do not overwrite dotfiles? ( warning, this can impact functionality )"; then
            iroot keepdotfiles 1
        fi

        ;;
    erase*)
        echo "erasing"
        iroot erasehome 1
        ;;
    esac

    iroot parthome "$HOMEPART"

    backpush home
    export ASKTASK="swap"
}

# choose swap partition or swap file
# var: swap
askswap() {
    case "$(echo 'use a swap file
use a swap partition' | imenu -l)" in

    *file)
        echo "using a swap file"
        ;;
    *partition)
        echo "using a swap partition"
        while [ -z "$SWAPCONFIRM" ]; do
            PARTSWAP="$(choosepart 'choose swap partition> ')"
            if imenu -c "This will erase all data on that partition. It should also be on a fast drive. Continue?"; then
                SWAPCONFIRM="true"
                echo "$PARTSWAP will be used as swap"
                iroot partswap "$PARTSWAP"
            fi
        done
        ;;
    esac

    backpush swap
    export ASKTASK="grub"
}

# choose wether to install grub and where to install it
# var: grub
askgrub() {

    while [ -z "$BOOTLOADERCONFIRM" ]; do
        if ! imenu -c "install bootloader (grub) ? (recommended)"; then
            if imenu -c "are you sure? This could make the system unbootable. "; then
                iroot nobootloader 1
                return
            fi
        else
            BOOTLOADERCONFIRM="true"
        fi
    done

    if efibootmgr; then
        while [ -z "$EFICONFIRM" ]; do
            choosepart 'select efi partition' | iroot i partefi
            if echo "This will format $(iroot partefi)
In most cases it *only* contains the bootloader
Operating systems that are already installed will remain bootable" | imenu -C; then
                EFICONFIRM="true"
            else
                rm /root/instantARCH/config/partefi
            fi
        done
    else
        GRUBDISK=$(fdisk -l | grep -i '^Disk /.*:' | imenu -l "select disk for grub " | grep -o '/dev/[^:]*')
        echo "grub disk $GRUBDISK"
        iroot grubdisk "$GRUBDISK"
    fi

    backpush grub
    export ASKTASK="drivers"
}


########################################
## End of partition related questions ##
########################################

# choose between different nvidia drivers
# var: drivers
askdrivers() {

    if lspci | grep -iq 'nvidia'; then
        echo "nvidia card detected"
    else
        echo "no nvidia card, not asking for drivers"
        export ASKTASK="user"
        return
    fi

    iroot hasnvidia 1
    while [ -z "$DRIVERCHOICE" ]; do
        DRIVERCHOICE="$(echo 'nvidia proprietary (recommended)
nvidia-dkms (try if proprietary does not work)
nouveau open source
install without graphics drivers (not recommended)' | imenu -l 'select graphics drivers')"

        if grep -q "without" <<<"$DRIVERCHOICE"; then
            if ! echo "are you sure you do not want to install graphics drivers?
This could prevent the system from booting" | imenu -C; then
                unset DRIVERCHOICE
            fi
        fi

    done

    if grep -qi "dkms" <<<"$DRIVERCHOICE"; then
        iroot graphics "dkms"
    elif grep -qi "nvidia" <<<"$DRIVERCHOICE"; then
        iroot graphics "nvidia"
    elif grep -qi "open" <<<"$DRIVERCHOICE"; then
        iroot graphics "open"
    elif [ -z "$DRIVERCHOICE" ]; then
        iroot graphics "nodriver"
    fi

    backpush drivers
    export ASKTASK="user"
}

# ask for user details
# var: user
askuser() {
    while [ -z "$NEWUSER" ]; do
        wallstatus user
        NEWUSER="$(imenu -i 'set username')"

        # validate input as a unix name
        if ! grep -Eq '^[a-z_]([a-z0-9_-]{0,31}|[a-z0-9_-]{0,30}\$)$' <<<"$NEWUSER"; then
            imenu -e "invalid username, usernames must not contain spaces or special symbols and start with a lowercase letter"
            unset NEWUSER
        fi
    done

    while ! [ "$NEWPASS" = "$NEWPASS2" ] || [ -z "$NEWPASS" ]; do
        NEWPASS="$(imenu -P 'set password')"
        NEWPASS2="$(imenu -P 'confirm password')"
        if ! [ "$NEWPASS" = "$NEWPASS2" ]; then
            echo "the confirmation password doesn't match.
Please enter a new password" | imenu -M
        fi
    done

    iroot user "$NEWUSER"
    iroot password "$NEWPASS"

    backpush user
    export ASKTASK="hostname"
}

# var: hostname
askhostname() {

    NEWHOSTNAME="$(imenu -i "enter the name of this computer")"
    if ! grep -q -E '^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$' <<<"$NEWHOSTNAME"; then
        imenu -m "$NEWHOSTNAME is not a valid hostname"
        return
    fi

    iroot hostname "$NEWHOSTNAME"

    backpush hostname
    export ASKTASK="advanced"
}


############################################################################################
## optional advanced options that allow more experienced users to customize their install ##
############################################################################################

askplymouth() {
    if imenu -c "enable autologin ? "; then
        iroot r noautologin
    else
        iroot noautologin 1
        echo "disabling autologin"
    fi
    export ASKTASK="advanced"
}

askautologin() {
    echo "editing autologin"
    if imenu -c "enable plymouth ? "; then
        iroot r noplymouth
    else
        iroot noplymouth 1
        echo "disabling plymouth"
    fi
    export ASKTASK="advanced"
}

askswapfile() {
    SWAPMETHOD="$(echo 'systemd-swap
swapfile
none' | imenu -C 'choose swap method')"

    iroot swapmethod "$SWAPMETHOD"
    export ASKTASK="advanced"

}

askkernel() {
    KERNEL="$(echo 'linux
linux-lts
linux-zen' | imenu -l 'select kernel')"

    iroot kernel "$KERNEL"
    echo "selected $(iroot kernel) kernel"
    export ASKTASK="advanced"
}

askpackages() {
    PACKAGELIST="$(echo 'libreoffice-fresh
lutris
chromium
code
pcmanfm
obs-studio
krita
gimp
inkscape
audacity
virtualbox' | imenu -b 'select extra packages to install')"

    if [ -z "${PACKAGELIST[0]}" ]; then
        echo "No extra packages to install"
        return
    fi

    if grep 'lutris' <<<"$PACKAGELIST"; then
        PACKAGELIST="$PACKAGELIST
wine
vulkan-tools"
    fi

    if grep 'virtualbox' <<<"$PACKAGELIST"; then
        PACKAGELIST="$PACKAGELIST
virtualbox-host-modules-arch"
    fi

    echo "adding extra packages to installation"
    iroot packages "$PACKAGELIST"

    export ASKTASK="advanced"
}

asklogs() {
    if imenu -c "backup installation logs to ix.io ? (disabled by default)"; then
        iroot logging 1
    else
        iroot r logging
    fi
    export ASKTASK="advanced"
}

askadvanced() {
    if ! iroot advancedsettings && ! imenu -c -i "edit advanced settings? (use only if you know what you're doing)"; then
        backpush advanced
        export ASKTASK="confirm"
        return
    fi

    iroot advancedsettings 1

    CHOICE="$(echo 'autologin
plymouth
kernel
logs
swap
packages
OK' | imenu -l 'select option')"

    [ -z "$CHOICE" ] && return
    if [ "$CHOICE" = "OK" ]; then
        echo "confirming advanced settings"
        backpush advanced
        export ASKTASK="confirm"
        return
    fi

    export ASKTASK="$CHOICE"

}


###############################
## end of question functions ##
###############################

# confirm installation questions
confirmask() {
    SUMMARY="Installation Summary:"

    addsum "Username" "user"
    addsum "Locale" "locale"
    addsum "Region" "region"
    addsum "Subregion" "city"

    if iroot otherkey; then
        addsum "Keyboard layout" "otherkey"
    else
        addsum "Keyboard layout" "keyboard"
    fi

    if iroot manualpartitioning; then
        SUMMARY="$SUMMARY
manual partitioning: "
        disksum() {
            if iroot "part${1}"; then
                addsum "$1 partition" "$1"
            fi
        }
        disksum "root"
        disksum "home"
        disksum "swap"
        disksum "grub"
    else
        addsum "Target install drive" "disk"
    fi

    addsum "Hostname" "hostname"

    if efibootmgr; then
        SUMMARY="$SUMMARY
GRUB: UEFI"
    else
        SUMMARY="$SUMMARY
GRUB: BIOS"
    fi

    SUMMARY="$SUMMARY
Should installation proceed with these parameters?"

    echo "summary:
$SUMMARY"

    if imenu -C <<<"$SUMMARY"; then
        iroot confirm 1
        export ASKCONFIRM="true"
    else
        unset CITY
        unset REGION
        unset DISK
        unset NEWKEY
        unset NEWLOCALE
        unset NEWPASS2
        unset NEWPASS
        unset NEWHOSTNAME
        unset NEWUSER
    fi
}
