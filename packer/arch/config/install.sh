#!/usr/bin/env bash -e

systemctl stop sshd.service

parted /dev/sda --script mklabel gpt
parted /dev/sda --script --align=optimal mkpart esp fat32 1MiB 1GiB set 1 esp on
parted /dev/sda --script --align=optimal mkpart primary ext4 1GiB 100%

mkfs.ext4 -L "root" /dev/sda2
mkfs.vfat -F32 /dev/sda1

mount /dev/sda2 /mnt
mkdir /mnt/boot
mount -o uid=0,gid=0,fmask=0077,dmask=0077 /dev/sda1 /mnt/boot

echo "ParallelDownloads = 16" >> /etc/pacman.conf

pacstrap -K /mnt base base-devel linux linux-firmware

genfstab -U /mnt >> /mnt/etc/fstab

cp bootstrap-system.sh /mnt/bootstrap-system.sh

arch-chroot /mnt /bootstrap-system.sh

rm /mnt/bootstrap-system.sh

sleep 10

umount -R /mnt


systemctl reboot
