#!/bin/sh

# List the USBs in their IOMMU groups, from wiki
# https://wiki.archlinux.org/index.php/PCI_passthrough_via_OVMF#USB_controller

for usb_ctrl in $(find /sys/bus/usb/devices/usb* -maxdepth 0 -type l); do 
    pci_path="$(dirname "$(realpath "${usb_ctrl}")")"; 
    echo "Bus $(cat "${usb_ctrl}/busnum") --> $(basename $pci_path) (IOMMU group $(basename $(realpath $pci_path/iommu_group)))"; 
    lsusb -s "$(cat "${usb_ctrl}/busnum"):"; 
    echo; 
done