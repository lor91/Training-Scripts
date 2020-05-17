#!/bin/bash

#List the VMs

virsh list --all

#Gather needed input

read -p "Which VM do you want to delete? Ensure the name matches the output above. " vmname

echo "You have selected $vmname for deletion. This action cannot be reversed. Continue? (y/n)"
read answer

if [ "$answer" != "${answer#[Yy]}" ] ;then

#Undefine VM and remove disk files

virsh undefine $vmname

sudo rm -f /var/lib/libvirt/images/$vmname.qcow2

echo "If you receive no errors, the deletion is complete.

If you receive snapshot errors run the following to get a list of snapshots for the VM: 

virsh snapshot-list --domain $vmname

Then use the following, replacing SNAPSHOT_NAME with the name of the snapshot listed above:

virsh snapshot-delete --domain $vmname --snapshotname SNAPSHOT_NAME

Then rerun this script."

else

exit
 
fi

