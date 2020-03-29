#!/usr/bin/expect
set timeout 1000
spawn fdisk /dev/sda

expect "m for help"
# create partition table
send "o\n"
sleep 1
expect "m for help"
# create root partition
send "n\n"
expect "Select"
sleep 0.1
send "\n"
expect "number"
sleep 0.1
send "\n"
expect "First"
sleep 0.1
send "\n"
expect "Last"
sleep 0.1
# leave 2G for swap partition
send -- "-2G\n"
sleep 1

expect "m for help"

# create swap partition
send "n\n"
expect "Select"
sleep 0.1
send "\n"
expect "number"
sleep 0.1
send "\n"
expect "First"
sleep 0.1
send "\n"
expect "Last"
sleep 0.1
send "\n"
sleep 0.1
expect "m for help"
send "a\n"
expect "number"
sleep 0.1
send "1\n"
sleep 0.1

expect "m for help"
send "w\n"
expect "m for help"
