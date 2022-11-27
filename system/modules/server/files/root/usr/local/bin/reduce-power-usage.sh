#!/bin/sh

# In total this reduces power usage by 3 watts

echo 'med_power_with_dipm' > '/sys/class/scsi_host/host0/link_power_management_policy';
echo 'med_power_with_dipm' > '/sys/class/scsi_host/host1/link_power_management_policy';
echo 'med_power_with_dipm' > '/sys/class/scsi_host/host2/link_power_management_policy';
echo 'med_power_with_dipm' > '/sys/class/scsi_host/host3/link_power_management_policy';
# echo 'med_power_with_dipm' > '/sys/class/scsi_host/host4/link_power_management_policy';
# echo 'med_power_with_dipm' > '/sys/class/scsi_host/host5/link_power_management_policy';

echo 'auto' > '/sys/block/sda/device/power/control';
echo 'auto' > '/sys/block/sdb/device/power/control';
echo 'auto' > '/sys/block/sdc/device/power/control';
# echo 'auto' > '/sys/block/sdd/device/power/control';
# echo 'auto' > '/sys/block/sde/device/power/control';

echo 'auto' > '/sys/bus/pci/devices/0000:03:00.0/power/control';
echo 'auto' > '/sys/bus/pci/devices/0000:00:1f.0/power/control';
echo 'auto' > '/sys/bus/pci/devices/0000:00:00.1/power/control';
echo 'auto' > '/sys/bus/pci/devices/0000:04:00.0/power/control';
echo 'auto' > '/sys/bus/pci/devices/0000:00:15.0/power/control';
echo 'auto' > '/sys/bus/pci/devices/0000:00:12.0/power/control';
echo 'auto' > '/sys/bus/pci/devices/0000:00:00.0/power/control';
# echo 'auto' > '/sys/bus/pci/devices/0000:01:00.0/power/control';

echo 'auto' > '/sys/bus/pci/devices/0000:00:12.0/ata1/power/control';
echo 'auto' > '/sys/bus/pci/devices/0000:00:12.0/ata2/power/control';
# echo 'auto' > '/sys/bus/pci/devices/0000:01:00.0/ata3/power/control';
# echo 'auto' > '/sys/bus/pci/devices/0000:01:00.0/ata4/power/control';
# echo 'auto' > '/sys/bus/pci/devices/0000:04:00.0/ata5/power/control';
# echo 'auto' > '/sys/bus/pci/devices/0000:04:00.0/ata6/power/control';
