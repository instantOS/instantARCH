#!/bin/bash

source /root/instantARCH/installutils.sh

escript depend/mirrors "configuring mirrors"
escript init/init "configuring time"
escript disk/disk "partitioning disk"
escript disk/mount "mounting partitions"
escript pacstrap/pacstrap "installing base packages"
sleep 0.5
