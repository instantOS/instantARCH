#!/usr/bin/expect
set timeout 1000
spawn fdisk instantdisk
expect "hello"
send "world"

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
expect "Select"
sleep 0.1
send "\n"
expect "sector"
sleep 0.1
send "\n"
expect "Last"
# leave 2G for swap partition
send "-2G\n"

expect "m for help"
# create swap partition
send "n\n"
expect "Select"
sleep 0.1
send "\n"
expect "Select"
sleep 0.1
send "\n"
expect "sector"
sleep 0.1
send "\n"
expect "Last"
# take all available space
send "\n"

expect "m for help"
send "w\n"
expect "m for help"
send "q\n"
