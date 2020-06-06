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
back' | imenu -l)"

    case "$STARTCHOICE" in

    edit*)
        editparts
        ;;
    choose*)
        chooseparts
        ;;
    esac
}

# cfdisk wrapper to modify partition table during installation
editparts() {
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

    echo "$DISK" >/root/instantARCH/config/disk
    startchoice
}

# choose all partitions
chooseparts() {
    choosehome
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
        touch /root/instantARCH/config/erasehome
        ;;
    esac
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

# //weiter
choosegrub() {
    if efibootmgr; then
        echo "efi setup detected"
        choosepart 'select efi partition'
    else

    fi
}
