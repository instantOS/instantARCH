#!/bin/bash

# make some iroot settings accessible by normal users

mkdir /etc/iroot

cp /root/instantARCH/config/* /etc/iroot/
chmod 755 /etc/iroot/*
rm /etc/iroot/password

echo "finished setting up config permissions"
