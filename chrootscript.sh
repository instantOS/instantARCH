#!/usr/bin/expect
set timeout 100000
set scriptname [lindex $argv 0]

spawn arch-chroot /mnt
expect "archiso"
sleep 1
send "bash /root/instantARCH/$scriptname; exit\n"