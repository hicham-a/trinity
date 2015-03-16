#!/bin/bash
umount /dev/sda1
if [ -b /dev/sda ]; then
   parted /dev/sda mklabel msdos
   parted -s --align cylinder /dev/sda mkpart primary ext2 0G 100%
   mkfs.ext4 /dev/sda1
fi
