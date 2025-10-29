#!/bin/bash

# sets default grub timeout to 2

sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=2/g' /etc/default/grub
echo 'GRUB_DISABLE_OS_PROBER=false' | tee -a /etc/default/grub
update-grub

grub-update
