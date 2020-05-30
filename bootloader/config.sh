#!/bin/bash

# update grub to detect operating systems and apply the instantOS theme
grub-mkconfig -o /boot/grub/grub.cfg
