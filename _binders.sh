#!/bin/bash

function unbind {
     sudo sh -c "echo '$1' > /sys/bus/pci/drivers/vfio-pci/new_id"
    sudo sh -c "echo '0000:$2' > /sys/bus/pci/devices/0000:$2/driver/unbind"
    sudo sh -c "echo '0000:$2' > /sys/bus/pci/drivers/vfio-pci/bind"
    sudo sh -c "echo '$1' > /sys/bus/pci/drivers/vfio-pci/remove_id"
    if [[ -z $3 ]]; then
        OPTS="$OPTS -device vfio-pci,host=$2"
    else
        OPTS="$OPTS -device vfio-pci,host=$2,$3"
    fi
}

function rebind {
    sudo sh -c "echo 1 > /sys/bus/pci/devices/0000:$1/remove"
}

OVMF="/usr/share/ovmf/x64/OVMF_CODE.fd"
OPTS=""

OPTS="$OPTS -vga none"
OPTS="$OPTS -soundhw hda"
OPTS="$OPTS -enable-kvm"

## Remove QEMU Monitor as separate window – avoids need for X11 Forwarding
OPTS="$OPTS -nographic"

function bind_kbd_usb {
    ############################################################################
    ## <USB_config>
    ############################################################################
    ## Logitech G603: Bus001, Port 007, id: 046d:c539
    ## Logitech G613: Bus001, Port 008, id: 046d:c53d

    ## Oculus Rift
    ## Headset, connected to USB 3.1 Gen 2 Type-A Port
    ## - B006, D002, id: 2833:3031
    ## - B005, D003, id: 2833:0031
    ## - B005, D002, id: 2833:2031
    ## Sensors (Dedicated 2.0):
    ## - B001, D001, id: 2833:0211
    ## Sensors (Dedicated 3.0):
    ## - B002, D002, id: 2833:0211
    ## - B002, D003, id: 2833:0211
    ############################################################################
    ## Adding Keyboard/Mouse, need to test bluetooth
    OPTS="$OPTS -usb"
    ## Logitech G603
    OPTS="$OPTS -usbdevice host:046d:c53d"
    ## Logitech G613
    OPTS="$OPTS -usbdevice host:046d:c539"
}

function mount_iso_ovmf {
    ## Adding OVMF BIOS
    OPTS="$OPTS -drive if=pflash,format=raw,readonly,file=${OVMF}"
    OPTS="$OPTS -device virtio-scsi-pci,id=scsi"
}

function mount_iso_boot {
    ## Adding boot media
    OPTS="$OPTS -drive file=$VMs/$1.iso,id=isocd,format=raw,if=none"
    OPTS="$OPTS -device scsi-cd,drive=isocd"
}

function mount_img_disk {
    ## Adding Win10 image
    OPTS="$OPTS -drive file=$VMs/$1.img,id=disk,format=qcow2,if=none,cache=writeback"
    OPTS="$OPTS -device scsi-hd,drive=disk"
}

function mount_iso_virt {
    ## Adding VirtIO drivers
    OPTS="$OPTS -drive file=$VMs/isos/virtio.iso,id=virtiocd,if=none,format=raw"
    OPTS="$OPTS -device ide-cd,bus=ide.1,drive=virtiocd"
}

function qemu_exit {
    sudo sh -c "echo 1 > /sys/bus/pci/rescan"
}