#!/usr/bin/expect
set timeout 1000
spawn fdisk instantdisk 

expect "m for help"
# create partition table
send "o\n" 
expect "m for help"

# create root partition
send "n\n"
expect "Select" 
send "\n"
expect "number" 
send "\n"
expect "First" 
send "\n"
expect "Last" 
# leave 2G for swap partition
send -- "-2G\n"
# remove old signature
expect {
	"remove" {
		send "Y\n"
		sleep 0.1
		send "n\n"
	}
	"m for help" {
		send "n\n"
	}
} 
# create swap partition
expect "Select" 
send "\n"
expect "number" 
send "\n"
expect "First" 
send "\n"
expect "Last" 
send "\n" 
# remove old signature
expect {
	"remove" {
		send "Y\n"
		sleep 0.1
		send "a\n"
	}
	"m for help" {
		send "a\n"
	}
} 

# toggle bootable
expect "number" 
send "1\n"  
expect "m for help" 

# set partition type to swap for partition 2
send "t\n"
expect "number"
send "2\n"
expect "code"
send "82\n" 

# write changes to disk
expect "m for help"  
send "w\n"
expect "m for help"
