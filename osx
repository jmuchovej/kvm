#!/bin/bash

. ./_binders.sh

## CPU/Memory management
## Getting Hyper-V working:
## - https://ladipro.wordpress.com/2017/02/24/running-hyperv-in-kvm-guest/
## - https://ladipro.wordpress.com/2017/07/21/hyperv-in-kvm-known-issues/
## Getting CPUs available:
## - `qemu-system-x86_64 -cpu help`
## Hyper-V currently doesn't seem to work (Feb 17, 2018)
OPTS="$OPTS -cpu host,kvm=off,+vmx"
# OPTS="$OPTS -cpu host,kvm=off"
OPTS="$OPTS -smp 4,sockets=1,cores=2,threads=2"
OPTS="$OPTS -m 12288"

bind_usb_kbd

mount_iso_ovmf
mount_iso_boot "osx"
mount_img_disk "osx"
mount_iso_virt

sudo qemu-system-x86_64 $OPTS

qemu_exit