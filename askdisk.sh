#!/bash

source /root/instantARCH/askutils.sh

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

chooseparts() {
    choosehome
}

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

choosehome() {
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

chooseroot() {

}
