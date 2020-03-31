#!/bin/bash

cat /root/instantARCH/data/lang/locale/"$(cat /root/instantARCH/config/locale)" >>/etc/locale.gen
locale-gen
