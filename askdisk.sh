#!/bin/bash

#########################################################
## Allow manual partitioning when installing instantOS ##
## Supports editing partitions and using existing ones ##
#########################################################

# todo: warning and confirmation messages

source /root/instantARCH/askutils.sh



# choose swap partition or swap file
chooseswap() {
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
                echo "$PARTSWAP" | iroot i partswap
            fi
        done
        ;;
    esac
    export BACKASK="swap"

}


# choose wether to install grub and where to install it
choosegrub() {

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
        echo "$GRUBDISK"
        iroot grubdisk "$GRUBDISK"
    fi
}

startchoice
iroot manualpartitioning 1
