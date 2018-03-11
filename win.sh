#!/bin/bash

. ./_binders.sh

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
OPTS="$OPTS -m 12288"

################################################################################
## <GPU_config> (Binding to VFIO for VM usage)
################################################################################
unbind '10de 1b06' '01:00.0' "multifunction=on"
unbind '10de 10ef' '01:00.1'
################################################################################
## </GPU_config>
################################################################################

## Adding Fresco Logic 3.0 Controller PCIe card
unbind '1b73 1100' '03:00.0' 

## Adding FireWire PCIe card – needed for Phantom Omni
unbind '1106 3044' '07:00.0'

################################################################################
## <USB_config>
################################################################################
bind_usb_kbd
################################################################################
## </USB_config>
################################################################################

################################################################################
## <HDD_config>
################################################################################
mount_iso_ovmf
mount_iso_boot "win"
mount_img_disk "win"
mount_iso_virt
################################################################################
## </HDD_config>
################################################################################

sudo qemu-system-x86_64 $OPTS

################################################################################
## <OS_remount>
################################################################################
rebind '01:00.0'
rebind '01:00.1'
rebind '03:00.0'
rebind '07:00.0'
################################################################################
## </OS_remount>
################################################################################

qemu_exit