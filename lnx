#!/bin/bash

. "$VMs/_binders.sh"

rescan

## CPU/Memory management
## Getting Hyper-V working:
## - https://ladipro.wordpress.com/2017/02/24/running-hyperv-in-kvm-guest/
## - https://ladipro.wordpress.com/2017/07/21/hyperv-in-kvm-known-issues/
## Getting CPUs available:
## - `qemu-system-x86_64 -cpu help`
## Hyper-V currently doesn't seem to work (Feb 17, 2018)
OPTS="$OPTS -cpu host,kvm=off"
# OPTS="$OPTS -cpu host,kvm=off"
OPTS="$OPTS -smp 4,sockets=1,cores=2,threads=2"
while getopts 'm:' flag; do
    case "${flag}" in
        "m") OPTS="$OPTS -m $((OPTARG * 1024))" ;;
        *)   printf "Unexpected arg."; exit -1;  ;;
    esac
done

## Adding GPU
unbind '10de 1b06' '01:00.0' "multifunction=on"
unbind '10de 10ef' '01:00.1'

unbind '10de 1b06' '02:00.0' "multifunction=on"
unbind '10de 10ef' '02:00.1'

## Adding keyboard/mouse
bind_kbd_usb

## Adding drives
mount_iso_ovmf
mount_iso_boot "lnx.$1"
mount_img_disk "lnx.$1"
mount_iso_virt

## Start the damn machine
sudo qemu-system-x86_64 $OPTS

rebind "01:00.0"
rebind "01:00.1"
rebind "02:00.0"
rebind "02:00.1"

rescan
