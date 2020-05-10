#!/bin/bash

# sets default timeout to 2
sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=2/g' /etc/default/grub
grub-update
