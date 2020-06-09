#!/bash

#########################################################
## Allow manual partitioning when installing instantOS ##
## Supports editing partitions and using existing ones ##
#########################################################

# todo: warning and confirmation messages

source /root/instantARCH/askutils.sh

# first displayed menu
startchoice() {
    STARTCHOICE="$(echo 'edit partitions
choose partitions
continue installation' | imenu -l)"

    case "$STARTCHOICE" in

    edit*)
        editparts
        ;;
    choose*)
        chooseparts
        ;;
    continue*)
        exit
        ;;
    esac
}

# cfdisk wrapper to modify partition table during installation
editparts() {
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

    DISK="$(fdisk -l | grep -i '^Disk /.*:' | imenu -l 'choose disk to edit> ')"

    if guimode; then
        if command -v st; then
            st -e bash -c "cfdisk $DISK"
        elif command -v urxvt; then
            urxvt -e bash -c "cfdisk $DISK"
        else
            xterm -e bash -c "cfdisk $DISK"
        fi
    else
        cfdisk "$DISK"
    fi

    iroot disk "$DISK"
    startchoice
}

# choose all partitions
chooseparts() {
    choosehome
    chooseroot
    chooseswap
    choosegrub
}

# menu that allows choosing a partition and put it in stdout
choosepart() {
    unset RETURNPART
    while [ -z "$RETURNPART" ]; do
        fdisk -l | grep '^/dev' | imenu -l "$1" | grep -o '^[^ ]*' >/tmp/diskchoice
        RETURNPART="$(cat /tmp/diskchoice)"
        if ! [ -e "$RETURNPART" ]; then
            imenu -m "$RETURNPART does not exist" &>/dev/null
            unset RETURNPART
        fi
    done
    echo "$RETURNPART"
}

# choose home partition, allow using existing content or reformatting
choosehome() {
    if ! imenu -c "do you want to use a seperate home partition?"; then
        return
    fi

    HOMEPART="$(choosepart 'choose home partition >')"
    case "$(echo 'keep current home data
erase partition to start fresh' | imenu -l)" in
    keep*)
        echo "keeping"
        ;;
    erase*)
        echo "erasing"
        iroot erasehome 1
        ;;
    esac
    iroot parthome "$HOMEPART"
    echo "$HOMEPART" >/root/instantARCH/config/parthome

}

# choose swap partition or swap file
chooseswap() {
    case "$(echo 'use a swap file
use a swap partition' | imenu -l)" in

    *file)
        echo "using a swap file"
        ;;
    *partition)
        echo "using a swap partition"
        choosepart "choose swap partition> " >/root/instantARCH/config/partswap
        ;;

    esac
}

# choose root partition for programs etc
chooseroot() {
    while [ -z "$ROOTCONFIRM" ]; do
        PARTROOT="$(choosepart 'choose root partition')"
        imenu -c "This will erase all data on that partition. Continue?" &&
            ROOTCONFIRM="true"
        echo "$PARTROOT" >/root/instantARCH/config/partroot
    done
}

# choose wether to install grub and where to install it
choosegrub() {

    while [ -z $BOOTLOADERCONFIRM ]; do
        if ! confirm -c "install bootloader (grub) ?"; then
            if confirm -c "are you sure? This could make the system unbootable. "; then
                touch /root/instantARCH/config/nobootloader
                return
            fi
        else
            BOOTLOADERCONFIRM="true"
        fi
    done

    if efibootmgr; then

        while [ -z "$EFICONFIRM" ]; do
            choosepart 'select efi partition' >/root/instantARCH/config/partefi
            if imenu -c "this will erase all data on $(cat /root/instantARCH/config/partefi)"; then
                EFICONFIRM="true"
            else
                rm /root/instantARCH/config/partefi
            fi
        done

    else
        GRUBDISK=$(fdisk -l | grep -i '^Disk /.*:' | imenu -l "select disk for grub > ")
        echo "$GRUBDISK"
    fi
}

startchoice
