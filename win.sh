#!/bin/bash

. "$HOME/Documents/kvm/_binders.sh"

## Make sure that all devices are bound as they're supposed to be
##  so that they can be unbound in a few ms
rescan

## CPU/Memory management
## Getting Hyper-V working:
## - https://ladipro.wordpress.com/2017/02/24/running-hyperv-in-kvm-guest/
## - https://ladipro.wordpress.com/2017/07/21/hyperv-in-kvm-known-issues/
## Getting CPUs available:
## - `qemu-system-x86_64 -cpu help`
## Hyper-V currently doesn't seem to work (Feb 17, 2018)
# OPTS="$OPTS -cpu Skylake-Client,kvm=off,hv_relaxed,hv_spinlocks=0x1fff,hv_vapic,hv_time,+vmx"
# OPTS="$OPTS -cpu host,kvm=off,hv_relaxed,hv_spinlocks=0x1fff,hv_vapic,hv_time,+vmx"
OPTS="$OPTS -cpu host,kvm=off"
OPTS="$OPTS -smp 4,sockets=1,cores=2,threads=2"
while getopts 'm:' flag; do
    case "${flag}" in
        "m") OPTS="$OPTS -m $((OPTARG * 1024))" ;;
        *)   printf "Unexpected arg."; exit -1;  ;;
    esac
done

# Bus 1 --> 0000:00:14.0 (IOMMU group 3)
# Bus 001 Device 003: ID 046d:c539 Logitech, Inc.
# Bus 001 Device 002: ID 046d:c53d Logitech, Inc.
# Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub

# Bus 2 --> 0000:00:14.0 (IOMMU group 3)
# Bus 002 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub

# Bus 3 --> 0000:05:00.0 (IOMMU group 16)
# Bus 003 Device 002: ID 2109:2812 VIA Labs, Inc. VL812 Hub
# Bus 003 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub

# Bus 4 --> 0000:05:00.0 (IOMMU group 16)
# Bus 004 Device 002: ID 2109:0812 VIA Labs, Inc. VL812 Hub
# Bus 004 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub

## Adding GPU
unbind '10de 1b06' '01:00.0' "multifunction=on"
unbind '10de 10ef' '01:00.1'

unbind '10de 1b06' '02:00.0' "multifunction=on"
unbind '10de 10ef' '02:00.1'

## Adding Fresco controller for USB 3.0
# unbind '1b73 1100' '03:00.0'

## Adding Intel USB 3.0
unbind '8086 a12f' '00:14.0'

## Adding FireWire PCIe card
#unbind '1106 3044' '03:00.0'

## Adding keyboard/mouse
bind_kbd_usb

## Adding drives
mount_iso_ovmf
mount_iso_boot "win"
mount_img_disk "win"
mount_iso_virt

## Start the damn machine
sudo qemu-system-x86_64 $OPTS

## Give it back
rebind '01:00.0'
rebind '01:00.1'
rebind '02:00.0'
rebind '02:00.1'
rebind '00:14.0'
# rebind '07:00.0'

## Handshake for default drivers
rescan

